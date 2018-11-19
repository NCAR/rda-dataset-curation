#!/bin/bash

usage()
{
    echo "Usage:"
    echo "convert_yearly_gribs.sh [in_dir] [out_dir]"
    exit 1
}


if [[ -z $1 || -z $2 ]]; then
    usage
fi

in_dir=$1 # Assumed to be directory that contains a timestep for every directory
out_dir=$2
debug=$3

####################
## Initialization ##
####################
year=`basename $in_dir | grep -o "[0-9][0-9][0-9][0-9]"`
echo "Processing year: $year"
echo "Initializing output directories"
working_dir=$out_dir/$year
mkdir $working_dir
mkdir $working_dir/obs
mkdir $working_dir/fg
mkdir $working_dir/anl

# Get temp file for example output
for dir in $in_dir/*; do
    echo $dir
    dir_basename=`basename $dir`
    echo "Processing $dir_basename"
    obs_dir=$working_dir/obs/$dir_basename
    mkdir $obs_dir
    cp $dir/*obs* $obs_dir

done

