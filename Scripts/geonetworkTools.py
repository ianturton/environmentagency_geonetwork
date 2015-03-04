
"""
Modified:
John Tate
Environment Agency
25/02/2015
"""

# Library Imports
import urllib
import urllib2
import cookielib
from lxml import etree
import sys

# GeoNetwork constants
gn_username = "yourusername"
gn_password = "yourpassword"
gn_baseURL = "http://URL:8080/geonetwork"
#gn_cswURI = gn_baseURL + "/srv/en/csw"
loginservice='j_spring_security_check'


def gn_authenticate():
   ## Copyright (c) 2014 Astun Technology - for gn_authenticate
   handler=urllib2.HTTPHandler()
   #Proxy stuff if needed
   proxy = urllib2.ProxyHandler({})

   #Login and get a cookie to use in the next call to the server
   data = urllib.urlencode({'username':gn_username,'password':gn_password})
   request = urllib2.Request('%s/%s'%(gn_baseURL, loginservice), data)
   cookie = urllib2.HTTPCookieProcessor(cookielib.LWPCookieJar())
   opener = urllib2.build_opener(handler, proxy, cookie)
   try:
       result=opener.open(request)
       assert ('failure=true' not in result.url)
       print "logged on"
       return opener
      
   except AssertionError:
       raise RuntimeError('Login failed!')


def gn_updatedate(opener, table):

   xmlurl = gn_baseURL + "/srv/eng"
   url_search = xmlurl + "/xml.search"
   url_get = xmlurl + "/xml.metadata.get"
   url_update = xmlurl + "/xml.metadata.update"
   header_xml = {"Mime-type": "application/xml"}
   table = str(table)

   openFile = open(table,'r')
   for line in openFile:
      line = line.strip().split(",")

      # Search for record using title
      searchparam = urllib.urlencode({"any": line[0]})
      request = urllib2.Request(url_search, searchparam, header_xml)
      response = opener.open(request)
      xml_response = response.read()
      
      # Get uuid from response
      xmldoc = etree.fromstring(xml_response)
      id = xmldoc.find('.//{http://www.fao.org/geonetwork}info/id').text
      
      # Get record using uuid
      getparam = urllib.urlencode({"id": id})
      request = urllib2.Request(url_get, getparam, header_xml)
      response = opener.open(request)
      xml_response = response.read()


      # Change the XML - update the dates
      xmldoc = etree.fromstring(xml_response)
      xslt_root = etree.XML('''\
         <xsl:stylesheet version="1.0" exclude-result-prefixes="eamp" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
         xmlns:gmd="http://www.isotc211.org/2005/gmd" xmlns:xlink="http://www.w3.org/1999/xlink"
         xmlns:eamp="http://environment.data.gov.uk/eamp" xmlns:gco="http://www.isotc211.org/2005/gco"
         xmlns:gml="http://www.opengis.net/gml/3.2" xmlns:srv="http://www.isotc211.org/2005/srv"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
         <xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes" omit-xml-declaration="yes"/>

         <xsl:template match="*/gmd:dateStamp/gco:Date">
            <gco:Date>''' + line[1] + '''</gco:Date>
         </xsl:template>
         <xsl:template match="*/gmd:dateStamp/gco:DateTime">
            <gco:Date>''' + line[1] + '''</gco:Date>
         </xsl:template>
         
         <xsl:template match="*/gmd:CI_Citation/gmd:date">                  
            <xsl:for-each select=".">
               <xsl:variable name="datetype">
                  <xsl:value-of select="./gmd:CI_Date/gmd:dateType/gmd:CI_DateTypeCode/@codeListValue"/>
               </xsl:variable>
               <xsl:if test="contains($datetype, 'revision')">
                  <gmd:date>
                     <gmd:CI_Date>
                        <gmd:date>
                           <gco:Date>''' + line[1] + '''</gco:Date>
                        </gmd:date>
                        <gmd:dateType>
                           <gmd:CI_DateTypeCode codeList="http://standards.iso.org/ittf/PubliclyAvailableStandards/ISO_19139_Schemas/resources/codelist/ML_gmxCodelists.xml#CI_DateTypeCode" codeListValue="revision"/>
                        </gmd:dateType>
                     </gmd:CI_Date>
                  </gmd:date>
               </xsl:if>
               <xsl:if test="not(contains($datetype, 'revision'))">
                  <gmd:date><xsl:apply-templates select="@* | node()"/></gmd:date>
               </xsl:if>
            </xsl:for-each>
         </xsl:template>
         
         <xsl:template match="@* | node()">
            <xsl:copy><xsl:apply-templates select="@* | node()"/></xsl:copy>
         </xsl:template>
         
         </xsl:stylesheet>''')
      
      transform = etree.XSLT(xslt_root)

      newXML = transform(xmldoc)
      #print str(newXML)
      newXML2 = "![CDATA[" + etree.tostring(newXML) + "]]"
      #newXML2 = "<![CDATA[" + etree.tostring(newXML) + "]]>"
      

      updateparam = urllib.urlencode({"id": id, "version": "1", "minor": "true", "data": newXML2})
      #print updateparam
      
      try:
         request = urllib2.Request(url_update, updateparam, header_xml)
         print request.get_data()
         response = opener.open(request)
         xml_response = response.read()
      except urllib2.HTTPError, error:
         print error.read()
      
      #print xml_response



   openFile.close()

