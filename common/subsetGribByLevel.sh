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
    wgrib $file > inventory
    levels=`cat inventory | awk -F: '{print $12}' | sort -u`
    echo "levels are"
    echo "$levels"
    # change outfile depending on the level--is a regex
    grepLevels=("sfc" "m above" "cm down" "sigma" "isotherm" "tropopause" "mb:" 'K$' 'MSL' 'atmos col' 'nom. top' 'cld|low cld|mid cld' '300K|350K|330K')
    grepLevelsName=("sfc" "height_m" "depth_cm" "sigma-level" "isotherm" "tropopause" "mb" 'K_level' 'MSL' 'atmos_col' 'convect_cld' 'nom_top' 'cld_lvl' 'K')
    levels_len=${#grepLevels[@]}
    echo "len $levels_len"
    totLines=0
    totInv=`cat inventory | wc -l`
    for(( i=0; i<$levels_len; i++ )); do
        outfile=$outdir`echo $fileBasename | sed "s/All_Levels/${grepLevelsName[$i]}/"`
        cat inventory | egrep ${grepLevels[$i]} > tmpInv
        invLen=`cat tmpInv | wc -l`
        totLines=$(( invLen + totLines ))
        if [[ $invLen -gt 0 ]]; then
            echo $invLen
            echo $totLines
        fi
        if [[ $invLen -ne 0 ]]; then
            cat tmpInv | wgrib -i $file -grib -append -o $outfile >/dev/null 2>&1
        fi

    done
        if [[ $totLines -eq $totInv ]]; then
            echo "i is $i"
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
    wgrib2 $file > inventory
    levels=`cat inventory | awk -F: '{print $5}' | sort -u`
    echo "levels are"
    echo "$levels"
    # change outfile depending on the level--is a regex
    grepLevels=("surface" "m above" "m below" "sigma" "isotherm" "tropopause" 'mb:' 'K$' 'MSL' 'entire atmosphere' 'top of atmosphere' 'cloud|cld|low cld|mid cld' '300 K|350 K|330 K')
    grepLevelsName=("sfc" "height_m" "depth_cm" "sigma-level" "isotherm" "tropopause" "mb" 'K_level' 'MSL' 'atmos_col' 'nom_top' 'cld_lvl' 'K')
    levels_len=${#grepLevels[@]}
    echo "len $levels_len"
    totLines=0
    totInv=`cat inventory | wc -l`
    for(( i=0; i<$levels_len; i++ )); do
        outfile=$outdir`echo $fileBasename | sed "s/All_Levels/${grepLevelsName[$i]}/"`
        cat inventory | egrep ${grepLevels[$i]} > tmpInv
        invLen=`cat tmpInv | wc -l`
        totLines=$(( invLen + totLines ))
        if [[ $invLen -gt 0 ]]; then
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
            break;
        fi
    echo $totLines
    echo $totInv
    if [[ $totLines -ne $totInv ]]; then
        echo "off"
        exit 1
    fi
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
        exit
    fi
done





