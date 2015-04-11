
"""
Login code from Astun technology:
Copyright (c) 2014 Astun Technology

Modified and added 'date update' and 'contact update' scripts:
John Tate
07/04/2015
Copyright (c) 2015 Environment Agency

 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:

 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.

"""

# Library Imports
import urllib
import urllib2
import cookielib
from lxml import etree
import os
import sys

# GeoNetwork constants
gn_username = "gn_username"
gn_password = "gn_password"
gn_baseURL = "http://localhost:8080/geonetwork"
loginservice='j_spring_security_check'

xmlurl = gn_baseURL + "/srv/eng"
url_search = xmlurl + "/xml.search"
url_get = xmlurl + "/xml.metadata.get"
url_update = xmlurl + "/xml.metadata.update"
header_xml = {"Mime-type": "application/xml"}

def gn_authenticate():
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


def gn_updatedate(opener, dateChange):

   # Check csv exists
   if os.path.isfile(dateChange):
      dateChange = str(dateChange)

      # open file and process a line at a time
      openFile = open(dateChange,'r')
      for line in openFile:
         line = line.strip().split(",")

         # Search for record using title
         searchparam = urllib.urlencode({"any": line[0]})
         request = urllib2.Request(url_search, searchparam, header_xml)
         response = opener.open(request)
         xml_response = response.read()
         xmldoc = etree.fromstring(xml_response)

         numRecords = int(xmldoc.xpath('//response/@to')[0])
         
         if numRecords == 1:
         
            # Get uuid from response
            uid = xmldoc.find('.//{http://www.fao.org/geonetwork}info/id').text
            
            # Get record using id
            getparam = urllib.urlencode({"id": uid})
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
               <xsl:output method="xml" version="1.0" indent="yes" omit-xml-declaration="yes"/>
               <xsl:template match="*/gmd:dateStamp/gco:Date">
                        <gco:Date>''' + line[1] + '''</gco:Date>
                     </xsl:template>
                     <xsl:template match="*/gmd:dateStamp/gco:DateTime">
                        <gco:Date>''' + line[1] + '''</gco:Date>
                     </xsl:template>
                     <xsl:template match="*/gmd:citation/gmd:CI_Citation/gmd:date">                  
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
                           <xsl:if test="contains($datetype, 'publication')">
                                <gmd:date>
                                  <xsl:apply-templates select="@* | node()"/>
                                </gmd:date>
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
                           <xsl:if test="contains($datetype, 'creation')">
                                <gmd:date>
                                  <xsl:apply-templates select="@* | node()"/>
                                </gmd:date>
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
                        </xsl:for-each>
                     </xsl:template>
                     
                     <xsl:template match="@* | node()">
                        <xsl:copy><xsl:apply-templates select="@* | node()"/></xsl:copy>
                     </xsl:template>
               
               </xsl:stylesheet>''')
            
            # Create xslt
            transform = etree.XSLT(xslt_root)
            # Transform xml with xslt
            fixed = transform(xmldoc)

            # Remove excess revision dates created in xslt
            # back to string, then list object(split by newline character)
            # (there are no newline characters in the added xml)
            xmlstring = etree.tostring(fixed)
            xmllist = xmlstring.split("\n")

            # Strip white space from each to make sure in case of inconsistences in xml
            for xl in xmllist:
               idx = xmllist.index(xl)
               xl2 = xl.strip()
               xmllist.pop(idx)
               xmllist.insert(idx,xl2)
               
            # the bit to find and remove
            string = '''<gmd:date><gmd:CI_Date><gmd:date><gco:Date>''' + line[1] + '''</gco:Date></gmd:date><gmd:dateType><gmd:CI_DateTypeCode codeList="http://standards.iso.org/ittf/PubliclyAvailableStandards/ISO_19139_Schemas/resources/codelist/ML_gmxCodelists.xml#CI_DateTypeCode" codeListValue="revision"/></gmd:dateType></gmd:CI_Date></gmd:date>'''
            # count occurences
            result = xmllist.count(string)

            # remove all extra occurences
            if result != 0:
                indexes = [i for i,x in enumerate(xmllist) if x == string]
                for j in range(len(indexes)):
                    xmllist.pop(indexes[j])
            
            result2 = xmllist.count(string)

            if result2 == 0:
               # Return the xml to a string
               newXML = ""
               for xl in xmllist:
                   newXML = newXML + xl + "\n"
               # remove final newline character
               newXML = newXML[:-1]
               
               # Prepare parameters for upload
               updateparam = urllib.urlencode({"id": uid, "version": "1", "minor": "true", "data": newXML})

               try:
                  request = urllib2.Request(url_update, updateparam, header_xml)
                  response = opener.open(request)
                  xml_response = response.read()
                  print "Updated: " + line[0]
               except urllib2.HTTPError, error:
                  print error.read()
                  
            else:
               print "Failed to update: " + line[0]
         else:
            print "Doesn't yet exist in a record: " + line[0]
         
      # Close the file
      openFile.close()
      
   else:
      print str(dateChange) + " is not valid.\n" \
            "Please provide a table in csv format, e.g.\n" \
            "'thing to search on','the-update-date'\n" \
            "HISTORIC_LAYER,2015-03-02\n" \
            "FLOOD_LAYER,2015-03-01"


def gn_updatecontact(opener, contactChange):

   # Check csv exists
   if os.path.isfile(contactChange):
      contactChange = str(contactChange)
      
      # process file of change details to a list then a dictionary.
      nfile = open(contactChange, 'r')
      itemLst = []
      for line in nfile:
         item = line.strip().split(",")
         itemLst.append(item)

      # Create dictionary for use in xsl
      namedict = {"contactType":itemLst[0][1], \
               "oldEmail":itemLst[1][1], \
               "newName":itemLst[2][1], \
               "newOrg":itemLst[3][1], \
               "newPos":itemLst[4][1], \
               "newEmail":itemLst[5][1], \
               "newRole":itemLst[6][1]}

      # Search for records using the old email address
      searchparam = urllib.urlencode({"any": namedict["oldEmail"]})
      request = urllib2.Request(url_search, searchparam, header_xml)
      response = opener.open(request)
      xml_response = response.read()
      
      # Get IDs from response
      xmldocmaster = etree.fromstring(xml_response)
      #numRecords = int(xmldocmaster.xpath('//response/@to')[0])
      lst = xmldocmaster.findall('.//{http://www.fao.org/geonetwork}info/id')
      
      for uid in lst:
        
         # Get record using id
         getparam = urllib.urlencode({"id": uid.text})
         request = urllib2.Request(url_get, getparam, header_xml)
         response = opener.open(request)
         xml_response = response.read()

         # Change the XML - update contact details
         xmldoc = etree.fromstring(xml_response)
         xslt_root = etree.XML('''\
            <xsl:stylesheet version="1.0" exclude-result-prefixes="eamp"
            xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
            xmlns:gmd="http://www.isotc211.org/2005/gmd"
            xmlns:xlink="http://www.w3.org/1999/xlink"
            xmlns:eamp="http://environment.data.gov.uk/eamp"
            xmlns:gco="http://www.isotc211.org/2005/gco"
            xmlns:gml="http://www.opengis.net/gml/3.2"
            xmlns:srv="http://www.isotc211.org/2005/srv"
            xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
            <xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes" omit-xml-declaration="no"/>
            <xsl:variable name="lowercase" select="'abcdefghijklmnopqrstuvwxyz'"/>
            <xsl:variable name="uppercase" select="'ABCDEFGHIJKLMNOPQRSTUVWXYZ'"/>
            <xsl:template match="*/gmd:''' + namedict["contactType"] + '''">
                 <gmd:''' + namedict["contactType"] + '''>
                     <xsl:variable name="email">
                         <xsl:value-of select="translate(./gmd:CI_ResponsibleParty/gmd:contactInfo/gmd:CI_Contact/gmd:address/gmd:CI_Address/gmd:electronicMailAddress/gco:CharacterString, $uppercase, $lowercase)"/>
                     </xsl:variable>
                     <xsl:if test=\"contains($email,\'''' + namedict["oldEmail"] + '''\')\">
                         <gmd:CI_ResponsibleParty>
                             <gmd:individualName>
                                 <gco:CharacterString>''' + namedict["newName"] + '''</gco:CharacterString>
                             </gmd:individualName>
                             <gmd:organisationName>
                                 <gco:CharacterString>''' + namedict["newOrg"] + '''</gco:CharacterString>
                             </gmd:organisationName>
                             <gmd:positionName>
                                 <gco:CharacterString>''' + namedict["newPos"] + '''</gco:CharacterString>
                             </gmd:positionName>
                             <gmd:contactInfo>
                                 <gmd:CI_Contact>
                                     <gmd:address>
                                         <gmd:CI_Address>
                                             <gmd:electronicMailAddress>
                                                 <gco:CharacterString>''' + namedict["newEmail"] + '''</gco:CharacterString>
                                             </gmd:electronicMailAddress>
                                         </gmd:CI_Address>
                                     </gmd:address>
                                 </gmd:CI_Contact>
                             </gmd:contactInfo>
                             <gmd:role>
                                 <gmd:CI_RoleCode codeList="http://standards.iso.org/ittf/PubliclyAvailableStandards/ISO_19139_Schemas/resources/Codelist/ML_gmxCodelists.xml#CI_RoleCode" codeListValue="''' + namedict["newRole"] + '''"/>
                             </gmd:role>
                         </gmd:CI_ResponsibleParty>
                     </xsl:if>
                     <xsl:if test=\"not(contains($email,\'''' + namedict["oldEmail"] + '''\'))\">
                         <xsl:apply-templates select="@* | node()"/>
                     </xsl:if>
                 </gmd:''' + namedict["contactType"] + '''>
            </xsl:template>
            <xsl:template match="@* | node()">
               <xsl:copy>
                  <xsl:apply-templates select="@* | node()"/>
               </xsl:copy>
            </xsl:template>
            </xsl:stylesheet>''')

         transform = etree.XSLT(xslt_root)

         # Transform the xml
         newXML = transform(xmldoc)
         # Convert back to a string for upload
         newXML = etree.tostring(newXML)
         # Update paremeters
         updateparam = urllib.urlencode({"id": uid.text, "version": "1", "minor": "true", "data": newXML})
         
         try:
            request = urllib2.Request(url_update, updateparam, header_xml)
            response = opener.open(request)
            xml_response = response.read()
            print "Success!"
         except urllib2.HTTPError, error:
            print error.read()

   else:
      print str(contactChange) + " is not valid.\n" \
               "Please provide a table as a csv, in the prescribed format."
