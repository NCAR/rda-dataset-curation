#!/bin/bash
#
# inDir should be a year's worth of output directories
# outDir can be anywhere. It will create the necessary output directories
#
#

inDir="/gpfs/fs1/collections/rda/transfer/20CRv3/20CRv3si/ensda_v451/ensda_1834"
outDir="/gpfs/fs1/scratch/rpconroy/rda-dataset-curation/datasets/ds131.3"

./convert_yearly_gribs.sh $inDir $outDir
