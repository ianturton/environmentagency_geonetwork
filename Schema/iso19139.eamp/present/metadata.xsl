<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl ="http://www.w3.org/1999/XSL/Transform"
                xmlns:gmd="http://www.isotc211.org/2005/gmd"
                xmlns:gts="http://www.isotc211.org/2005/gts"
                xmlns:gco="http://www.isotc211.org/2005/gco"
                xmlns:gmx="http://www.isotc211.org/2005/gmx"
                xmlns:srv="http://www.isotc211.org/2005/srv"
                xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
                xmlns:gml="http://www.opengis.net/gml"
                xmlns:eamp="http://environment.data.gov.uk/eamp"
                xmlns:xlink="http://www.w3.org/1999/xlink"
                xmlns:geonet="http://www.fao.org/geonetwork"
                xmlns:exslt="http://exslt.org/common"
                exclude-result-prefixes="#all">

    <xsl:import href="../../iso19139/present/metadata.xsl"/>

	<!-- main template - the way into processing EAMP -->
	<xsl:template name="metadata-iso19139.eamp">
		<xsl:param name="schema"/>
		<xsl:param name="edit" select="false()"/>
		<xsl:param name="embedded"/>

<!--<xsl:message> GEMINI metadata.xsl NODE <xsl:value-of select="local-name(.)"/></xsl:message>-->

        <!-- Let the original ISO19139 templates do the work -->
		<xsl:apply-templates mode="iso19139" select="." >
			<xsl:with-param name="schema" select="$schema"/>
			<xsl:with-param name="edit"   select="$edit"/>
			<xsl:with-param name="embedded" select="$embedded" />
		</xsl:apply-templates>
	</xsl:template>

    <xsl:template name="iso19139.eampCompleteTab">
        <xsl:param name="tabLink"/>
        <xsl:param name="schema"/>

        <!-- Let the original ISO19139 template do the work -->
        <xsl:call-template name="iso19139CompleteTab">
            <xsl:with-param name="tabLink" select="$tabLink"/>
            <xsl:with-param name="schema" select="$schema"/>
        </xsl:call-template>
    </xsl:template>

    <!-- iso19139 one is empty as well -->
    <xsl:template name="iso19139.eamp-javascript"/>

    <xsl:template name="iso19139.eampBrief">
       <!-- Let the original ISO19139 templates do the work -->
        <xsl:call-template name="iso19139Brief"/>
    </xsl:template>


    <!-- Make the standardname and standardversion read only-->

    <xsl:template mode="iso19139" match="gmd:metadataStandardName[gco:CharacterString]|gmd:metadataStandardVersion[gco:CharacterString]" priority="101">
        <xsl:param name="schema"/>
        <xsl:param name="edit" select="false()"/>

        <xsl:call-template name="iso19139String">
            <xsl:with-param name="schema" select="$schema"/>
            <xsl:with-param name="edit"   select="false()"/>
        </xsl:call-template>
    </xsl:template>

    <!-- Override with eamp where required -->

    <xsl:template mode="iso19139" match="eamp:*[gco:CharacterString|gco:Integer]" priority="150">
        <xsl:param name="schema"/>
         <xsl:param name="edit" select="false()"/>

        <xsl:call-template name="iso19139String">
            <xsl:with-param name="schema" select="$schema"/>
            <xsl:with-param name="edit"   select="$edit"/>
        </xsl:call-template>
    </xsl:template>


	

    <!-- Restrict the language list -->

  <xsl:template mode="iso19139" match="//gmd:language[gco:CharacterString]" priority="200">
    <xsl:param name="schema"/>
    <xsl:param name="edit"/>

    <xsl:apply-templates mode="simpleElement" select=".">
      <xsl:with-param name="schema" select="$schema"/>
      <xsl:with-param name="edit"   select="$edit"/>
      <xsl:with-param name="text">
        <xsl:call-template name="iso19139GetIsoLanguage_eamp">
          <xsl:with-param name="schema" select="$schema"/>
          <xsl:with-param name="edit"   select="$edit"/>
          <xsl:with-param name="value" select="gco:CharacterString"/>
          <xsl:with-param name="ref" select="concat('_', gco:CharacterString/geonet:element/@ref)"/>
        </xsl:call-template>
      </xsl:with-param>
    </xsl:apply-templates>
  </xsl:template>


  <xsl:template mode="iso19139" match="gmd:LanguageCode" priority="200">
    <xsl:param name="schema"/>
    <xsl:param name="edit"/>

    <xsl:call-template name="iso19139GetIsoLanguage_eamp">
      <xsl:with-param name="value" select="string(@codeListValue)"/>
      <xsl:with-param name="ref" select="concat('_', geonet:element/@ref, '_codeListValue')"/>
      <xsl:with-param name="schema" select="$schema"/>
      <xsl:with-param name="edit"   select="$edit"/>
    </xsl:call-template>
  </xsl:template>

  <!-- ===================================================================== -->
  <!-- these elements should be boxed -->
  <!-- ===================================================================== -->

  <xsl:template mode="iso19139" match="gmd:identificationInfo|gmd:distributionInfo|gmd:descriptiveKeywords|gmd:spatialRepresentationInfo|gmd:pointOfContact|gmd:dataQualityInfo|gmd:referenceSystemInfo|gmd:equivalentScale|gmd:projection|gmd:ellipsoid|gmd:extent[name(..)!='gmd:EX_TemporalExtent']|gmd:geographicBox|gmd:EX_TemporalExtent|gmd:MD_Distributor|srv:containsOperations|srv:SV_CoupledResource|gmd:resourceConstraints" priority="300">
    <xsl:param name="schema"/>
    <xsl:param name="edit"/>
    
    <xsl:apply-templates mode="complexElement" select=".">
      <xsl:with-param name="schema" select="$schema"/>
      <xsl:with-param name="edit"   select="$edit"/>
    </xsl:apply-templates>
  </xsl:template>

  <xsl:template name="iso19139GetIsoLanguage_eamp">
    <xsl:param name="schema"/>
    <xsl:param name="edit"/>
    <xsl:param name="value"/>
      <xsl:param name="ref"/>

    <xsl:variable name="lang"  select="/root/gui/language"/>

    <xsl:choose>
      <xsl:when test="$edit=true()">
        <select class="md" name="{$ref}" size="1">
          <option name=""/>

          <xsl:for-each select="/root/gui/isoLang/record">
            <xsl:sort select="label/child::*[name() = $lang]"/>

            <xsl:if test="code='eng' or code='cym' or code='gle' or code='gla' or code='cor' or code='sco' or code=$value">
                 <option value="{code}">
                  <xsl:if test="code = $value">
                    <xsl:attribute name="selected"/>
                  </xsl:if>
                  <xsl:value-of select="label/child::*[name() = $lang]"/>
                </option>

            </xsl:if>
          </xsl:for-each>
        </select>
      </xsl:when>

      <xsl:otherwise>
        <xsl:value-of select="/root/gui/isoLang/record[code=$value]/label/child::*[name() = $lang]"/>

        <!-- In view mode display other languages from gmd:locale of gmd:MD_Metadata element -->
        <xsl:if test="../gmd:locale or ../../gmd:locale">
          <xsl:text> (</xsl:text><xsl:value-of select="string(/root/gui/schemas/iso19139/labels/element[@name='gmd:locale' and not(@context)]/label)"/>
          <xsl:text>:</xsl:text>
          <xsl:for-each select="../gmd:locale|../../gmd:locale">
            <xsl:variable name="c" select="gmd:PT_Locale/gmd:languageCode/gmd:LanguageCode/@codeListValue"/>
            <xsl:value-of select="/root/gui/isoLang/record[code=$c]/label/child::*[name() = $lang]"/>
            <xsl:if test="position()!=last()">, </xsl:if>
          </xsl:for-each><xsl:text>)</xsl:text>
        </xsl:if>

      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

<!-- ============================================================================= -->
  <!-- utilities -->
  <!-- ============================================================================= -->
  
    
  <!-- additional handling of eamp extension elements -->
  <xsl:template mode="iso19139.eamp" match="eamp:EA_Constraints">
    <xsl:param name="schema"/>
    <xsl:param name="edit"/>
    <xsl:apply-templates mode="complexElement" select=".">
      <xsl:with-param name="schema" select="$schema"/>
      <xsl:with-param name="edit" select="$edit"/>
    </xsl:apply-templates>
  </xsl:template> 


  <!-- adding picker for data format thesaurus -->
  <!--<xsl:template mode="addXMLFragment" match="gmd:distributionFormat|geonet:child[@name='distributionFormat' and @prefix='gmd']" priority="300">
    <xsl:text>showKeywordSelectionPanel</xsl:text>
  </xsl:template> -->

</xsl:stylesheet>
