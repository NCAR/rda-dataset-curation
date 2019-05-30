#!/bin/bash
printDelimiter()
{
    printf '<:>'
}
count=111; # Some starting index
# First Anl
for filename in `ls -1 1836/anl/*.nc`; do
    i=`echo $filename | awk -F'1836_' '{print $2}' | sed 's/\.nc//'`
    printf "${count}"
    printDelimiter
    printf 'TS_AN-'
    printf $i
    printDelimiter
    printf '1' # 1 for the analysis group
    printDelimiter
    # Get longname
    long_name=`ncdump -h $filename | grep long_name | tail -1 | grep -o "\".*\"" | sed 's/"//g'`
    level=`ncdump -h $filename | grep typeOfLevel | tail -1 | grep -o "\".*\"" | sed 's/"//g'`
    printf "$long_name ($level)"
    printDelimiter
    printf '*'
    printf "${i}.nc"
    printDelimiter
    printDelimiter
    printDelimiter
    count=$(( $count + 1 ))
    echo
done
# Then FG
count=$(( count + 50 ))
for filename in `ls -1 1836/fg/*.nc`; do
    i=`echo $filename | awk -F'fhr06_' '{print $2}' | sed 's/\.nc//'`
    printf "${count}"
    printDelimiter
    printf 'TS_FG-'
    printf $i
    printDelimiter
    printf '1' # 1 for the analysis group
    printDelimiter
    # here would go the description
    long_name=`ncdump -h $filename | grep long_name | tail -1 | grep -o "\".*\"" | sed 's/"//g'`
    level=`ncdump -h $filename | grep typeOfLevel | tail -1 | grep -o "\".*\"" | sed 's/"//g'`
    printf "$long_name ($level)"
    printDelimiter
    printf '*'
    printf "${i}.nc"
    printDelimiter
    printDelimiter
    printDelimiter
    count=$(( $count + 1 ))
    echo
done
