#!/usr/bin/env python
import sys
import os
import add_nc_global


global_dict = {
        'GRIB_edition': '2',
        'GRIB_centre' : "kwbc" ,
        'GRIB_subCentre' : 2 ,
        'Conventions' : "CF-1.7",
        'institution' : "NOAA ESRL & CU/CIRES"
                }

filename = sys.argv[1]
assert os.path.exists(filename)
add_nc_global.add_globals(filename, global_dict)
