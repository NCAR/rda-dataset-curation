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



