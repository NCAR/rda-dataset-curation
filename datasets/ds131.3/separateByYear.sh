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
root_dir='/gpfs/fs1/collections/rda/transfer/20CRv3/20CRv3si'

mkdir $working_dir/$year 2>/dev/null

## Create FG tmp dir
out_dir="$working_dir/$year/tmp_FG"
mkdir $out_dir
in_dir=`find ${root_dir}/ensda_451/ -maxdepth 2 -mindepth 2 | grep "${year}$"`
echo "FG in_dir is : $in_dir"
./separateFG.sh $in_dir $out_dir

# Create SFLX tmp dir
out_dir="$working_dir/$year/tmp_SFLX"
mkdir $out_dir
in_dir=$root_dir/ensda_451_Sflx/$year
echo "starting to separate sflx"
./separateSFLX.sh $in_dir $out_dir

