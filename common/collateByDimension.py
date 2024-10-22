#!/usr/bin/env python
import sys, os
from netCDF4 import Dataset
import argparse
import numpy as np
import pdb

#TODO: improve this
try:
    from .copyNC import copy
except:
    from copyNC import copy

def collate(dim_name, files, varname=None, output_filename="out.nc"):
    if output_filename is None:
        output_filename = 'out.nc'
    # Open all files
    var_data = []
    dim_data = []
    dims = None
    for file_str in files:
        nc = Dataset(file_str)
        if varname is None:
            varname = get_primary_variable(nc)
        dv = get_dimension_variable(nc, dim_name)
        primary_var = nc.variables[varname]
        var_data.append(primary_var[:])
        dim_data.append(dv[:])
        dims = primary_var.dimensions
        dim_idx = dims.index(dim_name)
        nc.close()
    # Combine data
    new_var_data = np.concatenate(var_data, axis=dim_idx)
    new_dim_data = np.concatenate(dim_data, axis=0)


    nc = copy(files[0], output_filename, dim_name, varname)
    nc.createDimension(dim_name, len(new_dim_data))
    new_var = nc.createVariable(varname, new_var_data.dtype, dims)
    new_dim = nc.createVariable(dim_name, new_dim_data.dtype, (dim_name,))
    new_var[:] = new_var_data
    new_dim[:] = new_dim_data
    nc.close()


def is_primary_variable(varname, dims):
    return varname not in dims

def get_dimension_variable(nc, dim_name):
    return nc.variables[dim_name]

def get_primary_variable(nc):
    """Only returns one variable even if there are multiple primary variables"""
    for i in nc.variables:
        if is_primary_variable(i, nc.dimensions):
            return i

def getSecondaryVariables(nc):
    pass

def getDimIndex(var, dim_name):
    return var.dimensions.index(dim_name)

if __name__ == '__main__':
    description = "concatonates variable in netCDF file by dimension"
    parser = argparse.ArgumentParser(prog='collateByDimension', description=description)
    parser.add_argument('--dimname','-dn',type=str, required=True, help="Specify the name of the dimension to collate")
    parser.add_argument('--varname','-vn',type=str, help="Specify the name of the variable to collate")
    parser.add_argument('--outfile','-o',type=str, help="Specify the name of the output filename")
    parser.add_argument('files', nargs='*')
    if len(sys.argv) == 1:
        args = parser.parse_args(['-h'])
        exit(1)
    args = parser.parse_args()
    collate(args.dimname, args.files, varname=args.varname, output_filename=args.outfile)

