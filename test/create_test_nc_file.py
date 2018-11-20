#!/usr/bin/env python
import os
import argparse
from netCDF4 import Dataset
import numpy as np
import pdb


def get_test_filename():
    """Returns an unused default test name.
    Will be of form test[num].nc
    """
    filename = 'test'
    extension = '.nc'
    i = 1
    while os.path.isfile(filename + str(i) + extension):
        i += 1
    return filename + str(i) + extension

def create(name=None, num_dims=3, dim_len=10, varname='Test'):
    """Creates raw test file.
    """
    user_specified_dims = False
    ## Handle bad command line args
    if num_dims is None:
        num_dims=3
    if dim_len is None:
        dim_len = 10
    if type(dim_len) is tuple:
        user_specified_dims = True
    if varname is None:
        varname = 'Test'
    if name is None:
        name = get_test_filename()

    nc = Dataset(name, 'w')

    # Create Dimensions
    dim_names = []
    for i,letter in enumerate(range(65,65+num_dims)): # The letter 'A' -> A+num_dims
        cur_dim_name = chr(letter)
        dim_names.append(cur_dim_name)
        cur_dim_len = dim_len
        if user_specified_dims:
            cur_dim_len = dim_len[i]
        nc.createDimension(cur_dim_name, cur_dim_len)

    # Create Variables

    # Create Variables for each dimension
    for i,dn in enumerate(dim_names):
        cur_var = nc.createVariable(dn, float, (dn))
        cur_dim_len = dim_len
        if user_specified_dims:
            cur_dim_len = dim_len[i]
        cur_var[:] = np.random.rand(cur_dim_len)

    # Create Primary Variable
    cur_var = nc.createVariable(varname, float, tuple(dim_names))

    cur_dim_len = dim_len
    if user_specified_dims:
        cur_var[:] = np.random.rand(dim_len)
    else:
        cur_var[:] = np.random.rand(*[dim_len for i in dim_names])
    nc.close()
    return name


description = "Creates a test netcdf file."
parser = argparse.ArgumentParser(prog='create_test_nc_file', description=description)
parser.add_argument('--filename','-fn', type=str, help="Specify output filename")
parser.add_argument('--num-dims','-n', type=str, help="Specify number of dimensions")
parser.add_argument('--dim-length','-dl', type=str, help="Specify length of dimensions")
parser.add_argument('--varname','-v', type=str, help="Specify primary variable's name")

args = parser.parse_args()
name = create(name=args.filename,
        num_dims=args.num_dims,
        dim_len=args.dim_length,
        varname=args.varname)

print(name)




