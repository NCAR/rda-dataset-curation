#!/usr/bin/env python
import sys
from netCDF4 import Dataset
"""Adds given global attribute to file.
"""
def usage():
    print('Usage:')
    print('    '+sys.argv[0]+' [netCDF file] [attribute name] [attribute value]')

def add_global(filename, key, value):
    """Given a filename, will add a new global attribute
    of key value pair.
    """
    nc = Dataset(filename, 'a')
    nc.setncattr(key, value)
    nc.close()


if __name__ == '__main__':
    if len(sys.argv) <= 3:
        usage()
        exit(1)

    filename = sys.argv[1]
    key = sys.argv[2]
    value = sys.argv[3]
    add_global(filename, key, value)
