#!/usr/bin/env python
import sys
import os
import xarray
import pdb
import convert_chunks

def convert(filename):
    ds = xarray.open_dataset(filename)

    for v in ds.variables:
        convert_long_name(v)
        convert_chunks(filename, 'out.nc',


def convert_long_name(var):
    var.attrs['long_name'] = var.attrs['description']

def rechunk(ds):

    new_encoding = {}

    for var in ds.variables:
        chunksize = var.shape
        new_ds = ds.chunk(chunksize)
        new_encoding = new_ds[varname].encoding
        new_encoding['chunksizes'] = chunksize
        for i in ['szip', 'zstd', 'bzip2', 'blosc', 'preferred_chunks', 'coordinates']:
            if i in new_encoding:
                new_encoding.pop(i)
        print(new_encoding)
        return (new_ds, new_encoding)
    ds, encoding = convert_chunks.convert_chunk(ds, chunksize, var)



if __name__ == "__main__":
    if len(sys.argv) > 1:
        convert(sys.argv[1])
    else:
        print('Not enough arguments')
