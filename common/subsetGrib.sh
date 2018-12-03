#!/bin/bash
#########
#
# Given 1 or more grib files, this program will attempt create/append each parameter to an individual file.
#
########
#
# Usage : ./subsetGrib  [--nolevel] [-o/--outdir out_dir] [grib_file1, grib_file2, ... ]
#            grib_file      :  File to process. Can be grib 1 or 2
#           -n  --nolevel   :  Don't combine level into one grib
#           -o  --outdir    :
#
#########
usage()
{
    echo "subsetGrib.sh"
    echo "-------------"
    echo "Given 1 or more grib files, this program will attempt create/append each parameter to an individual file."
    echo
    echo "Usage : ./subsetGrib  [--nolevel] [-o/--outdir out_dir] [grib_file1, grib_file2, ... ]"
    echo "            grib_file       :  File to process. Can be grib 1 or 2"
    echo "            -n  --nolevel   :  Don't combine level into one grib"
    echo "            -o  --outdir    :  Directory to place files. Defaults to ./"
    echo
    exit 1
}
separateWgribParams()
{
    IFS=$'\n' # Make separator \n
    file=$1
    outdir=$2
    fileBasename=`basename $file | sed 's/_[0-9]*//g'`
    echo "basename is $fileBasename"
    params=`wgrib $file | awk -F: '{print $4}' | sort -u`
    for param in $params; do
        echo "separating $param"
        outfile="${outdir}${fileBasename}_${param}_All_Levels"
        wgrib $file | grep $param | wgrib -i $file -grib -append -o $outfile
    done
}
separateWgribLevels()
{
    IFS=$'\n' # Make separator \n
    file=$1
    outdir=$2
    fileBasename=`basename $file`
    levels=`wgrib $file | awk -F: '{print $12}' | sort -u`
    echo "levels are"
    echo $levels
    # change outfile depending on the level--is a regex
    grepLevels=("sfc" "m above" "cm down" "sigma" "isotherm" "tropopause" "mb" 'K$' 'MSL' 'atmos col' 'convect-cld' )
    levels_len=${#grepLevels[@]}
    echo "len $levels_len"
    for level in $levels; do
        for(( i=0; i<$levels_len; i++ )); do

            echo "||${grepLevels[$i]}||"
            echo "||$level||"
            echo $level | grep "${grepLevels[$i]}"
            rc=$?
            if [[ $rc -eq 0 ]]; then
                outfile=$outdir`echo $fileBasename | sed "s/All_Levels/${grepLevels[$i]}/"`
                wgrib $file | grep $level | wgrib -i $file -grib -append -o $outfile
                break
            fi
        done
    done
}
separateWgrib2()
{
    file=$1
}
if [[ $# -lt 1 ]]; then
    usage
fi
combineLevel=0
outdir="./"
files=""
# extract options and their arguments into variables.
while [[ $@ ]]; do
    case "$1" in
        -o|--outdir)
            outdir=$2
            shift 2 ;;
        -n|--nolevel) combineLevel=1; shift ;;
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
combineLevelStr="False"
scriptDir=`dirname "$0"`
if [[ $combineLevel -eq 1 ]]; then combineLevelStr="True"; fi
echo "Settings"
echo "--------"
echo "Combine Level    : $combineLevelStr"
echo "Output Directory : $outdir"
echo "Files to Process : $files"
echo "Common/ dir      : $scriptDir"

echo


for file in $files; do
    echo "Processing -- $file"

    # Get correct wgrib decoder
    isGrib=`$scriptDir/isGrib1.py $file`
    if [[ $isGrib == 'True' ]]; then
        wgrib=`which wgrib`
        echo "Using wgrib"
        separateWgribParams $file $outdir
        #separateWgribLevels $file $outdir

    elif [[ $isGrib == 'False' ]]; then
        wgrib=`which wgrib2`
        echo "Using wgrib2"
        separateWgrib2 $file
    else
        echo "ERROR: $file is not a grib file"
        echo "exiting"
        exit
    fi


done





