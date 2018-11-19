#!/bin/bash

file1=`python create_test_nc_file.py`
file2=`python create_test_nc_file.py`
file3=`python create_test_nc_file.py`
testFile="test.nc"
echo $file1
echo $file2
echo $file3
echo $testFile
../common/collateByDimension.py -dn B -varname Test -outfile $testFile
rm $file1
rm $file2
rm $file3
rm $testFile

