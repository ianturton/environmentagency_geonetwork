<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<sch:schema xmlns:sch="http://purl.oclc.org/dsdl/schematron" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

    <!-- EAMP v1.1 SCHEMATRON-->

    <sch:title xmlns="http://www.w3.org/2001/XMLSchema">Schematron validation for ISO 19115(19139) Environment Agency Metadata Profile v1.1</sch:title>

    <sch:ns prefix="gml" uri="http://www.opengis.net/gml"/>
    <sch:ns prefix="gmd" uri="http://www.isotc211.org/2005/gmd"/>
    <sch:ns prefix="srv" uri="http://www.isotc211.org/2005/srv"/>
    <sch:ns prefix="gco" uri="http://www.isotc211.org/2005/gco"/>
    <sch:ns prefix="eamp" uri="http://environment.data.gov.EAMP/eamp"/>
    <sch:ns prefix="geonet" uri="http://www.fao.org/geonetwork"/>
    <sch:ns prefix="xlink" uri="http://www.w3.org/1999/xlink"/>


    <!--METADATA STANDARD
    <sch:pattern>
        <sch:title>$loc/strings/EAMP999</sch:title>
        <sch:rule context="//gmd:MD_Metadata">

            <sch:report test="true()"><sch:value-of select="$loc/strings/EAMP999.report.name"/> <sch:value-of select="gmd:metadataStandardName/gco:CharacterString"/></sch:report>
            <sch:assert test="gmd:metadataStandardName/gco:CharacterString and gmd:metadataStandardName/gco:CharacterString = 'Environment Agency Metadata Profile'">$loc/strings/EAMP999.alert.name</sch:assert>

            <sch:report test="true()"><sch:value-of select="$loc/strings/EAMP999.report.version"/><sch:value-of select="gmd:metadataStandardVersion/gco:CharacterString"/></sch:report>
            <sch:assert test="gmd:metadataStandardVersion/gco:CharacterString and gmd:metadataStandardVersion/gco:CharacterString= '1.1'">$loc/strings/EAMP999.alert.version</sch:assert>
        </sch:rule>
    </sch:pattern>-->

    <!--DISTRIBUTION FORMAT -->
    <sch:pattern>
        <sch:title>DistributionFormat</sch:title>
    </sch:pattern>

    <sch:pattern>
        <sch:title>EAMP-mi1-DistributionFormat</sch:title>
        <sch:rule context="//gmd:distributionInfo/gmd:MD_Distribution/gmd:distributionFormat">
            <sch:assert test="string-length(.)>0">$loc/strings/EAMP100.alert.noformat</sch:assert>
        </sch:rule>
    </sch:pattern>

    <!--AfA NUMBER -->
    <sch:pattern>
        <sch:title>AfANumber</sch:title>
    </sch:pattern>

    <sch:pattern>
        <sch:title>EAMP-mi2-AfANumber</sch:title>
        <sch:rule context="//*[eamp:EA_Afa]">
            <sch:assert test="((//eamp:EA_AfaStatus = 'notAfaToBeAssessedWithGuidance' or
            //eamp:EA_AfaStatus = 'afaPubSchemeAndInfoForReuseReg' or
            //eamp:EA_AfaStatus = 'afaPublicRegister' or
            //eamp:EA_AfaStatus = 'afaPublicationScheme' or
            //eamp:EA_AfaStatus = 'afaInformationRequestsOnly') and
            string-length(//*[eamp:afaNumber]//gco:Decimal)!=0) or ((
            //eamp:EA_AfaStatus = 'notAfaToBeAssessed' or 
            //eamp:EA_AfaStatus = 'notApplicableThirdpartyDataset') 
            and string-length(//*[eamp:afaNumber]//gco:Decimal)=0)">$loc/strings/EAMP200.alert.number</sch:assert>
    </sch:rule>
    </sch:pattern>
    
 
    <!-- POINT OF CONTACT -->

    <sch:pattern>
        <sch:title>PointOfContact</sch:title>
    </sch:pattern>

    <sch:pattern>
        <sch:title>EAMP-mi3-GeneralContact</sch:title>
        <sch:rule context="/gmd:MD_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:pointOfContact/gmd:CI_ResponsibleParty">
            <sch:assert test="count(./gmd:individualName)=1">$loc/strings/EAMP300.alert.name</sch:assert>
            <sch:assert test="count(./gmd:organisationName)=1">$loc/strings/EAMP300.alert.org</sch:assert>
            <sch:assert test="count(./gmd:positionName)=1">$loc/strings/EAMP300.alert.position</sch:assert>
            <sch:assert test="count(./gmd:role)=1">$loc/strings/EAMP300.alert.role</sch:assert>
     </sch:rule>
    </sch:pattern>

    <sch:pattern>
        <sch:title>EAMP-mi4-Custodian</sch:title>
        <sch:rule context="/gmd:MD_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification">
            <sch:assert test="count(//gmd:pointOfContact/gmd:CI_ResponsibleParty/gmd:role/gmd:CI_RoleCode[@codeListValue='custodian'])=2">$loc/strings/EAMP300.alert.custodian</sch:assert>
            <sch:assert test="count(//gmd:pointOfContact/gmd:CI_ResponsibleParty/gmd:role/gmd:CI_RoleCode[@codeListValue='owner'])=1">$loc/strings/EAMP300.alert.owner</sch:assert>
            <sch:assert test="count(//gmd:pointOfContact/gmd:CI_ResponsibleParty/gmd:role/gmd:CI_RoleCode[@codeListValue='pointOfContact'])=1">$loc/strings/EAMP300.alert.poc</sch:assert>
         </sch:rule>
     </sch:pattern>

</sch:schema>
