#!/bin/bash
#
# inDir should be a year's worth of output directories
# outDir can be anywhere. It will create the necessary output directories
#
#
if [[ ! -z $1 ]]; then
    inDir=$1
else
    #inDir="/gpfs/fs1/collections/rda/transfer/20CRv3/20CRv3si/ensda_451/ensda_451_1834/1837"
    inDir=$in_dir
fi
outDir="/gpfs/fs1/scratch/rpconroy/rda-dataset-curation/datasets/ds131.3"
file_type=$2
#file_type=$proc_type

time ./convert_yearly_gribs.sh $inDir $outDir $file_type
