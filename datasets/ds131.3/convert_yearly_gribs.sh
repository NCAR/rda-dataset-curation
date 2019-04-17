#!/bin/bash

usage()
{
    echo "Usage:"
    echo "convert_yearly_gribs.sh [in_dir] [out_dir]"
    echo "in_dir"
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
echo "---------------------\n"
echo "Initializing output directories - anl/ obs/ fg/ in $working_dir "
working_dir=$out_dir/$year
mkdir $working_dir 2>/dev/null
anlDir="$working_dir/anl"
obsDir="$working_dir/obs"
fgDir="$working_dir/fg"

mkdir $anlDir
mkdir $obsDir
mkdir $fgDir

# Assingments
common_dir="../../common/"
subsetParamExe="$common_dir/subsetGrib.sh"
subsetLevelExe="$common_dir/subsetGribByLevel.sh"

# Spread Analysis - finds all files and subset's by param
for anlFile in `find $in_dir | grep 'sprdanl' | sort`; do
    $subsetParamExe $anlFile -o $anlDir
    rc=$?
    if [[ $rc -ne 0 ]]; then
        echo "subsetParam Failed on $anlFile"
        exit 1
    fi
done
echo "Completed subsetParam on sprdanl"
for anlFile in $anlDir/*; do
    $subsetLevelExe $anlFile -o $anlDir
    rc=$?
    if [[ $rc -ne 0 ]]; then
        echo "subsetParamByLevel Failed on $anlFile"
        exit 1
    fi
done
rm $anlDir/*All_Levels*

for anlFile in $anlDir/*; do
    filename=`echo $anlFile | sed "s/pgrbenssprdanl/anl_spread_$year/" | sed 's/grb/nc/'`
    echo $filename
    cfgrib to_netcdf $anlFile -o $filename
    rm $anlFile
    nccopy -d 6 $filename ${filename}.compressed
    echo "Size before:"
    du -m $filename
    mv ${filename}.compressed $filename
    echo "Size after:"
    du -m $filename
done

# Mean Analysis - finds all files and subset's by param
for anlFile in `find $in_dir | grep 'meananl' | sort`; do
    $subsetParamExe $anlFile -o $anlDir
    rc=$?
    if [[ $rc -ne 0 ]]; then
        echo "subsetParam Failed on $anlFile"
        exit 1
    fi
done
echo "Completed subsetParam on meananl"
for anlFile in $anlDir/*; do
    $subsetLevelExe $anlFile -o $anlDir
    rc=$?
    if [[ $rc -ne 0 ]]; then
        echo "subsetParamByLevel Failed on $anlFile"
        exit 1
    fi
done
rm $anlDir/*All_Levels*

for anlFile in $anlDir/*; do
    filename=`echo $anlFile | sed "s/pgrbensmeananl/anl_mean_$year/" | sed 's/grb/nc/'`
    echo $filename
    cfgrib to_netcdf $anlFile -o $filename
    rm $anlFile
    nccopy -d 6 $filename ${filename}.compressed
    echo "Size before:"
    du -m $filename
    mv ${filename}.compressed $filename
    echo "Size after:"
    du -m $filename
done
exit 1
# First guess spread - finds all first guess files and subsets by param
for fgFile in `find $in_dir | grep 'sprdfg' | sort`; do
    $subsetParamExe $fgFile -o $fgDir
    rc=$?
    if [[ $rc -ne 0 ]]; then
        echo "subsetParam Failed on $fgFile"
        exit 1
    fi
done
echo "Completed subsetParam on fg"
for fgFile in $fgDir/*; do
    $subsetLevelExe $fgFile -o $fgDir
    rc=$?
    if [[ $rc -ne 0 ]]; then
        echo "subsetParamByLevel Failed on $fgFile"
        exit 1
    fi
done
rm $fgDir/*All_Levels*

for fgFile in $fgDir/*; do
    filename=`echo $fgFile | sed "s/pgrbenssprdfg/fg_spread_$year/" | sed 's/grb/nc/'`
    echo $filename
    cfgrib to_netcdf $fgFile -o $filename
    rm $fgFile
    nccopy -d 6 $filename ${filename}.compressed
    echo "Size before:"
    du -m $filename
    mv ${filename}.compressed $filename
    echo "Size after:"
    du -m $filename
done
exit 1

## Get temp file for example output
#exple_dir=`ls -1 $in_dir | head -1 `
#for i in $in_dir/$exple_dir/*anl*.grb2; do
#    wgrib2 $i | awk -F : '{print($4);}' | sort -u >> tmp_grb2_param_inv_anl
#    wgrib2 $i | awk -F : '{print($5);}' | sed 's/[0-9]//g' | sed 's/\.//g' | sort -u >> tmp_grb2_level_inv_anl
#done
#
## Start processing
#for dir in $in_dir/*; do
#    dir_basename=`basename $dir`
#    echo "Processing $dir_basename"
#
#    # Analysis spread and mean
#    cat $dir/*sprdanl* >> $working_dir/anl/${year}sprd.grb1
#    cat $dir/*meananl* >> $working_dir/anl/${year}mean.grb2
#
#    # First Guess
#    cat $dir/*fg* >> $working_dir/fg/${year}mean.grb2
#
#    # Obs
#    obs_dir=$working_dir/obs/$dir_basename
#    mkdir $obs_dir 2>/dev/null
#    cp $dir/*obs* $obs_dir
#done
#
#tar -cvzf $working_dir/obs_$year.tgz $working_dir/obs
#
#
