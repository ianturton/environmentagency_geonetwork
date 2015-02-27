# -*- coding: utf8 -*-

## Copyright (c) 2014 Astun Technology

# Library Imports
import urllib
import urllib2
import cookielib


# GeoNetwork constants
gn_username = "yourusername" #change this to suit
gn_password = "yourpassword" #change this to suit
gn_baseURL = "http://ea.astuntechnology.com:8080/geonetwork"
gn_cswURI = "/geonetwork/srv/en/csw"

loginservice='j_spring_security_check' # replaces 'xml.user.login'
searchservice='srv/eng/xml.search'
delservice='srv/eng/metadata.delete'
groupcheck = 'srv/eng/xml.info?type=groups'
#add more URLs here or change to suit

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
except AssertionError:
    raise RuntimeError('Login failed!')

# Rest of script etc...
request = urllib2.Request('%s/%s'%(gn_baseURL, groupcheck))
response = opener.open(request)
print response.read()       # debug


