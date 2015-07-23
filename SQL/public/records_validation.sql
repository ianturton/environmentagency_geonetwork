-- View: records_validation

-- DROP VIEW records_validation;

CREATE OR REPLACE VIEW records_validation AS 
 SELECT metadata_xml.id,
    statusvalues.name,
    metadatastatus.changedate,
    metadatastatus.changemessage,
    validation.valtype,
    validation.status,
    validation.failed,
    validation.valdate,
    ('"'::text || array_to_string(xpath('/gmd:MD_Metadata/gmd:distributionInfo/gmd:MD_Distribution/gmd:distributor/gmd:MD_Distributor/gmd:distributorTransferOptions/gmd:MD_DigitalTransferOptions/gmd:onLine/gmd:CI_OnlineResource/gmd:linkage/gmd:URL/text()'::text, metadata_xml.data_xml, '{{gco,http://www.isotc211.org/2005/gco},{gmd,http://www.isotc211.org/2005/gmd}}'::text[]), '-'::text)) || '"'::text AS orl,
    ('"'::text || array_to_string(xpath('/gmd:MD_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:citation/gmd:CI_Citation/gmd:title/gco:CharacterString/text()'::text, metadata_xml.data_xml, '{{gco,http://www.isotc211.org/2005/gco},{gmd,http://www.isotc211.org/2005/gmd}}'::text[]), '-'::text)) || '"'::text AS title
   FROM metadatastatus,
    statusvalues,
    metadata_xml
     LEFT JOIN validation ON validation.metadataid = metadata_xml.id
  WHERE metadatastatus.metadataid = metadata_xml.id AND metadatastatus.statusid = statusvalues.id AND statusvalues.name::text = 'approved'::text AND (validation.failed IS NULL OR validation.failed > 0);

ALTER TABLE records_validation
  OWNER TO geonetwork;
COMMENT ON VIEW records_validation
  IS 'View includes all records approved and not validated/failed validation, showing:
- ID
- Status
- Date last changed
- Change message
- Validation type
- Validation status
- Validation failed indicator
- Validation date
- ORL
- Title';

