EA-specific config files for Geonetwork 2.10.4

Customised configuration files for the Environment Agency's Geonetwork Installation

**Transformations**

 * Files named import*.xsl are internal Geonetwork stylesheets for import of data and need to be copied to /var/lib/tomcat6/webapps/geonetwork/xsl/conversion/import
 * Other transformation files are external and do not need to be loaded onto the server

**Interface_Customisations**

 * These files are relative to the geonetwork folder, but apply with caution- config-overrides files may need credentials to be changed before use
