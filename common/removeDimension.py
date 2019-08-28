#!/usr/bin/env python
from netCDF4 import Dataset
import copyNCVariable as copync
import sys, os
import random
import pdb
import numpy as np
import datetime as dt

#
#
#


def usage():
    print("Usage")
    print("    "+sys.argv[0]+" [filename] [dim name]")
    exit(1)

def change_fill_value(nc, var, former_fill_value=np.nan, new_fill_value=np.nan):
    """Requires variable to be copied."""
    if former_fill_value is np.nan:
        compare_func = np.isnan
    else:
        compare_func = lambda x: x == former_fill_value
    new_data = var[np.where(compare_func(var[:]))] = new_fill_value

    # Copy data
    outfile = 'tmp' + str(random.randint(1,10000)) + '.nc'
    tmp_nc = Dataset(outfile, 'w')
    copync.copy_variables(nc, tmp_nc,  ignore=[var.name])
    tmp_nc.createVariable(var.name, var.dtype, var.dimensions, fill_value=new_fill_value)
    copync.copy_var_attrs(valid_var, new_var)
    os.rename(outfile, nc.filepath())

def change_time_units(var):
    """Change the time unit from epoch time to hours since 1800"""
    century18 = dt.datetime(1800,1,1,0)
    #for i,j in enumerate(var[:]):
    #    date = dt.datetime.utcfromtimestamp(j)
    #    seconds = (date - century18).total_seconds()
    #    hours = int( seconds / 60 / 60 )
    #    var[i] = hours
    def change_unit(date):
        date = dt.datetime.utcfromtimestamp(date)
        seconds = (date - century18).total_seconds()
        hours = int( seconds / 60 / 60 )
        return hours

    vfunc = np.vectorize(change_unit)
    new_data = vfunc(var[:])
    var[:] = new_data
    setattr(var, 'standard_name', "time")
    setattr(var, 'long_name', "time")
    setattr(var, "units","hours since 1800-01-01 00:00:00.0")
    setattr(var, "calendar", "proleptic_gregorian")
    return var


def add_utc_date(nc, time_var):
    """ Adds human readable date variable.
    Assumes date is in seconds since epoch.
    time_var is netCDF.Variable object.
    """
    # Create Variable
    utc = nc.createVariable('utc_time', int, ('time'))
    setattr(utc, 'standard_name', "time")
    setattr(utc, 'long_name', "UTC date yyyy-mm-dd hh:00:00 as yyyymmddhh")
    setattr(utc, "units","Gregorian_year month day hour")

    toUTC = lambda d: int(dt.datetime.fromtimestamp(d).strftime('%Y%m%d%H'))
    vfunc = np.vectorize(toUTC)
    utc_data = vfunc(time_var[:])
    utc[:] = utc_data


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

def add_time_bounds(nc, varname):
    """
    Adds a time bounds variable to variable.
    Assumes time dimension is called 'time'
    """
    THREE_HOURS = 60*60*3 # in seconds
    bnds_name = 'time_bnds'
    bounds_dim = 'nv'

    # Create bounds dimension
    nc.createDimension(bounds_dim, 2)

    # Get variable matching varname

    time_var = nc.variables['time']
    time_var.setncattr('bounds', bnds_name)
    time_data = time_var[:]
    time_length = len(time_data)

    # reshape time data
    bounds_data = np.dstack((time_data,time_data)).reshape(time_length,2)
    for i in bounds_data:
        i[0] = i[0] - (THREE_HOURS)
    bounds_var = nc.createVariable(bnds_name, time_var.dtype, ('time', bounds_dim), fill_value=9999)
    bounds_var[:] = bounds_data



def add_cell_methods(nc):
    methods = {
            'avg' : 'mean',
            'accum' : 'sum',
            'min' : 'minimum',
            'max' : 'maximum'
            }
    step_str = 'GRIB_stepType'
    for i in nc.variables:
        var = nc.variables[i]
        if step_str in var.ncattrs() and 'instant' not in var.getncattr(step_str):
            if 'cell_methods' in var.ncattrs():
                cur_str = var.getncattr('cell_methods')
                var.setncattr('cell_methods', cur_str + " time: " + methods[var.getncattr(step_str)])
            else:
                pass
                #var.setncattr('cell_methods', "time: " + methods[var.getncattr(step_str)])


def change_coordinates(nc):
    for i in nc.variables:
        var = nc.variables[i]
        if 'coordinates' in var.ncattrs():
            coord_str = var.getncattr('coordinates')
            coord_str = coord_str.replace('valid_time', '')
            coord_str = coord_str.replace('step', '')
            if 'time' not in coord_str:
                coord_str += " time"
            coord_str = ' '.join(coord_str.split())
            var.setncattr('coordinates', coord_str)



def remove_dimension(nc, dim_name, outfile=None):

    vars_to_modify = find_variables_with_dimension(nc, dim_name)
    vars_to_copy = find_variables_without_dimension(nc, dim_name)
    reduce_needed = check_if_reduce_needed(vars_to_modify)
    if outfile is None:
        outfile = 'tmp' + str(random.randint(1,10000)) + '.nc'
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
        return (outfile, tmp_nc)
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
            step_str = 'GRIB_stepType'
            if step_str in new_var.ncattrs() and new_var.getncattr(step_str) is not 'instant':
                add_time_bounds(tmp_nc, new_var.name)


    return (outfile, tmp_nc)

def change_fill_value(nc, fill_value):
    """Changes fill value for all variables in file"""
    outfile = 'tmp' + str(random.randint(1,100000)) + '.nc'
    out_nc = copync.copy_dimensions(nc, outfile)
    copync.copy_variables(nc, out_nc, new_fill_value=fill_value)
    out_nc.close()
    return outfile


if __name__ == '__main__':
    if len(sys.argv) <= 2:
        usage()
    nc_file = sys.argv[1]
    dim_name = sys.argv[2]
    nc = Dataset(nc_file)
    if dim_name != "none":
        outfile,nc = remove_dimension(nc, dim_name)
    add_cell_methods(nc)
    change_coordinates(nc)
    add_utc_date(nc, nc.variables['time'])
    change_time_units(nc.variables['time'])
    if 'time_bnds' in nc.variables:
        change_time_units(nc.variables['time_bnds'])
    second_outfile = change_fill_value(nc, 9999)
    nc.close()
    os.remove(outfile)
    os.rename(second_outfile, nc_file)


