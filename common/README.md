
## compareNetCDFData
Used to compare 2 netCDF files to test for equivalence.

```
$ ./compareNetCDFData.py
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
