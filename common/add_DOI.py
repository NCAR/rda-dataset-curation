#!/usr/bin/env python
import sys
from netCDF4 import Dataset
"""Adds given DOI to global attributes of file.
"""
def usage():
    print('Usage:')
    print('    '+sys.argv[0]+' [netCDF file] [DOI]')

def add_DOI(filename, doi):
    """Searches netcdf file for variables that do not have standard names
    and attempts to replace them from std_names dict.
    Uses existing long_name as key.
    """
    doi_attr_name = 'DOI'
    nc = Dataset(filename, 'a')
    nc.setncattr(doi_attr_name, doi)
    nc.close()

if len(sys.argv) <= 2:
    usage()
    exit(1)

add_DOI(sys.argv[1], DOI)
