<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet   xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0" 
						xmlns:gco="http://www.isotc211.org/2005/gco"
						xmlns:gmd="http://www.isotc211.org/2005/gmd"
						xmlns:eamp="http://environment.data.gov.uk/eamp">

	<xsl:template match="eamp:EA_Metadata|gmd:MD_Metadata|*[@gco:isoType='gmd:MD_Metadata']">
		 <uuid><xsl:value-of select="gmd:fileIdentifier/gco:CharacterString"/></uuid>
	</xsl:template>

</xsl:stylesheet>
