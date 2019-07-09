#!/usr/bin/env python
from netCDF4 import Dataset
import copyNCVariable as copync
import sys, os
import random
import pdb
import numpy as np

#
#
#


def usage():
    print("Usage")
    print("    "+sys.argv[0]+" [filename] [dim name]")
    exit(1)

def find_variables_with_dimension(nc, dim_name):
    selected_vars = []
    for var_name in nc.variables:
        var = nc.variables[var_name]
        if dim_name in var.dimensions:
            selected_vars.append(var)
    return selected_vars

def find_variables_without_dimension(nc, dim_name):
    selected_vars = []
    for var_name in nc.variables:
        var = nc.variables[var_name]
        if dim_name not in var.dimensions:
            selected_vars.append(var)
    return selected_vars

def check_if_reduce_needed(vars_to_modify):
    """Return True if variable has missing start and end"""
    for var in vars_to_modify:
        if len(var.dimensions) > 2 and var[0,0,:].mask.all() and \
                var[-1,1,:,:].mask.all():
            return True
    return False

def remove_dimension(nc, dim_name, outfile=None):

    vars_to_modify = find_variables_with_dimension(nc, dim_name)
    vars_to_copy = find_variables_without_dimension(nc, dim_name)
    reduce_needed = check_if_reduce_needed(vars_to_modify)
    if outfile is None:
        outfile = 'tmp' + str(random.randint(1,1000)) + '.nc'
    tmp_nc = Dataset(outfile, 'w')
    # First copy global attrs
    copync.copy_global_attrs(nc, tmp_nc)
    # Then copy dimensions minus unwanted
    copync.copy_dimensions(nc, tmp_nc, ignore=['time',dim_name])
    if 'step' in nc.dimensions:
        if reduce_needed:
            tmp_nc.createDimension('time', (nc.dimensions['time'].size * nc.dimensions['step'].size) - 2)
        else:
            tmp_nc.createDimension('time', nc.dimensions['time'].size * nc.dimensions['step'].size )

    else:
        tmp_nc.createDimension('time', nc.dimensions['time'].size)
    if len(vars_to_modify) == 0: # not in dimensions, but need to get rid of step vars
        err_str = "'" + dim_name + "' is not in any of the variables."
        #raise Exception(err_str)
        time_var = None
        valid_var = None
        for var in vars_to_copy:
            if var.name != 'time' and var.name != 'step' and var.name != 'valid_time':
                copync.copy_variable(nc, tmp_nc, var.name)
            elif var.name == 'time':
                time_var = var
            elif var.name == 'valid_time':
                valid_var = var
        new_var = tmp_nc.createVariable('time', valid_var.dtype, ('time',))
        copync.copy_var_attrs(valid_var, new_var)
        new_var[:] = valid_var[:]
        tmp_nc.close()
        return outfile
    # Next, copy unchanged vars
    time_var = None
    for var in vars_to_copy:
        if var.name != 'time':
            copync.copy_variable(nc, tmp_nc, var.name)
        else:
            time_var = var


    for var in vars_to_modify:
        # If described by only unwanted dimension, then remove variable.
        if len(var.dimensions) == 1:
            # Remove variable
            pass
        else:
            # find dim index
            dims = var.dimensions
            dims_list = list(dims)
            shape = var.shape
            shape_list = list(shape)
            idx = dims.index(dim_name)

            if idx == 0:
                print('Need to implement')
                print('Exiting.')
                exit(1)

            size = shape_list.pop(idx)
            dims_list.pop(idx)
            dims = tuple(dims_list)
            shape_list[idx-1] = shape_list[idx-1]*size

            new_data = var[:].reshape(*shape_list)
            if reduce_needed:
                if len(dims) == 1:
                    new_data = new_data[1:-1]
                elif len(dims) > 1:
                    new_data = new_data[1:-1,:,:]
            varname = var.name
            if varname == 'valid_time':
                varname = 'time'

            new_var = tmp_nc.createVariable(varname, var.dtype, dims)
            copync.copy_var_attrs(var, new_var)
            new_var[:] = new_data


    tmp_nc.close()
    return outfile



if __name__ == '__main__':
    if len(sys.argv) <= 2:
        usage()
    nc_file = sys.argv[1]
    dim_name = sys.argv[2]
    nc = Dataset(nc_file)
    outfile = remove_dimension(nc, dim_name)
    os.rename(outfile, nc_file)


