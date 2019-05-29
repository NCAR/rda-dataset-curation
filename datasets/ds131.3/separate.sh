#!/bin/bash
#
# Separates grib2 file given input file
#
#

inputFile=$1 # File that contains regexes
ingrib=$2 # Grib file to separate
outgrib1=$3 # First output grib filename (Those that match the grep)
outgrib2=$4 # Second output grib filename (Those that do Not match the grep)


# First get the inventory
inventory="inventory$RANDOM"
newInventory="newInventory$RANDOM"
wgrib2 $ingrib > $inventory

while read -r line; do
    echo $line

    grep "$line" $inventory >> $newInventory
    rc=$?
    echo $rc
    if [[ $rc -eq 1 ]]; then
        echo "$line not found in grib file"
        exit 1
    fi
    grep -v "$line" $inventory > "tmp$inventory"
    mv "tmp$inventory" $inventory
done < $inputFile

#rm $inventory




