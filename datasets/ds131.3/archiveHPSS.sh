#!/bin/bash

if [[ -z $1 ]]; then
    echo "please give year"
    exit 1
fi
year=$1

find $year/anl -type f > memberlists/${year}_anl_memberlist.txt
find $year/fg -type f > memberlists/${year}_fg_memberlist.txt
find $year/sflx -type f > memberlists/${year}_anl_6hr_memberlist.txt

dsarch 131.3 -AM -GX -DF hdf5nc4 -GN TS_AN -HM -LL memberlists/${year}_anl_memberlist.txt -MF ${year}_anl.HTAR
dsarch 131.3 -AM -GX -DF hdf5nc4 -GN TS_FG -HM -LL memberlists/${year}_fg_memberlist.txt -MF ${year}_fg.HTAR
dsarch 131.3 -AM -GX -DF hdf5nc4 -GN TS_AN_6H -HM -LL memberlists/${year}_anl_6hr_memberlist.txt -MF ${year}_anl_6h.HTAR
