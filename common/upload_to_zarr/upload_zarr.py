#!/usr/bin/env python
import sys
sys.path.insert(0,'/glade/u/home/rpconroy/.local/lib/python3.6/site-packages/')
import xarray
import zarr
import argparse
import os
import json
import yaml

def get_arguments():
    """Parses arguments and returns arguments.
    """
    description = "Creates a default configuration file for a dataset or data files."
    parser = argparse.ArgumentParser(prog=sys.argv[0], description=description)
    parser.add_argument('--config', required=False, help="Specify configuration file ")
    parser.add_argument('--skip_errors', required=False, help="Errors do not end program.", action='store_true')
    parser.add_argument('--title', required=False, help="Specify Title.")
    parser.add_argument('files', nargs="+", help="Files or directory to scan.")
    return parser.parse_args()

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

def get_variable_config(config, var):
    pass


if __name__ == "__main__":

    args = get_arguments()
    title = "test"
    if args.title is not None:
        title = args.title
    filenames = args.files
    if args.config is not None:
        ext = args.config.split('.')[-1]
        if ext == 'json':
            config = json.load(open(args.config))
        elif ext == 'yaml':
            config = yaml.load(open(args.config))
        else:
            raise ValueError("config format not recognized")

    for filename in filenames:
        if os.path.isdir(filename):
            filenames.extend(get_files_from_dir(filename))
            continue
        ds = xarray.open_dataset(filename)
        ds.to_zarr(title+'.zarr', mode='a', append_dim='time')



