-- View: records_deleted

-- DROP VIEW records_deleted;

CREATE OR REPLACE VIEW records_deleted AS 
 SELECT deleted_records.action_tstamp_tx AS delete_date,
    deleted_records.uuid AS id,
    ('"'::text || array_to_string(xpath('/gmd:MD_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:citation/gmd:CI_Citation/gmd:title/gco:CharacterString/text()'::text, deleted_records.data_xml, '{{gco,http://www.isotc211.org/2005/gco},{gmd,http://www.isotc211.org/2005/gmd}}'::text[]), '-'::text)) || '"'::text AS title,
    groups.name AS "group"
   FROM audit.deleted_records
     LEFT JOIN groups ON deleted_records.group_owner = groups.id
  WHERE deleted_records.action_tstamp_tx > ('now'::text::date - '7 days'::interval);

ALTER TABLE records_deleted
  OWNER TO geonetwork;
COMMENT ON VIEW records_deleted
  IS 'View includes all records deleted in past week, showing:
- ID
- Title
- Group';

