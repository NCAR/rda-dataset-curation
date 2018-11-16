#!/usr/bin/env python
import os
import argparse
from netCDF4 import Dataset
import numpy as np


def get_test_filename():
    filename = 'test'
    extension = '.nc'
    i = 1
    while os.path.isfile(filename + str(i) + extension):
        i += 1
    return filename + str(i) + extension

def create_test_file(name=None, num_dims=3, dim_len=10, varname='Test'):
    if name is None:
        name = get_test_filename()
    nc = Dataset(name, 'w')

    # Create Dimensions
    dim_names = []
    for i in range(65,65+num_dims):
        cur_dim_name = chr(i)
        dim_names.append(cur_dim_name)
        nc.createDimension(cur_dim_name, dim_len)

    # Create Variables

    # Create Variables for each dimension
    for dn in dim_names:
        cur_var = nc.createVariable(dn, float, (dn))
        cur_var[:] = np.random.rand(dim_len)

    # Create Primary Variable
    cur_var = nc.createVariable(varname, float, tuple(dim_names))
    cur_var[:] = np.random.rand(*[dim_len for i in dim_names])
    nc.close()






description = "Creates a test netcdf file."
parser = argparse.ArgumentParser(prog='create_test_nc_file', description=description)
parser.add_argument('--filename','-fn', type=str, help="Specify output filename")
parser.add_argument('--num-dims','-n', type=str, help="Specify number of dimensions")

args = parser.parse_args()
create_test_file()



