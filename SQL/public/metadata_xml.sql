-- View: metadata_xml

-- DROP VIEW metadata_xml;

CREATE OR REPLACE VIEW metadata_xml AS 
 SELECT metadata.id,
    metadata.uuid,
    metadata.schemaid,
    metadata.istemplate,
    metadata.isharvested,
    metadata.createdate,
    metadata.changedate,
    XMLPARSE(DOCUMENT metadata.data STRIP WHITESPACE) AS data_xml,
    metadata.data,
    metadata.source,
    metadata.title,
    metadata.root,
    metadata.harvestuuid,
    metadata.owner,
    metadata.doctype,
    metadata.groupowner,
    metadata.harvesturi,
    metadata.rating,
    metadata.popularity,
    metadata.displayorder
   FROM metadata;

ALTER TABLE metadata_xml
  OWNER TO geonetwork;
