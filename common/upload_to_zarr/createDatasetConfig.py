#!/usr/bin/env python
"""
Creates a configuration for a given directory
"""
#import zarr
from netCDF4 import Dataset
import xarray
import yaml
import sys
import pdb
from collections import OrderedDict

def usage():
    print("Usage:")
    print(sys.argv[0] + " [Files]")
    exit(1)

def zip_iterable(iter1, iter2):
    out_dict = {}
    for i,j in zip(iter1, iter2):
        out_dict[i] = j
    return out_dict


def get_config_dict(variable):
    """
    Get default configuration dictionary object
    """
    obj = {}
    obj['name'] = variable.name
    obj['dims'] = zip_iterable(variable.dims, variable.shape)
    obj['chunk'] = zip_iterable(variable.dims, variable.shape)
    return obj

def check_variable_exists(variables, var_name, dims):
    """Checks if you need to add variable.
    Returns 0 if found, otherwise returns next i"""
    i = 1
    while var_name in variables:
        if variables[var_name]['dims'].keys() == list(dims):
            return 0
        var_name += str(i)
        i += 1
    return i

def extract_ds_info(variables, filename):
    """Add filename variables to in_dict.
    """
    ds = xarray.open_dataset(filename)
    for var_name in ds.variables.keys():
        variable = ds[var_name]
        if var_name not in variables:
            variables[var_name] = get_config_dict(variable)
        else:
            i = check_variable_exists(variables, var_name, variable.dims)
            if i > 0:
                new_var_name = var_name+str(i)
                variables[new_var_name] = get_config_dict(variable)

class LastUpdatedOrderedDict(OrderedDict):
    'Store items in the order the keys were last added'

    def __setitem__(self, key, value):
        if key in self:
            del self[key]
        OrderedDict.__setitem__(self, key, value)

if __name__ == "__main__":
    if len(sys.argv) <= 1:
        usage()

    filenames = sys.argv[1:]


    variables = {}
    for filename in filenames:
        extract_ds_info(variables, filename)

    # Make variables a collection of objects
    config = list(variables.values())

    with open('config.yaml', 'w') as fh:
        yaml.dump(config, fh, default_flow_style=False)

