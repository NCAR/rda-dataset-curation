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


filelist=`find /gpfs/fs1/collections/rda/transfer/20CRv3/20CRv3si/ensda_451/ -maxdepth 2 -mindepth 2 | sort`
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
    bn=`basename $file`
    if [[ $bn -ge $from && $bn -le $to ]]; then
        echo "Executing $bn"
        sbatch -J ${bn} -o logs/${bn}_mean.out -e logs/${bn}_mean.err slurm_job.tcsh $file 'mean'
        sbatch -J ${bn} -o logs/${bn}_spread.out -e logs/${bn}_spread.err slurm_job.tcsh $file 'spread'
        sbatch -J ${bn} -o logs/${bn}_fg.out -e logs/${bn}_fg.err slurm_job.tcsh $file 'fg'
        sbatch -J ${bn} -o logs/${bn}_obs.out -e logs/${bn}_obs.err slurm_job.tcsh $file 'obs'
    fi
done
