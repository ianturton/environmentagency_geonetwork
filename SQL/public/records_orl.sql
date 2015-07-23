-- View: records_orl

-- DROP VIEW records_orl;

CREATE OR REPLACE VIEW records_orl AS 
 SELECT metadata_xml.id,
    ('"'::text || array_to_string(xpath('/gmd:MD_Metadata/gmd:distributionInfo/gmd:MD_Distribution/gmd:transferOptions/gmd:MD_DigitalTransferOptions/gmd:onLine/gmd:CI_OnlineResource/gmd:linkage/gmd:URL/text()'::text, metadata_xml.data_xml, '{{gco,http://www.isotc211.org/2005/gco},{gmd,http://www.isotc211.org/2005/gmd}}'::text[]), '-'::text)) || '"'::text AS orl,
    ('"'::text || array_to_string(xpath('/gmd:MD_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:citation/gmd:CI_Citation/gmd:title/gco:CharacterString/text()'::text, metadata_xml.data_xml, '{{gco,http://www.isotc211.org/2005/gco},{gmd,http://www.isotc211.org/2005/gmd}}'::text[]), '-'::text)) || '"'::text AS title
   FROM metadata_xml;

ALTER TABLE records_orl
  OWNER TO geonetwork;
COMMENT ON VIEW records_orl
  IS 'View includes all records,  showing:
- ID
- ORL
- Title';
