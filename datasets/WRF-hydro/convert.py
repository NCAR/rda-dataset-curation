#!/usr/bin/env python
import sys
import os
import xarray
import numpy
import pdb
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

def convert(filename, outfile):
    base_fn = os.path.basename(filename)
    #outdir = f'/glade/campaign/collections/rda/scratch/rpconroy/WRF-water'
    #outfile = f'{outdir}/{base_fn}'
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
    #ds = add_grid_vars(ds)
    ds = add_grid_mapping(ds)
    ds = adjust_globals(ds)
    remove_vars(ds)
    print(f'writing {outfile}')
    new_ds = ds.chunk()
    new_ds.compute()
    if encoding:
        new_ds.to_netcdf(outfile, encoding=encoding)
    else:
        new_ds.to_netcdf(outfile)


def add_grid_mapping(ds):
    lc = xarray.DataArray(
            attrs={
        'grid_mapping_name' : 'lambert_conformal',
        'standard_parallel' : '25.0',
        'longitude_of_central_meridian' : '265.0',
        'latitude_of_projection_origin' : '25.0'}).astype(numpy.dtype('int32'))
    return ds.assign(Lambert_Conformal=lc)

def add_grid_vars(ds):
    dx = 4000.0
    dy = 4000.0
    x = xarray.DataArray(data = numpy.array([i for i in range(1367)], dtype=numpy.dtype('float32'))*dx, dims=['west_east'])
    y = xarray.DataArray(data = numpy.array([i for i in range(1015)], dtype=numpy.dtype('float32'))*dy, dims=['north_south'])
    return ds.assign(X=x, Y=y)

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
    #encoding['zlib'] = True
    #encoding['complevel'] = 1
    for i in ['szip', 'zstd', 'bzip2', 'blosc', 'preferred_chunks', 'coordinates']:
        if i in encoding:
            encoding.pop(i)
    return encoding

g = convert_chunks.convert_chunk(ds, chunksize, var)


if __name__ == "__main__":
    if len(sys.argv) > 2:
        infile = sys.argv[1]
        outfile = sys.argv[2]
        convert(infile, outfile)
    else:
        print('Not enough arguments')
