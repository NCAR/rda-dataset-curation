#!/bin/bash
cd /glade/scratch/rpconroy/rda-dataset-curation/datasets/ds131.3
year=`cat curYear`
newYear=$(( $year + 1 ))
printf "$newYear" > curYear
echo ./runAll.sh $year
./runAll.sh $year > logs/${year}.out 2>&1
archive_year=$(( $year - 2 ))
./archive.sh $archive_year > logs/archive_${archive_year}.out 2>&1
