from netCDF4 import Dataset
import sys, os

nc_file = '/glade/scratch/rpconroy/rda-dataset-curation/datasets/ds131.3/1836/sflx/sflx_spread_1836_ALBDO_sfc.nc'


def usage():
    pass

def find_variables_with_dimension(nc, dim_name):
    selected_vars = []
    for var_name in nc.variables:
        var = nc.variables[var_name]
        if dim_name in var.dimensions
            selected_vars.push(var)
    return selected_vars


def remove_dimension(nc, dim_name):
    vars_to_modify = find_variables_with_dimension()
    if len(vars_to_modify) == 0:
        err_str = "'" dim_name + "' is not in any of the variables."
        raise Exception(err_str)

    for var in vars_to_modify:
        # If described by only unwanted dimension, then remove variable.
        if len(var.dimensions) == 1:



if __name__ == '__main__':
    dim_name = sys.argv[1]
    nc = Dataset(nc_file, 'a')
    remove_dimensions(nc, dim_name)


