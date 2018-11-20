#!/bin/bash
#########
#
# Given 1 or more grib files, this program will attempt create/append each parameter to an individual file.
#
########
#
# Usage : ./subsetGrib [grib_file] [--nolevel] [-o/--outdir out_dir]
#            grib_file      :  File to process. Can be grib 1 or 2
#           -n  --nolevel   :  Don't combine level into one grib
#           -o  --outdir    :
#
#########

#opts=`getopt -o o::,n --long outdir::,nolevel -n 'subsetGrib.sh' -- "$@"  `
#echo $opts
#echo
##eval set -- "$opts"
#exit
#echo $opts
#echo
#combineLevel=0
#files=""
## extract options and their arguments into variables.
#while true ; do
#    case "$1" in
#        -o|--outdir)
#            echo atout;
#            echo $2
#            case "$2" in
#                "") outdir='.' ; shift 2 ;;
#                *) outdir=$2 ; shift 2 ;;
#            esac ;;
#        -n|--nolevel) combineLevel=1 ; shift ;;
#        --) shift ; break ;;
#        *) echo "here"; files="$files $1"; shift ;;
#    esac
#done
#if [[ -z $files ]];then
#    echo "No input files, exiting"
#    exit 1
#fi
#echo "$outdir"
#echo "$combineLevel"
#echo "$files"










