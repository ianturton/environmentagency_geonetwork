# Force GeoNetwork Password Reset

Requirement:

> must force the password to be changed every 42 days

GeoNetwork doesn't have a facility to force users to change their password after a given number of days. This script and associated SQL add this ability.

## Dependencies

* GeoNetwork 2.10 with PostgreSQL 9.3 database

### PostgreSQL

* Hstore PostgreSQL extension (`CREATE EXTENSION hstore`)
* [PostgreSQL Audit Trigger Plus](https://wiki.postgresql.org/wiki/Audit_trigger_91plus)

### Python

* The Python package `psycopg2` requires the system packages `python-dev` and `libpq-dev` be installed.

## Setup

### Database

Once the dependencies are installed run `setup.sql` against the GeoNetwork database.

### Python

Create a Python 2.7 virtual environment and install dependencies using:

    pip install -r requirements.txt

### Existing users

If you wish to avoid all existing users from being forced to change their password when the script is first ran run the following to change all users passwords and then change them back again to their original value. This will populate the audit table to indicate that their password has been changed:

    update users set password = password || 'a';
    update users set password = substring(password from 1 for 80);

### Logging

All log messages are written to `stdout`, should output be written to a file a sample logrotate configuration is provided (`resetpasswd.logrotate`) which should be copied to `/etc/logrotate.d/`.

## Usage

For usage run `resetpasswd.py` using the `python` interpreter from the virtual environment:

    python resetpasswd.py --help

## Implementation

### Notes

* Passwords are salted & hashed before they are stored within the database for added security; as a different salt value is used each time a password is hashed there is no way to compare passwords in the database even if previous password hashes are stored. This means that a user could change their password for the same value and this script would not be aware.

* GeoNetwork only allows users with the `RegisteredUser` profile to reset their password via a "Forgot your password" function. To work around this restriction the script sets a users profile to `RegisteredUser` if they must reset their password then reverts their profile to the appropriate value once they have changed their password via the "Forgot your password" function.

### Workflow

* The script `resetpasswd.py` is ran daily, it:
    * Builds a list of all users who have not changed their password in the last `n` days:
        * Find the `id` of all users that *do not* have an audit entry for the `users` table due to:
            * Update action with password in changed_fields - Updated their password
            * Insert action - New user added
    * For each `userid`:
        * Update the user's entry in the `users` table:
            * `profile` to `'RegisteredUser'` - enables the user to use the "Forgotten you password?" function to reset their password
            * `password` to a constant value - disables access to their account until their password is reset
        * Send an email to the user to inform them that they need to reset their password before they can next login

* A trigger is ran before the `password` field is updated in the `users` table, if the old `password` is equal to the constant set by `resetpasswd.py` then set the users profile to the most recent profile value found in the audit table.
    * The audit table is used to determine the profile as:
        * it's possible that the administrator might change the users profile during the time that the user has been locked out;
        * The Administrator profile is special in that it doesn't appear in the `usergroups` table as an Administrator is effectely a member of all groups. This means that the `usergroups` table can't be used to determine a users profile.

## Potential enhancements

* Send a warning email x days before a users account is locked
* Add prominent link to the home page from the page that confirms a users password has been changed
* Ensure a users is logged on the page that confirms a users password has been changed
