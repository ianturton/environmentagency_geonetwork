#!/usr/bin/env python

from jinja2 import Template
from urlparse import urlparse

import json
import argparse
import logging
import os
import psycopg2
import psycopg2.extras
import smtplib
import sys
import xml.etree.ElementTree as ET


def parse_config(conf_file, db_xpath):
    root = ET.parse(conf_file)
    return {
        'db_user': root.find('%sdb.user' % db_xpath).text,
        'db_pass': root.find('%sdb.pass' % db_xpath).text,
        'db_url': root.find('%sdb.dbname' % db_xpath).text
    }


def build_conn_args(url, db_user, db_pass):
    url = urlparse(':'.join(url.split(':')[2:]))
    host, port = url.netloc.split(':')
    return {
        'database': url.path[1:],
        'host': host,
        'port': port,
        'user': db_user,
        'password': db_pass
    }


def slurp(path):
    with open(path, 'r') as f:
        return f.read()


def get_sys_settings(conn, setting_sql_path):
    with conn.cursor(cursor_factory=psycopg2.extras.DictCursor) as cur:
        sql = slurp(setting_sql_path)
        cur.execute(sql)

        settings = {}
        for row in cur:
            settings[row.get('id')] = dict(row)

        for id in reversed(sorted(settings.keys())):
            row = settings.get(id)
            parent_row = settings.get(row.get('parentid'))
            if parent_row:
                if not isinstance(parent_row.get('value'), dict):
                    parent_row['value'] = dict()
                parent_row['value'][row.get('name')] = row.get('value')

        return settings.get(0).get('value')


def send_email(email_body, email_to, email_settings):

    email_from = email_settings.get('email')

    email_body = "\r\n".join(["From: %s" % email_from, "To: %s" % ",".join(email_to), email_body])

    server = smtplib.SMTP('%s:%s' % (email_settings.get('mailServer').get('host'), email_settings.get('mailServer').get('port')))
    server.sendmail(email_from, email_to, email_body)
    server.quit()


def main(geonetwork_config_path, num_days, email_template_path, base_dir, print_settings):

    log = logging.getLogger('resetpasswd')

    config = parse_config(geonetwork_config_path, './properties/')
    conn_args = build_conn_args(config.get('db_url'), config.get('db_user'), config.get('db_pass'))

    tmpl = Template(slurp(email_template_path))
    with psycopg2.connect(**conn_args) as conn:
        sys_settings = get_sys_settings(conn, os.path.join(base_dir, 'settings.sql'))
        if print_settings:
            print json.dumps(sys_settings, indent=4)
            return
        with conn.cursor(cursor_factory=psycopg2.extras.DictCursor) as cur:
            sql = slurp(os.path.join(base_dir, 'resetpasswd.sql'))
            log.info('Checking users who have not reset password in %s days.' % num_days)
            log.debug('Executing resetpasswd.sql:\n%s' % sql)
            cur.execute(sql, {'num_days': num_days})
            log.info('Found %s users who need to reset their password.' % cur.rowcount)
            for user in cur:
                log.info('Forcing password reset for user: %s.' % user.get('username'))
                log.debug('User: %s' % user)
                email_body = tmpl.render(user=user, settings=sys_settings)
                send_email(email_body, [user.get('email')], sys_settings.get('system').get('feedback'))


if __name__ == '__main__':

    # Logging
    log_level = logging.INFO
    log = logging.getLogger('resetpasswd')
    handler = logging.StreamHandler(sys.stdout)
    handler.setFormatter(logging.Formatter('%(asctime)s - %(name)s - %(levelname)s - %(message)s'))
    log.setLevel(log_level)
    log.addHandler(handler)

    base_dir = os.path.dirname(os.path.realpath(__file__))

    # Defaults
    email_template_path = os.path.join(base_dir, 'email.tmpl')
    num_days = 42

    parser = argparse.ArgumentParser(__file__, description="Force users who have not reset their password in a given number of days to do so at next login")
    parser.add_argument("config", help="""path to GeoNetwork config from which database connection details can be read;
                                          other settings are read from the GeoNetwork settings table within the database
                                          including SMTP details used to send email. All GeoNetwork setting are made
                                          available to the email template under the key 'settings'.
                                          To view available settings run with the --settings flag""")
    parser.add_argument("-d", "--days", default=num_days, type=int, help="number of days after which a user must changed their password, default: %s" % num_days)
    parser.add_argument("-t", "--template", default=email_template_path, help="path to Jinja2 email template, default: %s" % email_template_path)
    parser.add_argument("-s", "--settings", action='store_true', help="print GeoNetwork settings as JSON to stdout and exit")
    parser.add_argument("-l", "--log", default=logging.getLevelName(log_level), help="standard Python logging level, default: %s" % logging.getLevelName(log_level))
    args = vars(parser.parse_args())

    log_level = getattr(logging, args.get('log').upper(), logging.INFO)
    log.setLevel(log_level)

    main(args.get('config'), args.get('days'), args.get('template'), base_dir, args.get('settings'))
