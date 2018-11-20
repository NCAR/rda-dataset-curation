#!/usr/bin/env python
"""Basically a wrapper around nccopy/ncks,
however it will aslo return the Dataset filehandle
"""

from netCDF4 import Dataset
from subprocess import call
import pdb

def copy(filename, new_filename, *removeVars):
    if len(removeVars) == 0:
        copy_nccopy(filename, new_filename)
    else:
        copy_ncks(filename, new_filename, removeVars)
    return Dataset(new_filename, 'r+')

def copy_nccopy(filename, new_filename):
    try:
        rc = call(['nccopy',filename, new_filename])
        if rc != 0:
            print("nccopy failed, exiting")
            exit(1)
    except:
        print("nccopy not found, trying ncks")
        copy_ncks(filename, new_filename)

def copy_ncks(filename, new_filename, removeVars=[]):
    if len(removeVars) == 0:
        try:
            rc = call(['ncks',filename, new_filename])
        except Exception as e:
            print(e)
            print("Try 'module load nco' or add ncks to your PATH")
            exit(1)
        if rc != 1:
            print("ncks failed")
            exit(1)
        else:
            exit(0)
    # or, if there are variables to remove
    try:
        rc = call(['ncks','-C','-x','-v',','.join(removeVars),filename, new_filename])
    except FileNotFoundError as e:
        print(e)
        print("Try 'module load nco' or add ncks to your PATH")
        exit(1)
    if rc != 0:
        print("ncks failed, exiting")
        exit(1)



