#!/usr/bin/env python
import sys
import os
import xarray
import pdb

def convert(filename):
    ds = xarray.open_dataset(filename)
    pdb.set_trace()

    for v in ds.variables:
        convert_long_name(v)


def convert_long_name(var):
    var.attrs['long_name'] = var.attrs['description']

def rechunk(var):
    pass



if __name__ == "__main__":
    if len(sys.argv) > 1:
        convert(sys.argv[1])
    else:
        print('Not enough arguments')
