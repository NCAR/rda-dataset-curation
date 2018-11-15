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
description = "Compares two netCDF file's variables. \n \
               Prints 'True' or 'False'. And, \n \
               Returns 0 for true and 1 for false"
parser = argparse.ArgumentParser(prog='compareNetCDFData', description=description)
parser.add_argument('file1', type=str,  help="Specify the name of first netCDF file")
parser.add_argument('file2', type=str, help="Specify the name of second netCDF file")
parser.add_argument('-v1', type=str, help="Specify the name of the variable in first file")
parser.add_argument('-v2', type=str, help="Specify the name of the variable in second file")
if len(sys.argv) == 1:
    args = parser.parse_args(['-h'])
    exit(2)
args = parser.parse_args()
file1 = args.file1
file2 = args.file2
if v1 is None:
    pass
nc1 = Dataset(file1)
nc2 = Dataset(file2)
#before['T']
#before.variables
#before['TMP2m'][:]
#a = before['TMP2m'][:]
#b = after['TMP2m'][:]
#numpy.all(a,b)
#before
#a
#numpy.array_equal(a,b)
