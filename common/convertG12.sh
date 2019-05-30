#!/bin/bash
#
# Reliably convert grib1 to grib2
#


ingrib=$1
outgrib=$2

numMsgs=`wgrib $ingrib | wc -l`

if [[ $numMsgs -le 8000 ]]; then
    cnvgrib -g12 -p0 -nv ${ingrib} ${outgrib}
    exit 0
fi
counter=0
startIdx=8000
while [[ $numMsgs -gt 8000 ]]; do
    wgrib $ingrib | head -$startIdx | tail -8000 | wgrib -i $ingrib -grib -o ${ingrib}.${counter}
    numMsgs=$(( $numMsgs - 8000 ))
    startIdx=$(( $startIdx + 8000 ))
    counter=$(( $counter + 1 ))
wgrib $ingrib | tail -$numMsgs | wgrib -i $ingrib -grib -o ${ingrib}.${counter}

done
for (( i=0; i<=$counter; i++ )); do
    cnvgrib -g12 -p0 -nv ${ingrib}.$i ${ingrib}.grb2.$i
    cat ${ingrib}.grb2.$i >> $outgrib
done
