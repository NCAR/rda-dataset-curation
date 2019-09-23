#!/bin/tcsh
#SBATCH --job-name=20CR_1940
#SBATCH --ntasks=1
#SBATCH --time=15:00:00
#SBATCH --account=P43713000
#SBATCH --partition=dav
#SBATCH --mem=80000
#SBATCH --qos=rda
#SBATCH --error=logs/err.%j
#SBATCH --output=logs/out.%j

setenv TMPDIR /glade/scratch/rpconroy/rda-dataset-curation/datasets/ds131.3/tmp
mkdir -p $TMPDIR

source /glade/u/home/rpconroy/.tcshrc

cd /gpfs/fs1/scratch/rpconroy/rda-dataset-curation/datasets/ds131.3
srun ./runYear.sh $1 $2
