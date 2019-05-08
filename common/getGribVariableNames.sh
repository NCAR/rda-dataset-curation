#!/bin/bash
#
# Returns unique variable names from a grib1 or grib2 file
#
# Usage
# getGribVariableName [file]
#
usage()
{
    echo "Usage:"
    echo " $0 [file]"
    exit 1
}
if [[ -z $1 ]]; then
    usage
fi

file=$1

# First find if file needs wgrib or wgrib2
isGrib1=`./isGrib1.py $file`
rc=$?
if [[ $isGrib1 == 'True' ]]; then
    wgrib=`which wgrib`
elif [[ $isGrib1 == 'False' ]]; then
    wgrib=`which wgrib2`
else
    echo "$file is not grib file"
    exit 1
fi

$wgrib $file | awk -F: '{print $4}' | sort -u







