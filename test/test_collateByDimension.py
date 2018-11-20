#!/usr/bin/env python
import sys, os
sys.path.append(os.path.dirname(os.path.realpath(__file__)) +"/../")
import common.collateByDimension as cbd
import create_test_nc_file as create_nc
from netCDF4 import Dataset
from subprocess import call

# Creates test netcdf file with default dimensions and variables
print("Creating Test files")
filename = create_nc.create()
filename2 = create_nc.create()

dimension_name = 'B'
try:
    print("Testing Collate")
    cbd.collate(dimension_name, [filename,filename2], varname=None, output_filename="out.nc" )
except Exception as:
    print(e)

print("Asserting truth")
testnc = None
outnc = Dataset('out.nc')

call(['rm', 'out.nc'])
call(['rm', filename])
call(['rm', filename2])
