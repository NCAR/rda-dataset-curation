#!/usr/bin/env python
import sys
import yaml
from netCDF4 import Dataset
"""Searches netcdf file for variables that do not have standard names
and attempts to replace them from std_names dict.
Uses existing long_name as key.
"""

def load_yaml(filename):
    """Given filename, returns dict from yaml file
    """
    yaml_dict = None
    with open(filename, 'r') as stream:
        try:
            yaml_dict = yaml.safe_load(stream)
        except yaml.YAMLError as exc:
            print(exc)
            exit(1)
    return yaml_dict

def add_standard_name(filename, std_names):
    """Searches netcdf file for variables that do not have standard names
    and attempts to replace them from std_names dict.
    Uses existing long_name as key.
    """
    nc = Dataset(filename)
    for var_str in nc.variables:
        var = nc.variables[var_str]
        if 'standard_name' not in var and 'long_name' in var and 'long_name' in std_names:
            # Try to add standard name if exists
            long_name = var['long_name']
            std_name = std_names[long_name]
            if std_name std_name is None or std_name == '':
                err_msg = 'standard_name for '+long_name+' doesn\'t exist or is empty'
                sys.err.write(err_msg)
            var.setncattr('standard_name', std_name)


yaml_file = 'grib2standard_name.yaml'
std_names = load_yaml(yaml_file)

if len(sys.argv) <= 1:
    sys.stderr.write('No netcdf file')
    exit(1)

add_standard_name(sys.argv[1], std_names)






