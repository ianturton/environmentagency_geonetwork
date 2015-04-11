"""
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

Update date:
    Use date_update.csv for updatedate script, must be in form of:
    e.g. 'thing to search on','the-update-date', e.g.
    HISTORIC_LAYER,2015-03-02
    FLOOD_LAYER,2015-03-01

OR

Contact details:
    Use contact_change.csv for change script
    It uses "oldEmail" to find records.
    "contacttype" = "contact" for metadata contact change, or
                    "pointOfContact" for resource contact change.
    Provide new details.
    
"""

# Import custom module of tools
import geonetworkTools

# Change this path or cantact details?
contactChange = r"contact_change.csv"
dateChange = r"date_update.csv"


# Uncomment the tool you wish to use.
opener = geonetworkTools.gn_authenticate()
geonetworkTools.gn_updatedate(opener, dateChange)
#geonetworkTools.gn_updatecontact(opener, contactChange)
