#!/bin/bash
#
# Separates grib2 file given input file
#
#

usage()
{
    echo "Usage:"
    echo "    ./separate [regexFile] [input grib2] [output filename (matching)] [output filename (unmatching)"
    exit 1
}

if [[ $# -lt 4 ]]; then
    usage
fi

inputFile=$1 # File that contains regexes
ingrib=$2 # Grib file to separate
outgrib1=$3 # First output grib filename (Those that match the grep)
outgrib2=$4 # Second output grib filename (Those that do Not match the grep)


common_dir="../../common/"
isGrib1="$common_dir/isGrib1.py"

grib1=`$isGrib1 $ingrib`
if [[ $grib1 == "True" ]]; then
    wgrib="wgrib"
else
    wgrib="wgrib2"
fi

# First get the inventory
inventory="inventory$RANDOM"
newInventory="newInventory$RANDOM"
$wgrib $ingrib > $inventory

while read -r line; do
    grep "$line" $inventory >> $newInventory
    rc=$?
    if [[ $rc -eq 1 ]]; then
        echo "$line not found in grib file"
        exit 1
    fi
    grep -v "$line" $inventory > "tmp$inventory"
    mv "tmp$inventory" $inventory
done < $inputFile
# At this point, both inventories should be different

# Now to actually separate
if [[ $grib1 == "False" ]]; then
    cat $newInventory | wgrib2 -i $ingrib -grib $outgrib1 >/dev/null
    cat $inventory | wgrib2 -i $ingrib -grib $outgrib2 >/dev/null
else
    cat $newInventory | wgrib -i $ingrib -grib -o $outgrib1 >/dev/null
    cat $inventory | wgrib -i $ingrib -grib -o $outgrib2 >/dev/null
fi

rm $inventory
rm $newInventory




