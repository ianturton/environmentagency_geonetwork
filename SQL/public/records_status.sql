select metadata_xml.id, metadata_xml.uuid, 
(array_to_string(xpath('/gmd:MD_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:citation/gmd:CI_Citation/gmd:title/gco:CharacterString/text()'::text, metadata_xml.data_xml, '{{gco,http://www.isotc211.org/2005/gco},{gmd,http://www.isotc211.org/2005/gmd}}'::text[]), '-'::text)) ::text AS title, 
name as status, 
userid, 
foo.changedate, 
changemessage from 
(SELECT DISTINCT ON (metadataid) * FROM metadatastatus ORDER BY metadataid, changedate desc) foo 
left join statusvalues on foo.statusid= statusvalues.id
right join  metadata_xml on foo.metadataid = metadata_xml.id
order by metadata_xml.id
