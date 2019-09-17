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
if [[ $year -gt 1980 ]]; then
    root_dir='/gpfs/fs1/collections/rda/transfer/20CRv3/20CRv3mo'
    in_dir=`find ${root_dir}/ensda_452/ -maxdepth 2 -mindepth 2 | grep "${year}$"`
else
    root_dir='/gpfs/fs1/collections/rda/transfer/20CRv3/20CRv3si'
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
in_dir=$root_dir/ensda_451_Sflx/$year
if [[ $year -gt 1980 ]]; then
    in_dir=$root_dir/ensda_452_Sflx/$year
fi
echo "starting to separate sflx"
./separateSFLX.sh $in_dir $out_dir



