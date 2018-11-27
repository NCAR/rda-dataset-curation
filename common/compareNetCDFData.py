#!/usr/bin/env python
import sys
import argparse
from netCDF4 import Dataset
import numpy

"""
compareNetCDFData
-----------------

Given two netcdf files and and a variable,
determines if the data within the variables are equal.

Useful for determining the impact of compression or
effects of conversion methods.
"""
def findVariable(nc):
    """Returns name of first variable in nc file handle
    """
    for i in nc.variables:
        return i

description = "Compares two netCDF file's variables.\n \
               Prints 'True' or 'False'. And,\n \
               Returns 0 for true and 1 for false. Does not handle NetCDF groups"
parser = argparse.ArgumentParser(
        prog='compareNetCDFData',
        description=description,
        formatter_class=argparse.RawTextHelpFormatter)
parser.add_argument('file1', type=str,  help="Specify the name of first netCDF file")
parser.add_argument('file2', type=str, help="Specify the name of second netCDF file")
parser.add_argument('-v1', type=str, help="Specify the name of the variable in first file\n(Default compares all variables)")
parser.add_argument('-v2', type=str, help="Specify the name of the variable in second file\n(Default compares all variables)")
if len(sys.argv) == 1:
    args = parser.parse_args(['-h'])
    exit(99)

args = parser.parse_args()

file1 = args.file1
file2 = args.file2

nc1 = Dataset(file1)
nc2 = Dataset(file2)

if args.v1 is None:
    v1 = findVariable(nc)
else:
    v1 = args.v1

if args.v2 is None:
    v2 = v1
else:
    v2 = args.v2

data1 = nc1[v1][:]
data2 = nc2[v2][:]
ans = numpy.array_equal(a,b)
print(ans)
if ans:
    exit(0)
exit(1)
