#!/bin/tcsh
#PBS -N 20CRv3
#PBS -A P43713000
#PBS -l walltime=6:00:00
#PBS -M rpconroy@ucar.edu
#PBS -m abe
#PBS -l select=1:ncpus=1:mem=50GB
#PBS -q regular

setenv TMPDIR /glade/scratch/rpconroy/rda-dataset-curation/datasets/ds131.3/tmp
mkdir -p $TMPDIR

source /glade/u/home/rpconroy/.tcshrc

cd /glade/scratch/rpconroy/rda-dataset-curation/datasets/ds131.3
in_dir=$in_dir
proc_name=$proc_name
bash  ./runYear.sh $in_dir $proc_name
