#!/usr/bin/env python
import sys
from netCDF4 import Dataset
"""Adds given attribute key/value to main variable.
This program attempts to find the 'main' variable in the file to give the parameter
"""
def usage():
    print('Usage:')
    print('    '+sys.argv[0]+' [netCDF file] [key] [value] [varname (optional)]')

def add_attr(nc_handle, var_name, key, value):
    """Adds attr to variable
    """
    doi_attr_name = 'DOI'
    nc.variables[varname].setncattr(key, value)

if __name__ == '__main__':
    if len(sys.argv) <= 3:
        usage()
        exit(1)

    filename = sys.argv[1]
    key = sys.argv[2]
    value = sys.argv[3]

    nc = Dataset(filename, 'a')
    if len(sys.argv) == 5:
        varname = sys.argv[4]
    else: # find varname
        most_likely_varname = None
        longest = 0
        for varname in nc.variables:
            var = nc.variables[varname]
            if len(var.dimensions) > longest:
                most_likely_varname = varname
    add_attr(nc, varname, key, value)
    nc.close()


