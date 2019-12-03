#!/usr/bin/env python
import sys
import zarr
import xarray
import argparse

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


if __name__ == "__main__":
    args = get_arguments()


    ds = xarray.open_dataset(filename)
    #mmk.chunk({})
    ds.to_zarr(filename+'.zarr')

