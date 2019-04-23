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

#######################################################
# Separates a single grib file into grib files based
# on unique parameters.
# Example:
# 1:64908676:d=36010200:VGRD:kpds5=34:kpds6=105:kpds7=10:TR=10:P1=0:P2=3:TimeU=1:10 m above gnd:3hr fcst:ensemble:std dev:NAve=0
# 2:65138153:d=36010200:V-GWD:kpds5=148:kpds6=1:kpds7=0:TR=3:P1=0:P2=3:TimeU=1:sfc:0-3hr ave:ensemble:std dev:NAve=0
#
# Would become 2 files: VGRD_All_Levels.grb and V-GWD_All_Levels.grb
#
separateWgribParams()
{
    IFS=$'\n' # Make separator \n
    file=$1
    outdir=$2
    fileBasename=`basename $file | sed 's/_[0-9]*//g' | sed 's/\.grb2//g' `
    echo "basename is $fileBasename"
    params=`wgrib $file | awk -F: '{print $4}' | sort -u` # Get all Params
    for param in $params; do
        echo "separating $param"

        outfile="${outdir}${fileBasename}_${param}_All_Levels.grb"
        wgrib $file | grep $param | wgrib -i $file -append -grib -o $outfile >/dev/null
    done
}
separateWgrib2Params()
{
    IFS=$'\n' # Make separator \n
    file=$1
    outdir=$2
    fileBasename=`basename $file | sed 's/_[0-9]*//g' | sed 's/\.grb2//g' `
    echo "basename is $fileBasename"
    params=`wgrib2 $file | awk -F: '{print $4}' | sort -u` # Get all Params
    for param in $params; do
        echo "separating $param"

        outfile="${outdir}${fileBasename}_${param}_All_Levels.grb"
        wgrib2 $file | grep $param | wgrib2 -i $file -append -grib $outfile >/dev/null
    done
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
    elif [[ $isGrib == 'False' ]]; then
        wgrib=`which wgrib2`
        echo "Using wgrib2"
        separateWgrib2Params $file $outdir
    else
        echo "ERROR: $file is not a grib file"
        echo "exiting"
        exit 1
    fi


done





