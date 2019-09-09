#!/usr/bin/python
import sys
import os
import pdb
import argparse
from netCDF4 import Dataset
import numpy as np

def copy_variable(infile, outfile, var_name, new_varname=None, new_fill_value=None):
    """Copies variable from infile to outfile.

    This assumes (for now) that dimensions of source variable
    are defined and match the destination file.
    infile (str or Dataset) : Name of file/filehandle to copy from.
    outfile (str or Dataset) : Name of file/filehandle to copy to.
    varname (str) : Name of variable to copy
    """
    if new_varname is None:
        new_varname = var_name

    f1 = get_NC_filehandle(infile)
    f2 = get_NC_filehandle(outfile, mode='a')
    var = f1[var_name]

    new_var = f2.createVariable(new_varname, var.dtype, var.dimensions, fill_value=new_fill_value)
    # Add attributes
    if new_fill_value is not None and len(var.dimensions) > 0:
        copy_var_attrs(var, new_var, ignore=['_FillValue'])
        new_var[:] = change_fill_value(var, 9999)
    else:
        copy_var_attrs(var, new_var)
        new_var[:] = var[:]
    return f2

def copy_variables(infile, outfile, ignore=[], new_fill_value=None):
    """Copies all variables from outfile to infile.
    Optionally ignore varname
    """
    f1 = get_NC_filehandle(infile)
    f2 = get_NC_filehandle(outfile, mode='r+')

    for v in f1.variables:
        if v not in ignore:
            copy_variable(f1, f2, v, new_fill_value=new_fill_value)
    return f2

def change_fill_value(var, new_fill_value=np.nan):
     """Requires variable to be copied."""
     if '_FillValue' in var.ncattrs():
         if np.isnan(var.getncattr('_FillValue')):
             compare_func = np.isnan
         else:
             former_fill_value = var.getncattr('_FillValue')
             compare_func = lambda x: x == former_fill_value
         new_data  = var[:]
         new_data[np.where(compare_func(var[:]))] = new_fill_value
     else:
         new_data = var[:]
     return new_data


def copy_var_attrs(invar, outvar, ignore=[]):
    """Copies attributes from one variable to another"""
    for key in invar.ncattrs():
        value = invar.getncattr(key)
        if key not in ignore:
            outvar.setncattr(key, value)
    return outvar

def copy_dimensions(infile, outfile, ignore=[]):
    """ Given an infile and outfile, copy dimensions
    """
    if type(ignore) is not list:
        ignore = [ignore]
    f1 = get_NC_filehandle(infile)
    f2 = get_NC_filehandle(outfile, mode='a')
    for dim_name in f1.dimensions:
        if dim_name not in ignore:
            dim_size = f1.dimensions[dim_name].size
            f2.createDimension(dim_name, dim_size)
    return f2


def copy_global_attrs(infile, outfile, ignore=[]):
    """Copies global attributes from one file/filehandle to another."""
    f1 = get_NC_filehandle(infile)
    f2 = get_NC_filehandle(outfile, mode='a')
    for global_key in f1.ncattrs():
        if global_key not in ignore:
            f2.setncattr(global_key, f1.getncattr(global_key))
    return f2

def get_NC_filehandle(filename, mode='r'):
    """Returns filehandle give a filehandle or filename str.

    Optionally, can provide mode to open with
    """
    # If str, assume they're filenames
    if type(filename) is str:
        if not os.path.isfile(filename):
            return Dataset(filename, 'w')
        return Dataset(filename, mode)
    elif type(filename) is Dataset:
        return filename
    raise Exception("filename type not understood")


if __name__ == "__main__":
    description = "copies variable from one netcdf file to another"
    parser = argparse.ArgumentParser(prog='copyNCVariable', description=description)
    parser.add_argument('--sourceFile', '-s',type=str, required=True, help="NetCDF File where were variable is located")
    parser.add_argument('--destFile', '-d',type=str, required=True, help="NetCDF file to copy var to")
    parser.add_argument('--varname','-vn', type=str, required=True, help="Name of variable")
    if len(sys.argv) <  3:
        args = parser.parse_args(['-h'])
        exit(1)
    args = parser.parse_args()
    f2 = copy_variable(args.sourceFile, args.destFile, args.varname)
    f2.close()
