#!/usr/bin/env python
"""Basically a wrapper around nccopy,
however it will aslo return the Dataset filehandle
"""

from netCDF4 import Dataset
from subprocess import call

def copy(filename, new_filename):
    rc = call(['nccopy',filename, new_filename])
    if rc != 0:
        print("nccopy failed")
        exit(1)

    return Dataset('new_filename', 'r+')


