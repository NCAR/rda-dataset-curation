#!/usr/bin/env python

import zarr
import xarray

# Upload arbitrary file to zarr
def usage():
    print "Usage:"
    print sys.argv[0] + " [filename]"
    exit(1)

if __name__ == "__main__":
if len(sys.argv) <= 1:
    usage()

filename = sys.argv[1]

xarray.open(filename)
xarray.tozarr(filename+'.zar')

