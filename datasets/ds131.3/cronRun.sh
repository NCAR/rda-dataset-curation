#!/bin/bash
cd /glade/scratch/rpconroy/rda-dataset-curation/datasets/ds131.3
source ~/.bashrc
export PATH="$PATH:/ncar/opt/slurm/latest/bin"
export PATH="$PATH:/glade/u/apps/ch/opt/grib-bins/1.3/gnu/8.3.0/bin"
which wgrib2 >> test.out 2>&1
which sbatch >> test.out 2>&1
year=`cat curYear`
newYear=$(( $year + 1 ))
printf "$newYear" > curYear
echo ./runAll.sh $year
./runAll.sh $year > logs/${year}.out 2>&1
archive_year=$(( $year - 2 ))
sbatch -J "${archive_year}_archive" -o logs/${year}_archive.out -e logs/${year}_archive.out slurm_archive.tcsh $archive_year
