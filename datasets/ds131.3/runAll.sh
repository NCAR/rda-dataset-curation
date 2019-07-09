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
    year=`basename $file` # $year is the year
    if [[ $year -ge $from && $year -le $to ]]; then
        echo "Executing $year"

#        ./separateByYear.sh $year
        sbatch -J "${year}_mean" -o logs/${year}_mean.out -e logs/${year}_mean.out slurm_job.tcsh $file 'mean'
        sleep 5
#        sbatch -J "${year}_sprd" -o logs/${year}_spread.out -e logs/${year}_spread.out slurm_job.tcsh $file 'spread'
#        sleep 5
#        sbatch -J "${year}_mean_fg" -o logs/${year}_mean_fg.out -e logs/${year}_mean_fg.out slurm_job.tcsh $file 'meanfg'
#        sleep 5
#       sbatch -J "${year}_spread_fg" -o logs/${year}_spread_fg.out -e logs/${year}_spread_fg.out slurm_job.tcsh $file 'sprdfg'
#        sleep 5
#        sbatch -J "${year}_obs" -o logs/${year}_obs.out -e logs/${year}_obs.out slurm_job.tcsh $file 'obs'
#        sleep 5
#       sbatch -J "${year}_meansflx" -o logs/${year}_meansflx.out -e logs/${year}_meansflx.out slurm_job.tcsh $root_dir/ensda_451_Sflx/$year 'meansflx'
#        sleep 5
#       sbatch -J "${year}_sprdsflx" -o logs/${year}_sprdsflx.out -e logs/${year}_sprdsflx.out slurm_job.tcsh $root_dir/ensda_451_Sflx/$year 'sprdsflx'

    fi
done
