'''
Author: John Tate - Environment Agency
Date:   27/02/2015
'''

# Import custom module of tools
import geonetworkTools

# Change this path?
table = r"table.csv"

# Dont' change anything below here.
opener = geonetworkTools.gn_authenticate()
geonetworkTools.gn_updatedate(opener, table)
