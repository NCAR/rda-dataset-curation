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
mkdir $working_dir 2>/dev/null
mkdir $working_dir/obs
mkdir $working_dir/fg
mkdir $working_dir/anl

# Get temp file for example output
exple_dir=`ls -1 $in_dir | head -1 `
#echo "37:2523073:d=1836051206:TMP:700 mb:anl:ens mean" | awk -F : '{print($4":"$5":"$6)}'
for i in $in_dir/$exple_dir/*anl*.grb2; do
    wgrib2 $i | awk -F : '{print($4);}' | sort -u >> tmp_grb2_param_inv_anl
    wgrib2 $i | awk -F : '{print($5);}' | sed 's/[0-9]//g' | sed 's/\.//g' | sort -u >> tmp_grb2_param_inv_anl
done
cat tmp_grb2_inv | sort -u > tmp_grb2_inv2
exit

# Start processing
for dir in $in_dir/*; do
    dir_basename=`basename $dir`
    echo "Processing $dir_basename"

    # Analysis spread and mean
    cat $dir/*sprdanl* >> $working_dir/anl/${year}sprd.grb1
    cat $dir/*meananl* >> $working_dir/anl/${year}mean.grb2

    # First Guess
    cat $dir/*fg* >> $working_dir/fg/${year}mean.grb2

    # Obs
    obs_dir=$working_dir/obs/$dir_basename
    mkdir $obs_dir 2>/dev/null
    cp $dir/*obs* $obs_dir
done


# Post processing
tar -cvzf $working_dir/obs_$year.tgz $working_dir/obs

