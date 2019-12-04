#!/usr/bin/env python
"""
Creates a configuration for a given directory
"""
#import zarr
import sys
import os
from netCDF4 import Dataset
import xarray
import yaml
import pdb
import json
import argparse

def get_arguments():
    """Parses arguments and returns arguments.
    """
    description = "Creates a default configuration file for a dataset or data files."
    parser = argparse.ArgumentParser(prog=sys.argv[0], description=description)
    parser.add_argument('--json', required=False, help="Use JSON output.", action='store_true')
    parser.add_argument('--yaml', required=False, help="Use YAML output.", action='store_true')
    parser.add_argument('--skip_errors', required=False, help="Errors do not end program.", action='store_true')
    parser.add_argument('--title', required=False, help="Specify Title.")
    parser.add_argument('--append_dim', required=False, nargs="+", default='time', help="Dimension to append to.")
    parser.add_argument('--chunk_size', required=False, default='10MB', help="Desired Chunk size. Example: 10MB, 5GB, 10KB, etc")
    parser.add_argument('files', nargs="+", help="Files or directory to scan.")
    return parser.parse_args()


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
    obj['attrs'] = {}
    return obj

def parse_chunk_size(chunk_size_str):
    """Attempts to parse chunk size into bytes."""
    chunk_size_str = chunk_size_str.upper()
    size_factors =
    {
            "B" : 1,
            "KB" : 1000,
            "MB" : 1000**2,
            "GB" : 1000**3,
            "TB" : 1000**4,
            }
    format = chunk_size_str[-2:]
    value = chunk_size_str[:-2]
    if format not in size_factors:
        raise ValueError(format+" not in +"size_factors.keys())
    scaled_value = int(value) * size_factors(format)
    return scaled_value

def check_variable_exists(variables, var_name, dims):
    """Checks if you need to add variable.
    Returns 0 if found, otherwise returns next i"""
    i = 1
    while var_name in variables:
        if list(variables[var_name]['dims'].keys()) == list(dims):
            return 0
        var_name += str(i)
        i += 1
    return i

def extract_ds_info(variables, filename):
    """Add filename variables to in_dict.
    """
    ds = xarray.open_dataset(filename)
    for var_name in ds.data_vars.keys():
        variable = ds[var_name]
        if var_name not in variables:
            variables[var_name] = get_config_dict(variable)
        else:
            i = check_variable_exists(variables, var_name, variable.dims)
            if i > 0:
                new_var_name = var_name+str(i)
                variables[new_var_name] = get_config_dict(variable)

def get_files_from_dir(directory):
    """Given directory, return a list of files.
    """
    files = []
    for path in os.walk(directory):
        dirpath = path[0]
        dirnames = path[1]
        filenames = path[2]
        if len(filenames) == 0:
            continue
        for f in filenames:
            files.append(dirpath+'/'+f)
    return files

if __name__ == "__main__":
    args = get_arguments()
    filenames = args.files
    if args.json and args.yaml:
        print("both yaml and json selected, defaulting to json")
        args.yaml = False
    if not args.json and not args.yaml:
        args.json = True

    if args.json:
        ext = '.json'
    elif args.yaml:
        ext = '.yaml'
    if args.title is not None:
        config_filename = args.title+ext
    else:
        config_filename = args.files[0]+ext

    variables = {}
    for filename in filenames:
        if os.path.isdir(filename):
            filenames.extend(get_files_from_dir(filename))
            continue
        print("processing "+filename)
        extract_ds_info(variables, filename)

    # Make variables a collection of objects
    config = list(variables.values())

    with open(config_filename, 'w') as fh:
        if args.json:
            json.dump(config, fh, indent=4)
        elif args.yaml:
            yaml.dump(config, fh, default_flow_style=False)

