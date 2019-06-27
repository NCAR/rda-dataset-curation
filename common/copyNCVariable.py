#!/usr/bin/python
import sys
import argparse
from netCDF4 import Dataset

def copyVariable(infile, outfile, var_name):
    """Copies variable from infile to outfile.

    This assumes (for now) that dimensions of source variable
    are defined and match the destination file.
    infile (str or Dataset) : Name of file/filehandle to copy from.
    outfile (str or Dataset) : Name of file/filehandle to copy to.
    varname (str) : Name of variable to copy
    """

    f1 = get_NC_filehandle(infile)
    f2 = get_NC_filehandle(outfile, mode='a')
    var = f1[var_name]

    new_var = f2.createVariable(var.name, var.dtype, var.dimensions)
    # Add attributes
    for key in var.ncattrs():
        value = var.getncattr(key)
        new_var.setncattr(key, value)
    new_var[:] = var[:]

def copyDimensions(infile, outfile, ignore=[]):
    f1 = get_NC_filehandle(infile)
    f2 = get_NC_filehandle(outfile, mode='a')
    for dim_name in f1.dimensions:
        if dim_name not in ignore:
            dim_size = f1.dimensions[dim_name].size
            f2.createDimension(dim_name, dim_size)
    return f2


def copyGlobalAttrs(infile, outfile, ignore=[]):
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
        return Dataset(infile, mode)
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
    copyVariable(args.sourceFile, args.destFile, args.varname)
