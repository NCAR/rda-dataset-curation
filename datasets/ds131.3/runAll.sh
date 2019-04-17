#!/bin/bash


filelist=`find /gpfs/fs1/collections/rda/transfer/20CRv3/20CRv3si/ensda_451/ -maxdepth 2 -mindepth 2 | sort`

for file in $filelist; do
    ./runYear.sh $file
done
