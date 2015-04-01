<?xml version="1.0" encoding="utf-8" standalone="yes"?>
<!--	Trasformation for EAMP extended metadata to Gemini, anonymizing and removing information on the way out of GeoNetwork. 
		Author:		Environment Agency
		Date:		2015 02 20
		Version:	1
-->

<xsl:stylesheet version="1.0" exclude-result-prefixes="eamp geonet" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:gmd="http://www.isotc211.org/2005/gmd" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:eamp="http://environment.data.gov.uk/eamp" xmlns:gco="http://www.isotc211.org/2005/gco" xmlns:gml="http://www.opengis.net/gml/3.2" xmlns:geonet="http://www.fao.org/geonetwork" xmlns:srv="http://www.isotc211.org/2005/srv" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
	
	<xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes"/>

	<!-- Remove geonet's own stuff -->
	<xsl:template match="geonet:info" priority="1000"/>
	
	<!-- from iso19139 one to remove "root" element. Not quite right, but it works-->
	<xsl:template match="/root">
		<xsl:apply-templates select="gmd:MD_Metadata"/>
	</xsl:template>
	
	<!-- this does some stuff -->	
	<xsl:template match="/gmd:MD_Metadata" priority="400">
		<gmd:MD_Metadata xmlns:gmd="http://www.isotc211.org/2005/gmd" 
		xmlns:gco="http://www.isotc211.org/2005/gco" 
		xmlns:gml="http://www.opengis.net/gml/3.2" 
		xmlns:srv="http://www.isotc211.org/2005/srv" 
		xmlns:xlink="http://www.w3.org/1999/xlink"
		xmlns:gmx="http://www.isotc211.org/2005/gmx"
		xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
		xsi:schemaLocation="http://www.isotc211.org/2005/gmx http://eden.ign.fr/xsd/isotc211/isofull/20090316/gmx/gmx.xsd">		
		<xsl:apply-templates select="@* | node()"/>
		</gmd:MD_Metadata>
	</xsl:template>
		
	<!-- Add any nodes here that are not to be copied over. Separate with '|', a pipe. If node is a parent, children will not be copied either. -->
	<xsl:template match="gmd:pointOfContact"/>
	
	<!-- Remove AfA element -->
	<xsl:template match="*/gmd:resourceConstraints">
		<xsl:if test="not(./eamp:EA_Constraints)">
			<gmd:resourceConstraints>
				<xsl:apply-templates select="@* | node()"/>
			</gmd:resourceConstraints>
		</xsl:if>
	</xsl:template>

	<!-- Add generic Responsible Organisation contact after Abstract. All current ones are obliterated in the empty template above -->
	<xsl:template match="*/gmd:abstract">
	  <gmd:abstract>
		<xsl:apply-templates select="@* | node()"/>
	  </gmd:abstract>
	  <gmd:pointOfContact>
		<gmd:CI_ResponsibleParty>
		  <gmd:organisationName>
			<gco:CharacterString>Environment Agency</gco:CharacterString>
		  </gmd:organisationName>
		  <gmd:contactInfo>
			<gmd:CI_Contact>
			  <gmd:address>
				<gmd:CI_Address>
				  <gmd:electronicMailAddress>
					<gco:CharacterString>metadata@environment-agency.gov.uk</gco:CharacterString>
				  </gmd:electronicMailAddress>
				</gmd:CI_Address>
			  </gmd:address>
			  <gmd:onlineResource>
				<gmd:CI_OnlineResource>
				  <gmd:linkage>
					  <gmd:URL>https://www.gov.uk/government/organisations/environment-agency</gmd:URL>
				  </gmd:linkage>
				  <gmd:description>
					<gco:CharacterString>Environment Agency Website</gco:CharacterString>
				  </gmd:description>
				</gmd:CI_OnlineResource>
			  </gmd:onlineResource>
			</gmd:CI_Contact>
		  </gmd:contactInfo>
		  <gmd:role>
			<gmd:CI_RoleCode codeList="http://www.isotc211.org/2005/resources/Codelist/gmxCodelists.xml#CI_RoleCode" codeListValue="pointOfContact" codeSpace="ISOTC211/19115">pointOfContact</gmd:CI_RoleCode>
		  </gmd:role>
		</gmd:CI_ResponsibleParty>
	  </gmd:pointOfContact>
	</xsl:template>
	
	<!-- replace with generic Metadata Contact -->
	<xsl:template match="*/gmd:contact">
	  <gmd:contact>
		<gmd:CI_ResponsibleParty>
		  <gmd:organisationName>
			<gco:CharacterString>Environment Agency</gco:CharacterString>
		  </gmd:organisationName>
		  <gmd:contactInfo>
			<gmd:CI_Contact>
			  <gmd:address>
				<gmd:CI_Address>
				  <gmd:electronicMailAddress>
					<gco:CharacterString>metadata@environment-agency.gov.uk</gco:CharacterString>
				  </gmd:electronicMailAddress>
				</gmd:CI_Address>
			  </gmd:address>
			</gmd:CI_Contact>
		  </gmd:contactInfo>
		  <gmd:role>
			<gmd:CI_RoleCode codeList="http://www.isotc211.org/2005/resources/Codelist/gmxCodelists.xml#CI_RoleCode" codeListValue="pointOfContact" codeSpace="ISOTC211/19115">pointOfContact</gmd:CI_RoleCode>
		  </gmd:role>
		</gmd:CI_ResponsibleParty>
	  </gmd:contact>
	</xsl:template>
	
	<!-- Removes any reference to DSTR IDs -->
	<xsl:template match="*/gmd:identifier">
		<xsl:variable name="URI2"><xsl:value-of select="./gmd:identifier/gmd:MD_Identifier/gmd:code/gco:CharacterString"/></xsl:variable>	
		<xsl:if test="not(contains($URI2,'DSTR'))">
			<gmd:identifier>
				<xsl:apply-templates select="@* | node()"/>
			</gmd:identifier>
		</xsl:if>
	</xsl:template>
	
	<!-- Remove excess bits in the data format element if there -->
	<xsl:template match="*/gmd:distributionFormat">
		<xsl:variable name="format"><xsl:value-of select="./gmd:MD_Format/gmd:name/gco:CharacterString"/></xsl:variable>
		<xsl:variable name="version"><xsl:value-of select="./gmd:MD_Format/gmd:version/gco:CharacterString"/></xsl:variable>
		  <xsl:if test="contains($format,'|')">
			  <gmd:distributionFormat>
				<gmd:MD_Format>
				  <gmd:name>
					<gco:CharacterString><xsl:value-of select="normalize-space(substring-after($format, '|'))"/></gco:CharacterString>
				  </gmd:name>
				  <gmd:version>
					<gco:CharacterString><xsl:value-of select="$version"/></gco:CharacterString>
				  </gmd:version>
				</gmd:MD_Format>
			  </gmd:distributionFormat>
			</xsl:if>
			<xsl:if test="not(contains($format,'|'))">
				<gmd:distributionFormat>
					<xsl:apply-templates select="@* | node()"/>
				</gmd:distributionFormat>
			</xsl:if>
	</xsl:template>
	
	<!-- Remove internal Resource Locators -->
	<xsl:template match="*/gmd:transferOptions">
		<gmd:transferOptions>
            <gmd:MD_DigitalTransferOptions>
				<xsl:for-each select="./gmd:MD_DigitalTransferOptions/gmd:onLine">
					<xsl:variable name="URL"><xsl:value-of select="./gmd:CI_OnlineResource/gmd:linkage/gmd:URL"/></xsl:variable>
					<xsl:variable name="protocol"><xsl:value-of select="./gmd:CI_OnlineResource/gmd:protocol/gco:CharacterString"/></xsl:variable>
					<xsl:if test="contains($URL,'http')">
						<xsl:if test="not(contains($URL,'intranet.ea.gov'))">
							<gmd:onLine>
								<gmd:CI_OnlineResource>
									<gmd:linkage>
										<gmd:URL><xsl:value-of select="$URL"/></gmd:URL>
									</gmd:linkage>
									<gmd:protocol>
										<gco:CharacterString><xsl:value-of select="$protocol"/></gco:CharacterString>
									</gmd:protocol>	  
								</gmd:CI_OnlineResource>
							</gmd:onLine>
						</xsl:if>  
					</xsl:if>
				</xsl:for-each>	
			</gmd:MD_DigitalTransferOptions>
		</gmd:transferOptions>
	</xsl:template>
	
	<!-- Change standard from EAMP to Gemini -->
	<xsl:template match="*/gmd:metadataStandardName">
		<gmd:metadataStandardName>
			<gco:CharacterString>Gemini</gco:CharacterString>
		</gmd:metadataStandardName>
	</xsl:template>
	<xsl:template match="*/gmd:metadataStandardVersion">
		<gmd:metadataStandardVersion>
			<gco:CharacterString>2.2</gco:CharacterString>
		</gmd:metadataStandardVersion>
	</xsl:template>
	
	<!-- copy All -->
	<xsl:template match="@* | node()">
		<xsl:copy>
			<xsl:apply-templates select="@* | node()"/>
		</xsl:copy>
	</xsl:template>
	
</xsl:stylesheet>
