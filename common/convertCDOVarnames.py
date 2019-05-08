#!/bin/bash
import sys, os
import yaml
from netCDF4 import Dataset
"""
Gives CDO varable names readable names and metadata based on the provided table
"""
nc_file = sys.argv[1]
nc = Dataset(nc_file)

# load yaml
table_dict = yaml.load('table2')

vars = nc.variables.keys()
for var in filter(lambda x: 'var' in x, mmk):
    nc_var = nc.variables[var]
    num = var.strip('var').zfill(3)
    metadata = table_dict[num]
    print(metadata)


