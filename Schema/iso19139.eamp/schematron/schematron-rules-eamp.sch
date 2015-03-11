<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<sch:schema xmlns:sch="http://purl.oclc.org/dsdl/schematron" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

    <!-- EAMP v1.1 SCHEMATRON-->

    <sch:title xmlns="http://www.w3.org/2001/XMLSchema">Schematron validation for ISO 19115(19139) Environment Agency Metadata Profile v1.1</sch:title>

    <sch:ns prefix="gml" uri="http://www.opengis.net/gml"/>
    <sch:ns prefix="gmd" uri="http://www.isotc211.org/2005/gmd"/>
    <sch:ns prefix="srv" uri="http://www.isotc211.org/2005/srv"/>
    <sch:ns prefix="gco" uri="http://www.isotc211.org/2005/gco"/>
    <sch:ns prefix="eamp" uri="http://environment.data.gov.uk/eamp"/>
    <sch:ns prefix="geonet" uri="http://www.fao.org/geonetwork"/>
    <sch:ns prefix="xlink" uri="http://www.w3.org/1999/xlink"/>

    <sch:let name="langCodeList">eng;cym;gle;gla;cor;sco</sch:let>

    <!--METADATA STANDARD-->
    <sch:pattern>
        <sch:title>$loc/strings/UK999</sch:title>
        <sch:rule context="//gmd:MD_Metadata">

            <sch:report test="true()"><sch:value-of select="$loc/strings/UK999.report.name"/> <sch:value-of select="gmd:metadataStandardName/gco:CharacterString"/></sch:report>
            <sch:assert test="gmd:metadataStandardName/gco:CharacterString and gmd:metadataStandardName/gco:CharacterString = 'Environment Agency Metadata Profile'">$loc/strings/UK999.alert.name</sch:assert>

            <sch:report test="true()"><sch:value-of select="$loc/strings/UK999.report.version"/><sch:value-of select="gmd:metadataStandardVersion/gco:CharacterString"/></sch:report>
            <sch:assert test="gmd:metadataStandardVersion/gco:CharacterString and gmd:metadataStandardVersion/gco:CharacterString= '1.1'">$loc/strings/UK999.alert.version</sch:assert>
        </sch:rule>
    </sch:pattern>

    <!--DISTRIBUTION FORMAT -->
    <sch:pattern>
        <sch:title>DistributionFormat</sch:title>
    </sch:pattern>

    <sch:pattern>
        <sch:title>EAMP-mi1-NotNillable</sch:title>
        <sch:rule context="/*[1]/gmd:distributionInfo[1]/*[1]/gmd:MD_Distribution/gmd:distributionFormat[1]">
            <sch:assert test="string-length(.)>0">At least one DistributionFormat must be provided</sch:assert>
            <sch:report test="true()">At least one DistributionFormat has been provided</sch:report>
        </sch:rule>
    </sch:pattern>

    <!--AfA NUMBER -->
    <sch:pattern>
        <sch:title>AfANumber</sch:title>
    </sch:pattern>

    <sch:pattern>
        <sch:title>EAMP-mi2-NotNillable</sch:title>
        <sch:rule context="/*[1]/gmd:resourceConstraints/eamp:afa[1]/eamp:EA_Afa[1]/eamp_afaNumber">

            <sch:assert test="((../eamp@afaStatus/eamp:EA_AfaStatus = 'notAfaToBeAssessedWithGuidance' or
            ../eamp@afaStatus/eamp:EA_AfaStatus = 'afaPubSchemeAndInfoForReuseReg' or
            ../eamp@afaStatus/eamp:EA_AfaStatus = 'afaPublicRegister' or
            ../eamp@afaStatus/eamp:EA_AfaStatus = 'afaPublicationScheme' or
            ../eamp@afaStatus/eamp:EA_AfaStatus = 'afaInformationRequestsOnly') and
            string-length(.)=0)">AfANumber is mandatory for records with status notAfaToBeAssessedWithGuidance, afaPubSchemeAndInfoForReuseReg, afaPublicRegister, afaPublicationScheme or afaInformationRequestsOnly</sch:assert>
            <sch:report test="true()">AfANumber is applicable and has been provided</sch:report>
        </sch:rule>
    </sch:pattern>

    <sch:pattern>
        <sch:title>EAMP-mi2-Nillable</sch:title>
        <sch:rule context="/*[1]/gmd:resourceConstraints/eamp:afa[1]/eamp:EA_Afa[1]/eamp_afaNumber">

            <sch:assert test="((../eamp@afaStatus/eamp:EA_AfaStatus = 'notAfaToBeAssessed or 
            ../eamp@afaStatus/eamp:EA_AfaStatus = 'notApplicableThirdpartyDataset') and
            string-length(.)>0)">AfANumber is not applicable for records with status notAfaToBeAssessed or notApplicableThirdpartyDataset</sch:assert>
            <sch:report test="true()">AfANumber is not applicable and has not been provided</sch:report>
        </sch:rule>
    </sch:pattern>

    <!-- POINT OF CONTACT -->

    <sch:pattern>
        <sch:title>PointOfContact</sch:title>
    </sch:pattern>

    <sch:pattern>
        <sch:title>EAMP-mi3-GeneralContact</sch:title>
        <sch:rule context="/*[1]/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:pointOfContact/gmd:CI_ResponsibleParty">
            <sch:assert test="count(gmd:individualName)!=1 and count(gmd:organisationName)!=1 and count(gmd:positionName) !=1 and count(gmd:role) !=1">Each Point of Contact must contain one Individual Name, one Position Name, one Organisation Name and 1 role</sch:assert>
            <sch:report test="true()">Exactly one Individual Name, one Position Name, one Organisation Name and 1 role have been provided for each Point of Contact</sch:report>
        </sch:rule>
    <sch:pattern>

    <sch:pattern>
        <sch:title>EAMP-mi4-Custodian</sch:title>
         <sch:rule context="/*[1]/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:pointOfContact/">
         <sch:assert test="((gmd:CI_ResponsibleParty/gmd:role='Custodian') and count(.)=2)">Each dataset must have exactly two points of contact with the role "Custodian"</sch:assert>
         <sch:report test="true()">Exactly two points of contact with the role "Custodian" have been supplied</sch:report>
         </sch:rule>
     </sch:pattern>


     <sch:pattern>
         <sch:title>EAMP-mi5-owner</sch:title>
          <sch:rule context="/*[1]/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:pointOfContact/">
          <sch:assert test="((gmd:CI_ResponsibleParty/gmd:role='Owner') and count(.)=1)">Each dataset must have exactly one point of contact with the role "Owner"</sch:assert>
          <sch:report test="true()">Exactly one point of contact with the role "Owner" has been supplied</sch:report>
          </sch:rule>
      </sch:pattern>

      <sch:pattern>
         <sch:title>EAMP-mi6-pointofcontact</sch:title>
          <sch:rule context="/*[1]/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:pointOfContact/">
          <sch:assert test="((gmd:CI_ResponsibleParty/gmd:role='Point of Contact') and count(.)=1)">Each dataset must have exactly one point of contact with the role "Point of Contact"</sch:assert>
          <sch:report test="true()">Exactly one point of contact with the role "Point of Contact" has been supplied</sch:report>
          </sch:rule>
      </sch:pattern>

</sch:schema>
