#!/bin/bash

year=$1
echo $year
if [[ -z $1 ]]; then
    echo "no year provided"
    exit
fi
if [[ ! -z $2 ]]; then
    working_dir=$2
else
    working_dir='/gpfs/fs1/scratch/rpconroy/rda-dataset-curation/datasets/ds131.3'
fi
if [[ $year -lt 1836 ]]; then
    root_dir='/gpfs/fs1/collections/rda/transfer/20CRv3/BACK1806'
    in_dir=`find ${root_dir}/ -maxdepth 1 -mindepth 1 | grep "${year}$"`
elif [[ $year -gt 1980 ]]; then
    root_dir='/gpfs/fs1/collections/rda/transfer/20CRv3/20CRv3mo'
    in_dir=`find ${root_dir}/ensda_452/ -maxdepth 2 -mindepth 2 | grep "${year}$"`
else
    root_dir='/gpfs/fs1/collections/rda/transfer/20CRv3/20CRv3si'
    in_dir=`find ${root_dir}/ensda_451/ -maxdepth 2 -mindepth 2 | grep "${year}$"`
fi

mkdir $working_dir/$year 2>/dev/null

# Create FG tmp dir
out_dir="$working_dir/$year/tmp_FG"
mkdir $out_dir
echo "FG in_dir is : $in_dir"
echo "FG out_dir is : $out_dir"
./separateFG.sh $in_dir $out_dir

# Create SFLX tmp dir
out_dir="$working_dir/$year/tmp_SFLX"
mkdir $out_dir
if [[ $year -lt 1836 ]]; then
    in_dir=$root_dir/$year
else
    in_dir=$root_dir/ensda_451_Sflx/$year
fi
if [[ $year -gt 1980 ]]; then
    in_dir=$root_dir/ensda_452_Sflx/$year
fi
echo "starting to separate sflx"
./separateSFLX.sh $in_dir $out_dir



