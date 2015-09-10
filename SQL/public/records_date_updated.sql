-- View: records_date_updated

-- DROP VIEW records_date_updated;

CREATE OR REPLACE VIEW records_date_updated AS 
 SELECT metadata_xml.id,
    metadata_xml.changedate,
    ('"'::text || array_to_string(xpath('(/gmd:MD_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:pointOfContact[gmd:CI_ResponsibleParty/gmd:role/gmd:CI_RoleCode="custodian"]/gmd:CI_ResponsibleParty/gmd:individualName/gco:CharacterString/text())[1]'::text, metadata_xml.data_xml, '{{gco,http://www.isotc211.org/2005/gco},{gmd,http://www.isotc211.org/2005/gmd}}'::text[]), '-'::text)) || '"'::text AS custodian,
    ('"'::text || array_to_string(xpath('/gmd:MD_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:citation/gmd:CI_Citation/gmd:title/gco:CharacterString/text()'::text, metadata_xml.data_xml, '{{gco,http://www.isotc211.org/2005/gco},{gmd,http://www.isotc211.org/2005/gmd}}'::text[]), '-'::text)) || '"'::text AS title,
    groups.name
   FROM metadata_xml
     LEFT JOIN groups ON metadata_xml.groupowner = groups.id
  WHERE to_date(metadata_xml.changedate::text, 'YYYY-MM-DD'::text) < ('now'::text::date - '3 mons'::interval);

ALTER TABLE records_date_updated
  OWNER TO geonetwork;
COMMENT ON VIEW records_date_updated
  IS 'View includes all records with no update in past three months, showing:
- ID
- Date last changed
- Custodian 1
- Title
- Group
';
