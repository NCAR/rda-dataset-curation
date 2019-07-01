#!/bin/bash


if [[ -z $1 ]]; then
    echo "No year given"
    echo "Usage:"
    echo "    $0 [year]"
    exit 1
fi

year=$1

# First Guess
for file in $year/fg/*.nc; do
    bn=`basename $file`
    groupname=`echo $bn | awk -F"${year}_" '{print $2}' | sed 's/\.nc//'`

    echo "dsarch -DS ds131.3 -AW -GX -OE -GN TS_FG-$groupname -DF hdf5nc4 -LF $file"
    dsarch -DS ds131.3 -AW -GX -OE -GN TS_FG-$groupname -DF hdf5nc4 -LF $file
done
# Surface Flux
for file in $year/sflx/*.nc; do
    bn=`basename $file`
    groupname=`echo $bn | awk -F"${year}_" '{print $2}' | sed 's/\.nc//'`

    echo "dsarch -DS ds131.3 -AW -GX -OE -GN TS_SFLX-$groupname -DF hdf5nc4 -LF $file"
    dsarch -DS ds131.3 -AW -GX -OE -GN TS_SFLX-$groupname -DF hdf5nc4 -LF $file
done
# Analysis
for file in $year/anl/*.nc; do
    bn=`basename $file`
    groupname=`echo $bn | awk -F"${year}_" '{print $2}' | sed 's/\.nc//'`

    echo "dsarch -DS ds131.3 -AW -GX -OE -GN TS_AN-$groupname -DF hdf5nc4 -LF $file"
done
#dsarch -DS ds131.3 -AW -GX -OE -GN TS_SFLX-TMP_2m -DF hdf5nc4 -LF 1837/sflx/sflx_mean_1837_TMP_2m.nc
