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
if [[ $from -lt 1836 ]]; then
    root_dir="/gpfs/fs1/collections/rda/transfer/20CRv3/BACK1806"
    filelist=`find ${root_dir}/ -maxdepth 1 -mindepth 1 | sort`
elif [[ $from -gt 1980 ]]; then
    yearSwitch='mo'
    root_dir="/gpfs/fs1/collections/rda/transfer/20CRv3/20CRv3${yearSwitch}"
    filelist=`find ${root_dir}/ensda_452/ -maxdepth 2 -mindepth 2 | sort`
else
    yearSwitch='si'
    root_dir="/gpfs/fs1/collections/rda/transfer/20CRv3/20CRv3${yearSwitch}"
    filelist=`find ${root_dir}/ensda_451/ -maxdepth 2 -mindepth 2 | sort`
fi


echo "from: $from"
echo "to: $to"
for file in $filelist; do
    year=`basename $file` # $year is the year
    if [[ $year -ge $from && $year -le $to ]]; then
        echo "Executing $year"

    #    ./separateByYear.sh $year
        #qsub -N "${year}_mean" -o logs/${year}_mean.out -e logs/${year}_mean.out PBS_job.tcsh -v "$file mean"
        #sleep 5
        #qsub -N "${year}_sprd" -o logs/${year}_spread.out -e logs/${year}_spread.out PBS_job.tcsh -v "$file spread"
        #sleep 5
        #qsub -N "${year}_mean_fg" -l walltime=6:00:00 -o logs/${year}_mean_fg.out -e logs/${year}_mean_fg.out PBS_job.tcsh -v "$file meanfg"
        #sleep 5
        #qsub -N "${year}_spread_fg" -l walltime=6:00:00 -o logs/${year}_spread_fg.out -e logs/${year}_spread_fg.out PBS_job.tcsh -v "$file sprdfg"
        #sleep 5
        #qsub -N "${year}_obs" -l select=1:mem=4gb -l walltime=1:00:00 -o logs/${year}_obs.out -e logs/${year}_obs.out PBS_job.tcsh -v "$file obs"
        #sleep 5
        #echo qsub -N "${year}_meansflx" -l select=1:mem=30GB -l walltime=2:00:00 -o logs/${year}_meansflx.out -e logs/${year}_meansflx.out PBS_job.tcsh -v "$root_dir/ensda_451_Sflx/$year meansflx"
        qsub -N "${year}_meansflx" -l select=1:mem=30GB -l walltime=2:00:00 -o logs/${year}_meansflx.out -e logs/${year}_meansflx.out PBS_job.tcsh -v "$root_dir/ensda_451_Sflx/$year meansflx"
        #sleep 5
        #qsub -N "${year}_sprdsflx" -l select=1:mem=30GB -l walltime=2:00:00 -o logs/${year}_sprdsflx.out -e logs/${year}_sprdsflx.out PBS_job.tcsh -v "$root_dir/ensda_451_Sflx/$year sprdsflx"



        #sbatch -J "${year}_mean" -o logs/${year}_mean.out -e logs/${year}_mean.out slurm_job.tcsh $file 'mean'
        #sleep 5
        #sbatch -J "${year}_sprd" -o logs/${year}_spread.out -e logs/${year}_spread.out slurm_job.tcsh $file 'spread'
        #sleep 5
        #sbatch -J "${year}_mean_fg" --time 6:00:00 -o logs/${year}_mean_fg.out -e logs/${year}_mean_fg.out slurm_job.tcsh $file 'meanfg'
        #sleep 5
        #sbatch -J "${year}_spread_fg" --time 6:00:00 -o logs/${year}_spread_fg.out -e logs/${year}_spread_fg.out slurm_job.tcsh $file 'sprdfg'
        #sleep 5
        #sbatch -J "${year}_obs" --mem=4000 --time 1:00:00 -o logs/${year}_obs.out -e logs/${year}_obs.out slurm_job.tcsh $file 'obs'
        #sleep 5
        #sbatch -J "${year}_meansflx" --mem=30000 --time 2:00:00 -o logs/${year}_meansflx.out -e logs/${year}_meansflx.out slurm_job.tcsh $root_dir/ensda_451_Sflx/$year 'meansflx'
        #sleep 5
        #sbatch -J "${year}_sprdsflx" --mem=30000 --time 2:00:00 -o logs/${year}_sprdsflx.out -e logs/${year}_sprdsflx.out slurm_job.tcsh $root_dir/ensda_451_Sflx/$year 'sprdsflx'

    fi
done
