#!/usr/bin/env python
import sys
import os
import tempfile
import xarray
import numpy
import convert_chunks
import standard_name_map

def apply_standard_name(var):
    """Apply a CF `standard_name` from the provided mapping if available."""
    try:
        name = var.name
    except Exception:
        return
    if not name:
        return
    std = standard_name_map.standard_names.get(name)
    if std:
        var.attrs['standard_name'] = std

def convert(filename):
    ds = xarray.open_dataset(filename, lock=None)
    ds.load()
    encoding = {}
    for v in ds.variables:
        convert_long_name(ds[v])
        apply_standard_name(ds[v])
        remove_stagger(ds[v])
        adjust_xtime(ds[v])
        if '2d' in filename:
            if len(ds[v].shape) == 3:
                encoding[v] = get_encoding(ds[v])
    ds = add_grid_mapping(ds)
    ds = adjust_globals(ds)
    remove_vars(ds)
    new_ds = ds.chunk()
    new_ds.compute()

    dirpath = os.path.dirname(os.path.abspath(filename))
    fd, tmppath = tempfile.mkstemp(dir=dirpath, suffix='.nc')
    os.close(fd)
    try:
        print(f'writing {tmppath}')
        if encoding:
            new_ds.to_netcdf(tmppath, encoding=encoding)
        else:
            new_ds.to_netcdf(tmppath)
        os.replace(tmppath, filename)
        print(f'replaced {filename}')
    except Exception:
        os.unlink(tmppath)
        raise


def add_grid_mapping(ds):
    lc = xarray.DataArray(
            attrs={
        'grid_mapping_name' : 'lambert_conformal',
        'standard_parallel' : '25.0',
        'longitude_of_central_meridian' : '265.0',
        'latitude_of_projection_origin' : '25.0'}).astype(numpy.dtype('int32'))
    return ds.assign(Lambert_Conformal=lc)

def remove_vars(ds):
    del ds['XTIME']

def adjust_globals(ds):
    ds.attrs['conventions'] = "CF-1.12"
    ds.attrs['title'] = 'CONUS404'
    ds.attrs['Contacts'] = 'Lulin Xue (xuel@ucar.edu)'
    return ds

def remove_stagger(var):
    """Remove empty stagger attributes."""
    if 'stagger' in var.attrs and var.attrs['stagger'] == "":
        del var.attrs['stagger']

def convert_long_name(var):
    if 'description' in var.attrs and 'long_name' not in var.attrs:
        var.attrs['long_name'] = var.attrs['description'].capitalize()
        del var.attrs['description']
    elif 'description' in var.attrs:
        var.attrs['description'] = var.attrs['description'].capitalize()

def adjust_xtime(var):
    if 'coordinates' in var.attrs and 'XTIME' in var.attrs['coordintes']:
        var.attrs['coordinates'] = var.attrs['coordinates'].replace('XTIME','Time')

def get_encoding(var, chunksize=None):
    encoding = var.encoding
    if chunksize is None:
        chunksize = var.shape
    encoding['chunksizes'] = chunksize
    for i in ['szip', 'zstd', 'bzip2', 'blosc', 'preferred_chunks', 'coordinates']:
        if i in encoding:
            encoding.pop(i)
    return encoding


if __name__ == "__main__":
    if len(sys.argv) > 1:
        for filename in sys.argv[1:]:
            convert(filename)
    else:
        print('Usage: convert_inplace.py <file> [file ...]')
