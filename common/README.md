This directory contains common routines that may be useful in dataset curation. It has generic format, metadata, and convenience scripts. 

# Table of Contents
- [compareNetCDFData](#comparenetcdfdata)
  + [Usage](#usage)
  + [Example](#example)
- [collateByDimension](#collateByDimension)
  + [Usage](#usage-1)
  + [Example](#example-1)
- [isGrib1](#isGrib1)
  + [Usage](#usage-2)
  + [Example](#example-2)

## compareNetCDFData
Used to compare two netCDF files to test for equivalence.

### Usage
```
$ ./compareNetCDFData.py -h
usage: compareNetCDFData [-h] [-v1 V1] [-v2 V2] file1 file2

Compares two netCDF file's variables. Prints 'True' or 'False'. And, Returns 0
for true and 1 for false. Does not handle NetCDF groups

positional arguments:
  file1       Specify the name of first netCDF file
  file2       Specify the name of second netCDF file

optional arguments:
  -h, --help  show this help message and exit
  -v1 V1      Specify the name of the variable in first file
  -v2 V2      Specify the name of the variable in second file
```
### Example
```
# Assuming there is netCDF file called test.nc
$ cp test.nc test2.nc
$ ./compareNETCDFData.py test.nc test2.nc
True
$ echo $?
0
```

## collateByDimension

### Usage
```
$ ./collateByDimension --help
usage: collateByDimension [-h] --dimname DIMNAME [--varname VARNAME]
                          [--outfile OUTFILE]
                          [files [files ...]]

concatonates variable in netCDF file by dimension

positional arguments:
  files

optional arguments:
  -h, --help            show this help message and exit
  --dimname DIMNAME, -dn DIMNAME
                        Specify the name of the dimension to collate
  --varname VARNAME, -vn VARNAME
                        Specify the name of the variable to collate
  --outfile OUTFILE, -o OUTFILE
                        Specify the name of the output filename
```
### Example
```TODO```

## isGrib1

### Usage
```
rda-dataset-curation/common> ./isGrib1.py 
Usage: isGrib1 [file]
    Determines whether the given file is a grib1 file.

    Prints True (return code 0)
    Prints False (return code 1)
    Return code 99 if neither, or error
```
### Example
```
```
