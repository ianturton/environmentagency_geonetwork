-- View: records_custodian

-- DROP VIEW records_custodian;

CREATE OR REPLACE VIEW records_custodian AS 
 SELECT metadata_xml.id,
    ('"'::text || array_to_string(xpath('(/gmd:MD_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:pointOfContact[gmd:CI_ResponsibleParty/gmd:role/gmd:CI_RoleCode="custodian"]/gmd:CI_ResponsibleParty/gmd:individualName/gco:CharacterString/text())[1]'::text, metadata_xml.data_xml, '{{gco,http://www.isotc211.org/2005/gco},{gmd,http://www.isotc211.org/2005/gmd}}'::text[]), '-'::text)) || '"'::text AS custodian1,
    ('"'::text || array_to_string(xpath('(/gmd:MD_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:pointOfContact[gmd:CI_ResponsibleParty/gmd:role/gmd:CI_RoleCode="custodian"]/gmd:CI_ResponsibleParty/gmd:individualName/gco:CharacterString/text())[2]'::text, metadata_xml.data_xml, '{{gco,http://www.isotc211.org/2005/gco},{gmd,http://www.isotc211.org/2005/gmd}}'::text[]), '-'::text)) || '"'::text AS custodian2,
    ('"'::text || array_to_string(xpath('/gmd:MD_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:citation/gmd:CI_Citation/gmd:title/gco:CharacterString/text()'::text, metadata_xml.data_xml, '{{gco,http://www.isotc211.org/2005/gco},{gmd,http://www.isotc211.org/2005/gmd}}'::text[]), '-'::text)) || '"'::text AS title,
    metadatarating.rating
   FROM metadata_xml
     LEFT JOIN metadatarating ON metadata_xml.id = metadatarating.metadataid;

ALTER TABLE records_custodian
  OWNER TO geonetwork;
COMMENT ON VIEW records_custodian
  IS 'View includes all records showing:
- Custodian 1
- Custodian 2
- Title
- Rating
';
