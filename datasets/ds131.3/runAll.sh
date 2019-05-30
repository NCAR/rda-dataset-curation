#!/bin/bash
#
# Usage:
#   ./runAll.sh [from] [to]
#
# Example
#   ./runAll.sh 1888 1920
#
# Processes files for every year inclusively between dates
# One date will only process that date
# mean, spread, fg processing are in separate batch jobs
#

root_dir='/gpfs/fs1/collections/rda/transfer/20CRv3/20CRv3si'
filelist=`find ${root_dir}/ensda_451/ -maxdepth 2 -mindepth 2 | sort`
from=1800 # less than actual data
to=2050   # more thna actual data
if [[ ! -z $1 ]]; then
    from=$1
fi
if [[ ! -z $2 ]]; then
    to=$2
elif [[ ! -z $1 ]]; then
    to=$from
else
    echo "No dates; exiting"
    exit 1
fi

echo "from: $from"
echo "to: $to"
for file in $filelist; do
    bn=`basename $file` # $bn is the year
    if [[ $bn -ge $from && $bn -le $to ]]; then
        echo "Executing $bn"
        sbatch -J "${bn}_mean" -o logs/${bn}_mean.out -e logs/${bn}_mean.out slurm_job.tcsh $file 'mean'
        sleep 5
#        sbatch -J "${bn}_sprd" -o logs/${bn}_spread.out -e logs/${bn}_spread.out slurm_job.tcsh $file 'spread'
#        sleep 5
#        sbatch -J "${bn}_mean_fg" -o logs/${bn}_mean_fg.out -e logs/${bn}_mean_fg.out slurm_job.tcsh $file 'meanfg'
#        sleep 5
#        sbatch -J "${bn}_spread_fg" -o logs/${bn}_spread_fg.out -e logs/${bn}_spread_fg.out slurm_job.tcsh $file 'sprdfg'
#        sleep 5
#        sbatch -J "${bn}_obs" -o logs/${bn}_obs.out -e logs/${bn}_obs.out slurm_job.tcsh $file 'obs'
#        sleep 5
#        sbatch -J "${bn}_sflx" -o logs/${bn}_sflx.out -e logs/${bn}_sflx.out slurm_job.tcsh $root_dir/ensda_451_Sflx/$bn 'sflx'
#
    fi
done
