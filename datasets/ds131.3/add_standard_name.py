#!/usr/bin/env python
import sys
import yaml
import pdb
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

def add_standard_name(filename, attrs_dict):
    """Searches netcdf file for variables that do not have standard names
    and attempts to replace them from attrs dict.
    Uses existing long_name as key.
    """
    nc = Dataset(filename, 'r+')
    print('File loaded')
    for var_str in nc.variables:
        var = nc.variables[var_str]
        attrs = var.ncattrs()
        if 'long_name' in attrs and var.getncattr('long_name') in attrs_dict:
            # Try to add standard name if exists
            long_name = var.getncattr('long_name')
            attrs = attrs_dict[long_name]
            if attrs is None or attrs == '':
                err_msg = 'standard_name for '+long_name+' doesn\'t exist or is empty\n'
                sys.stderr.write(err_msg)
                continue
            if type(attrs) is str:
                var.setncattr('standard_name', attrs)
            elif type(attrs) is dict:
                for key,value in attrs.items():
                    var.setncattr(key, value)


        else:
            print('Either no long name or not in yaml file for '+ var.name)
    nc.close()


yaml_file = 'grib2attrs.yaml'
attrs = load_yaml(yaml_file)
print('yaml loaded')

if len(sys.argv) <= 1:
    sys.stderr.write('No netcdf file')
    exit(1)

add_standard_name(sys.argv[1], attrs)






