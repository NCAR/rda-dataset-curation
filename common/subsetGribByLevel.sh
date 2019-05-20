#!/bin/bash
#########
#
# Given 1 or more grib files, this program will attempt create/append each parameter to an individual file.
#
########
#
# Usage : ./subsetGrib  [--nolevel] [-o/--outdir out_dir] [grib_file1, grib_file2, ... ]
#            grib_file      :  File to process. Can be grib 1 or 2
#           -o  --outdir    :
#
#########
usage()
{
    echo "subsetGribLevels.sh"
    echo "-------------"
    echo "Given 1 or more grib files, this program will attempt create/append grib messages with"
    echo "similar levels to an individual file."
    echo
    echo "Usage : ./subsetGrib  [-o/--outdir out_dir] [grib_file1, grib_file2, ... ]"
    echo "            grib_file       :  File to process. Can be grib 1 or 2"
    echo "            -o  --outdir    :  Directory to place files. Defaults to ./"
    echo
    exit 1
}
separateWgribLevels()
{
    IFS=$'\n' # Make separator \n
    file=$1
    outdir=$2
    fileBasename=`basename $file`
    inventory="inventory$RANDOM"
    wgrib $file > $inventory
    levels=`cat $inventory | awk -F: '{print $12}' | sort -u`
    echo "levels are"
    echo "$levels"
    # change outfile depending on the level--is a regex
    grepLevels=("sfc" "10 m above"    "1*2 m above|[2-9]0 m above|[1-9]00 m above" "cm down"  "sigma" "isotherm" "tropopause" "mb:"  'K$'      'MSL' 'atmos col' 'convect-cld'       'nom. top' 'bndary-layer' 'high cld' 'low cld' 'mid cld' '300K|350K|330K')
    grepLevelsName=("sfc" "10m" "height" "depth_cm" "sigma" "isotherm" "tropopause" "pres" 'K_level' 'msl' 'atmos-col' 'convect-cld-layer' 'nom_top'  'boundary_layer' 'high_cld' 'low_cld' 'mid_cld' 'K')
    levels_len=${#grepLevels[@]}
    echo "len $levels_len"
    totLines=0
    totInv=`cat $inventory | wc -l`
    for(( i=0; i<$levels_len; i++ )); do
        outfile=$outdir`echo $fileBasename | sed "s/All_Levels/${grepLevelsName[$i]}/"`
        tmpInv="tmpInv$RANDOM"
        cat $inventory | egrep ${grepLevels[$i]} > $tmpInv
        invLen=`cat $tmpInv | wc -l`
        totLines=$(( invLen + totLines ))
        if [[ $invLen -gt 0 ]]; then
            echo $invLen
            echo $totLines
        fi
        if [[ $invLen -ne 0 ]]; then
            cat $tmpInv | wgrib -i $file -grib -append -o $outfile >/dev/null 2>&1
        fi
    rm $tmpInv
    done
        if [[ $totLines -eq $totInv ]]; then
            echo "i is $i"
            rm $inventory
            break;
        fi
    echo $totLines
    echo $totInv
    if [[ $totLines -ne $totInv ]]; then
        echo "off"
        exit 1
    fi
}
separateWgrib2Levels()
{
    IFS=$'\n' # Make separator \n
    file=$1
    outdir=$2
    fileBasename=`basename $file`
    inventory="inventory$RANDOM"
    wgrib2 $file > $inventory
    levels=`cat $inventory | awk -F: '{print $5}' | sort -u`
    echo "levels are"
    echo "$levels"
    # change outfile depending on the level--is a regex
    grepLevels=(":2 m"    "surface" '10 m above' "1*2 m above|[2-9]0 m above|[1-9]00 m above"  "m below"  "sigma"       "isotherm" "tropopause" 'mb:' 'K$' 'MSL' 'entire atmosphere' 'top of atmosphere' 'boundary layer' 'low cloud' 'middle cloud' 'high cloud' 'convective cloud' '300 K|350 K|330 K')
    grepLevelsName=("2m"  "sfc"     '10m' "height"     "depth_cm"     "sigma-level" "isotherm" "tropopause" "mb"  'K'  'MSL' 'atmos_col'         'nom_top'           'boundary_layer' 'low_cld'   'middle_cld'   'high_cld'   'convective_cld' 'K')
    levels_len=${#grepLevels[@]}
    echo "len $levels_len"
    totLines=0
    totInv=`cat $inventory | wc -l`
    for(( i=0; i<$levels_len; i++ )); do
        outfile=$outdir`echo $fileBasename | sed "s/All_Levels/${grepLevelsName[$i]}/"`
        cat $inventory | egrep ${grepLevels[$i]} > tmpInv
        invLen=`cat tmpInv | wc -l`
        totLines=$(( invLen + totLines ))
        if [[ $invLen -gt 0 ]]; then
            echo $outfile
            echo $invLen
            echo $totLines
        fi
        if [[ $invLen -ne 0 ]]; then
            echo $outfile
            cat tmpInv | wgrib2 -i $file  -append  -grib $outfile >/dev/null 2>&1
        fi

    done
        if [[ $totLines -eq $totInv ]]; then
            echo "i is $i"
            rm $inventory
            break;
        fi
    echo $totLines
    echo $totInv
    if [[ $totLines -ne $totInv ]]; then
        echo "off"
        exit 1
    fi
    rm $inventory
}
if [[ $# -lt 1 ]]; then # Check if there are enough arguments (need at least 1 file)
    usage
fi
outdir="./"
files=""
# extract options and their arguments into variables.
while [[ $@ ]]; do
    case "$1" in
        -o|--outdir)
            outdir=$2
            shift 2 ;;
        *) files="$files $1"; shift ;;
    esac
done
if [[ -z $files ]];then
    echo "No input files, exiting"
    exit 1
fi
if [[ `echo $outdir | grep -o ".$"` != '/' ]]; then
    outdir="${outdir}/"
fi
echo "Settings"
echo "--------"
echo "Combine Level    : $combineLevelStr"
echo "Output Directory : $outdir"
echo "Files to Process : $files"

echo

scriptDir=`dirname "$0"`

for file in $files; do
    echo "Processing -- $file"

    # Get correct grib decoder
    isGrib=`$scriptDir/isGrib1.py $file`
    if [[ $isGrib == 'True' ]]; then
        wgrib=`which wgrib`
        echo "Using wgrib"
        separateWgribLevels $file $outdir

    elif [[ $isGrib == 'False' ]]; then
        wgrib=`which wgrib2`
        echo "Using wgrib2"
        separateWgrib2Levels $file $outdir
    else
        echo "ERROR: $file is not a grib file"
        echo "exiting"
        exit 1
    fi
done





