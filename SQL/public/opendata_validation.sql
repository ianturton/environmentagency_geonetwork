-- View: opendata_validation

-- DROP VIEW opendata_validation;

-- View to pull out all records with keywords OpenData or NotOpen (all the records to be published on data.gov.uk) and show whether they have been through the validation process

CREATE OR REPLACE VIEW opendata_validation AS 

SELECT distinct uuid, title, beenthroughvalidation from (select 
metadata_xml.uuid,
    ('"'::text || array_to_string(xpath('/gmd:MD_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:citation/gmd:CI_Citation/gmd:title/gco:CharacterString/text()'::text, metadata_xml.data_xml, '{{gco,http://www.isotc211.org/2005/gco},{gmd,http://www.isotc211.org/2005/gmd}}'::text[]), '-'::text)) || '"'::text AS title,
    validation.valdate,
case when 
    validation.valdate != '' then 'y'
    else 'n' end as beenthroughvalidation
   FROM metadatastatus,
    metadata_xml
     LEFT JOIN validation ON validation.metadataid = metadata_xml.id
  WHERE metadatastatus.metadataid = metadata_xml.id 
    AND ('OpenData' = ANY(xpath('/gmd:MD_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:descriptiveKeywords/gmd:MD_Keywords/gmd:keyword/gco:CharacterString/text()'::text, metadata_xml.data_xml, '{{gco,http://www.isotc211.org/2005/gco},{gmd,http://www.isotc211.org/2005/gmd}}')::text[]) or 'NotOpen' = ANY(xpath('/gmd:MD_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:descriptiveKeywords/gmd:MD_Keywords/gmd:keyword/gco:CharacterString/text()'::text, metadata_xml.data_xml, '{{gco,http://www.isotc211.org/2005/gco},{gmd,http://www.isotc211.org/2005/gmd}}')::text[]))) as foo  group by uuid, title,beenthroughvalidation   order by beenthroughvalidation asc, title asc;


ALTER TABLE opendata_validation
  OWNER TO geonetwork;
