This directory provides test cases for code found in the `common/` and `datasets/` directories.

# Useful testing utilities

## create_test_nc_file.py

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

### Basic Example
```
$ ./create_test_nc_file.py 
test1.nc
$ ncdump -h test1.nc 
netcdf test1 {
dimensions:
    A = 10 ;
    B = 10 ;
    C = 10 ;
variables:
    double A(A) ;
    double B(B) ;
    double C(C) ;
    double Test(A, B, C) ;
}
```
### Exmple with arguments
```
rda-dataset-curation/test> ./create_test_nc_file.py -fn 'my_test.nc' -n 2 -dl 180 -v 'temperature'
my_test.nc
rda-dataset-curation/test> ncdump -h my_test.nc 
netcdf my_test {
dimensions:
    A = 180 ;
    B = 180 ;
variables:
    double A(A) ;
    double B(B) ;
    double temperature(A, B) ;
}
```
