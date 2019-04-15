#!/usr/bin/env python
import sys, os
from subprocess import call, Popen, PIPE
import pdb

def getParams(files):
    num_files = len(files)
    # Query files until there're no additions
    done = False
    idx = 0
    all_params = set()
    while not done:
        cur_file = files[idx]
        process = Popen(['getGribVariableNames.sh', cur_file], stdout=PIPE)
        out, err = process.communicate()
        params = out.decode('utf-8').split('\n')
        params.pop()
        params = set(params)
        if len(params.symmetric_difference(all_params)) > 0:
            all_params = all_params.union(params)
        else:
            done = True
        idx += 1
        if idx == num_files:
            done = True
    return all_params

files = sys.argv
files.pop(0) # Remove name of program

params = getParams(files)
print(params)


for grb_file in files:
    for param in params:
        pass

