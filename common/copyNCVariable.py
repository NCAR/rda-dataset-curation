#!/usr/bin/python
import sys
import argparse
from netCDF4 import Dataset

def copyVariable(infile, outfile, var_name):
    """Copies variable from infile to outfile.

    This assumes (for now) that dimensions of source variable
    are defined and match the destination file."""
    f1 = Dataset(infile)
    f2 = Dataset(outfile, 'a')
    var = f1[var_name]

    new_var = f2.createVariable(var.name, var.dtype, var.dimensions)
    # Add attributes
    for key in var.ncattrs():
        value = var.getncattr(key)
        new_var.setncattr(key, value)
    new_var[:] = var[:]



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
