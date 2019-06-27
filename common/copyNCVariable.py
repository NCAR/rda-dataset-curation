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

    # If str, assume they're filenames
    if type(infile) is str and type(outfile) is str:
        f1 = Dataset(infile)
        f2 = Dataset(outfile, 'a')
    elif type(infile) is Dataset and type(outfile) is Dataset:
        f1 = infile
        f2 = outfile
    else:
        raise Exception("infile and outfile type not understood")
    var = f1[var_name]

    new_var = f2.createVariable(var.name, var.dtype, var.dimensions)
    # Add attributes
    for key in var.ncattrs():
        value = var.getncattr(key)
        new_var.setncattr(key, value)
    new_var[:] = var[:]

def copyDimensions():
    pass

def copyGlobalAttrs():
    pass


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
