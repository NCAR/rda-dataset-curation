This directory provides test cases for code found in the `common/` and `datasets/` directories.

# Useful testing utilities
```create_test_nc_file.py```

### Usage
```
usage: create_test_nc_file [-h] [--filename FILENAME] [--num-dims NUM_DIMS]
                           [--dim-length DIM_LENGTH] [--varname VARNAME]

Creates a test netcdf file.

optional arguments:
  -h, --help            show this help message and exit
  --filename FILENAME, -fn FILENAME
                        Specify output filename
  --num-dims NUM_DIMS, -n NUM_DIMS
                        Specify number of dimensions
  --dim-length DIM_LENGTH, -dl DIM_LENGTH
                        Specify length of dimensions
  --varname VARNAME, -v VARNAME
                        Specify primary variable's name
```
