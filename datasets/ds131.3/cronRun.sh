#!/bin/bash
cd /glade/scratch/rpconroy/rda-dataset-curation/datasets/ds131.3
year=`cat curYear`
echo ./runAll.sh $year
./runAll.sh $year

newYear=$(( $year + 1 ))
printf "$newYear" > curYear
