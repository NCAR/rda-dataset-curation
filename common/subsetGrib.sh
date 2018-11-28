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
separateWgrib()
{
    IFS=$'\n' # Make separator \n
    file=$1
    inv=`wgrib $file`
    for i in $inv; do
        param=`echo $i | awk -F: '{print $4}'`
        echo $param
#wgrib pgrbenssprdanl_1981010103 | grep `cat param.junk | head -5 | tail -1` | wgrib -i pgrbenssprdanl_1981010103 -grib -append -o grb.out

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
outDir="./"
files=""
# extract options and their arguments into variables.
while [[ $@ ]]; do
    case "$1" in
        -o|--outdir)
            outDir=$2
            shift 2 ;;
        -n|--nolevel) combineLevel=1; shift ;;
        *) files="$files $1"; shift ;;
    esac
done
if [[ -z $files ]];then
    echo "No input files, exiting"
    exit 1
fi
combineLevelStr="False"
if [[ $combineLevel -eq 1 ]]; then combineLevelStr="True"; fi
echo "Settings"
echo "--------"
echo "Combine Level    : $combineLevelStr"
echo "Output Directory : $outDir"
echo "Files to Process : $files"

echo


for file in $files; do
    echo "Processing -- $file"

    # Get correct wgrib decoder
    isGrib=`./isGrib1.py $file`
    if [[ $isGrib == 'True' ]]; then
        wgrib=`which wgrib`
        echo "Using wgrib"
        separateWgrib $file
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









