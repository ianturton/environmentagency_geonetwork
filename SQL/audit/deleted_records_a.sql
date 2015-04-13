-- View: audit.deleted_records_a

-- DROP VIEW audit.deleted_records_a;

CREATE OR REPLACE VIEW audit.deleted_records_a AS 
 SELECT logged_actions.client_query,
    ('0'::text || COALESCE(logged_actions.row_data -> 'id'::text, '0'::text))::integer AS uuid,
    XMLPARSE(DOCUMENT logged_actions.row_data -> 'data'::text STRIP WHITESPACE) AS data_xml,
    logged_actions.action,
    logged_actions.action_tstamp_tx,
    logged_actions.row_data -> 'owner'::text AS owner,
    ('0'::text || COALESCE(logged_actions.row_data -> 'groupowner'::text, '0'::text))::integer AS group_owner
   FROM audit.logged_actions
  WHERE logged_actions.table_name = 'metadata'::text AND logged_actions.action = 'D'::text AND logged_actions.action_tstamp_tx > ('now'::text::date - '7 days'::interval)
  ORDER BY ('0'::text || COALESCE(logged_actions.row_data -> 'id'::text, '0'::text))::integer;

ALTER TABLE audit.deleted_records_a
  OWNER TO geonetwork;
