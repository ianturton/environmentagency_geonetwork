-- View: records_status

-- DROP VIEW records_status;

CREATE OR REPLACE VIEW records_status AS 
 SELECT metadata_xml.id,
    metadata_xml.uuid,
    array_to_string(xpath('/gmd:MD_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:citation/gmd:CI_Citation/gmd:title/gco:CharacterString/text()'::text, metadata_xml.data_xml, '{{gco,http://www.isotc211.org/2005/gco},{gmd,http://www.isotc211.org/2005/gmd}}'::text[]), '-'::text) AS title,
    statusvalues.name AS status,
    foo.userid,
    foo.changedate,
    foo.changemessage
   FROM ( SELECT DISTINCT ON (metadatastatus.metadataid) metadatastatus.metadataid,
            metadatastatus.statusid,
            metadatastatus.userid,
            metadatastatus.changedate,
            metadatastatus.changemessage
           FROM metadatastatus
          ORDER BY metadatastatus.metadataid, metadatastatus.changedate DESC) foo
     LEFT JOIN statusvalues ON foo.statusid = statusvalues.id
     RIGHT JOIN metadata_xml ON foo.metadataid = metadata_xml.id
  ORDER BY array_to_string(xpath('/gmd:MD_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:citation/gmd:CI_Citation/gmd:title/gco:CharacterString/text()'::text, metadata_xml.data_xml, '{{gco,http://www.isotc211.org/2005/gco},{gmd,http://www.isotc211.org/2005/gmd}}'::text[]), '-'::text);

ALTER TABLE records_status
  OWNER TO geonetwork;
COMMENT ON VIEW records_status
  IS 'View includes all records,  showing:
- ID
- Current status (or blank)
- Date last changed
- Change message
- ORL
- Title';
