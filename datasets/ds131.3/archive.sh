#!/bin/bash


if [[ -z $1 ]]; then
    echo "No year given"
    echo "Usage:"
    echo "    $0 [year]"
    exit 1
fi

year=$1

# Analysis
echo "Starting ANL"
for file in $year/anl/*.nc; do
    bn=`basename $file`
    groupname=`echo $bn | awk -F"${year}_" '{print $2}' | sed 's/\.nc//'`

    echo "dsarch -DS ds131.3 -AW -GX -OE -GN TS_AN-$groupname -DF hdf5nc4 -LF $file"
    dsarch -DS ds131.3 -AW -GX -OE -GN TS_AN-$groupname -DF hdf5nc4 -LF $file
done
# First Guess
echo "Starting FG"
for file in $year/fg/*.nc; do
    bn=`basename $file`
    groupname=`echo $bn | awk -F"${year}_" '{print $2}' | sed 's/\.nc//'`

    echo "dsarch -DS ds131.3 -AW -GX -OE -GN TS_FG-$groupname -DF hdf5nc4 -LF $file"
    dsarch -DS ds131.3 -AW -GX -OE -GN TS_FG-$groupname -DF hdf5nc4 -LF $file
done
# Surface Flux
echo "Starting SFLX"
for file in $year/sflx/*.nc; do
    bn=`basename $file`
    groupname=`echo $bn | awk -F"${year}_" '{print $2}' | sed 's/\.nc//'`

    echo "dsarch -DS ds131.3 -AW -GX -OE -GN TS_AN_6H-$groupname -DF hdf5nc4 -LF $file"
    dsarch -DS ds131.3 -AW -GX -OE -GN TS_AN_6H-$groupname -DF hdf5nc4 -LF $file
done
