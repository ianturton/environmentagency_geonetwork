-- View: records_status

-- DROP VIEW records_status;

CREATE OR REPLACE VIEW records_status AS 
 SELECT metadata_xml.id,
    statusvalues.name,
    metadatastatus.changedate,
    metadatastatus.changemessage,
    ('"'::text || array_to_string(xpath('/gmd:MD_Metadata/gmd:distributionInfo/gmd:MD_Distribution/gmd:transferOptions/gmd:MD_DigitalTransferOptions/gmd:onLine/gmd:CI_OnlineResource/gmd:linkage/gmd:URL/text()'::text, metadata_xml.data_xml, '{{gco,http://www.isotc211.org/2005/gco},{gmd,http://www.isotc211.org/2005/gmd}}'::text[]), '-'::text)) || '"'::text AS orl,
    ('"'::text || array_to_string(xpath('/gmd:MD_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:citation/gmd:CI_Citation/gmd:title/gco:CharacterString/text()'::text, metadata_xml.data_xml, '{{gco,http://www.isotc211.org/2005/gco},{gmd,http://www.isotc211.org/2005/gmd}}'::text[]), '-'::text)) || '"'::text AS title
   FROM metadata_xml
     LEFT JOIN metadatastatus ON metadatastatus.metadataid = metadata_xml.id
     LEFT JOIN statusvalues ON metadatastatus.statusid = statusvalues.id
  WHERE metadatastatus.changedate IS NULL OR metadatastatus.changedate::text = (( SELECT max(metadatastatus_1.changedate::text) AS max
           FROM metadatastatus metadatastatus_1));

ALTER TABLE records_status
  OWNER TO geonetwork;
