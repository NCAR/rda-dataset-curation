#!/bin/bash

usage()
{
    echo "Usage:"
    echo "convert_yearly_gribs.sh [in_dir] [out_dir] [file_type]"
    echo "in_dir"
    exit 1
}
convert_g1_to_g2()
{
    echo "Done converting grib1 to grib2"
    local g1infile=$1
    local g2outfile=$2
    $common_dir/convertG12.sh $g1infile $g2outfile
    echo "Done converting grib1 to grib2"
}
convert_cfgrib()
{
    infile=$1
    outfile=$2
    # First convert to grib2
    $isGrib1 $infile
    if [[ $? -eq 0 ]]; then # if is grib 1
        convert_g1_to_g2 $infile "${infile}.grb2"
        echo "cfgrib to_netcdf ${infile}.grb2 -o $outfile"
        cfgrib to_netcdf "${infile}.grb2" -o $outfile
    else
        echo "cfgrib to_netcdf ${infile} -o $outfile"
        cfgrib to_netcdf ${infile} -o $outfile
    fi
    if [[ $? -ne 0 ]]; then
        >&2 echo "cfgrib failed on $infile"
        exit 1;
    fi

    # Add DOI here for consistency
    $common_dir/add_DOI.py $outfile '10.5065/H93G-WS83'
    # Add repo location
    $common_dir/add_nc_global.py $outfile 'RDA-Curation-Repo', 'https://github.com/NCAR/rda-dataset-curation/tree/master/datasets/ds131.3'

}
convert_ncl()
{
    infile=$1
    outfile=$2
    ncl_outfile=`echo $infile | sed 's/\.grb.*$//'`
    ncl_outfile="${ncl_outfile}.nc"
    ncl_convert2nc $infile
    mv $ncl_outfile $outfile
}

if [[ -z $1 || -z $2 ]]; then
    usage
fi

in_dir=$1 # Assumed to be directory that contains a timestep for every directory
out_dir=$2
file_type=$3 # 'spread', 'mean', 'sprdfg', or 'meanfg', 'obs', 'sflx'
#
# Error Checking
#
if [[ ! -z $file_type && $file_type != "spread" && $file_type != "mean" && $file_type != "meanfg" && $file_type != "sprdfg" && $file_type != "obs" && $file_type != "sflx" ]]
then
    >&2 echo "file_type not correct. Can be 'spread', 'mean', 'obs', 'meanfg' or 'sprdfg' or 'sflx'"
    >&2 echo "no file_type will do all."
    exit 1
fi
module load grib-bins
module load ncl
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
sflxDir="$working_dir/sflx"

mkdir $anlDir
mkdir $obsDir
mkdir $fgDir
mkdir $sflxDir

# Assignments
common_dir="../../common/"
subsetParamExe="$common_dir/subsetGrib.sh"
subsetLevelExe="$common_dir/subsetGribByLevel.sh"
isGrib1="$common_dir/isGrib1.py"

#####################
## Spread Analysis ##
#####################
if [[ -z $file_type || $file_type == 'spread' ]]; then
    echo "Starting spread processing"
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
    for anlFile in $anlDir/*sprdanl*; do
        $subsetLevelExe $anlFile -o $anlDir
        rc=$?
        if [[ $rc -ne 0 ]]; then
            >&2 echo "subsetParamByLevel Failed on $anlFile"
            exit 1
        fi
    done
    rm $anlDir/*sprdanl*All_Levels*
    numFiles=`ls -1 $anlDir/*sprdanl* | wc -l`
    counter=0
    for anlFile in $anlDir/*sprdanl*; do
        counter=$(( $counter + 1 ))
        echo "file $counter/$numFiles"
        filename=`echo $anlFile | sed "s/pgrbenssprdanl/anl_spread_$year/" | sed 's/grb/nc/'`
        echo $filename
        >&2 echo "converting $anlFile to netcdf"
        #convert_ncl $anlFile $filename
        convert_cfgrib $anlFile $filename
        #rm $anlFile
        nccopy -d 6 -k nc4 -m 5G $filename ${filename}.compressed
        echo "Size before:"
        du -m $filename
        mv ${filename}.compressed $filename
        echo "Size after:"
        du -m $filename
        $common_dir/add_var_attr.py $filename 'cell_methods' 'area: standard_deviation'
    done
    rm $anlDir/*sprdanl*grb*
    rm $anlDir/*sprd*.idx
fi
###################
## Mean Analysis ##
###################
if [[ -z $file_type || $file_type == 'mean' ]]; then
    # Mean Analysis - finds all files and subset's by param
    echo "Starting mean processing"
    echo "subsetting meananl param"
    for anlFile in `find $in_dir | grep 'meananl' | sort`; do
        $subsetParamExe $anlFile -o $anlDir
        rc=$?
        if [[ $rc -ne 0 ]]; then
            >&2 echo "subsetParam Failed on $anlFile"
            exit 1
        fi
    done

    echo "Completed subsetParam on meananl"
    for anlFile in $anlDir/*meananl*; do
        echo "$subsetLevelExe $anlFile -o $anlDir"
        $subsetLevelExe $anlFile -o $anlDir
        rc=$?
        if [[ $rc -ne 0 ]]; then
            >&2 echo "subsetParamByLevel Failed on $anlFile"
            exit 1
        fi
    done
    echo "Completed subsetParamByLevel"
    rm $anlDir/*meananl*All_Levels*
    numFiles=`ls -1 $anlDir/*meananl* | wc -l`
    counter=0
    for anlFile in $anlDir/*meananl*; do
        counter=$(( $counter + 1 ))
        echo "file $counter/$numFiles"
        filename=`echo $anlFile | sed "s/pgrbensmeananl/anl_mean_$year/" | sed 's/grb/nc/'`
        echo $filename
        >&2 echo "converting $anlFile to netcdf"
        #convert_ncl $anlFile $filename
        convert_cfgrib $anlFile $filename
        #rm $anlFile
        nccopy -d 6 -k nc4 -m 5G $filename ${filename}.compressed
        echo "Size before:"
        du -m $filename
        mv ${filename}.compressed $filename
        echo "Size after:"
        du -m $filename
    done
    rm $anlDir/*meananl*grb*
    rm $anlDir/*meananl*.idx
fi
########################
## Spread First Guess ##
########################
if [[ -z $file_type || $file_type == 'sprdfg' ]]; then
    # First guess spread - finds all first guess files and subsets by param
    for fgFile in `find $in_dir | grep 'sprdfg' | sort`; do
        echo "Starting fg processing"
        $subsetParamExe $fgFile -o $fgDir
        rc=$?
        if [[ $rc -ne 0 ]]; then
            >&2 echo "subsetParam Failed on $fgFile"
            exit 1
        fi
    done
    echo "Completed subsetParam on fg"
    for fgFile in $fgDir/*sprdfg*; do
        $subsetLevelExe $fgFile -o $fgDir
        rc=$?
        if [[ $rc -ne 0 ]]; then
            >&2 echo "subsetParamByLevel Failed on $fgFile"
            exit 1
        fi
    done
    rm $fgDir/*sprdfg*All_Levels*
    numFiles=`ls -1 $fgDir/*sprdfg* | wc -l`
    counter=0
    for fgFile in $fgDir/*sprdfg*; do
        counter=$(( $counter + 1 ))
        echo "file $counter/$numFiles"
        filename=`echo $fgFile | sed "s/pgrbenssprdfg/fg_spread_$year/" | sed 's/grb/nc/'`
        echo $filename
        >&2 echo "converting $fgFile to netcdf"
        #convert_ncl $fgFile $filename
        convert_cfgrib $fgFile $filename
        #rm $fgFile
        nccopy -d 6 -k nc4 -m 5G $filename ${filename}.compressed
        echo "Size before:"
        du -m $filename
        mv ${filename}.compressed $filename
        echo "Size after:"
        du -m $filename
        $common_dir/add_var_attr.py $filename 'cell_methods' 'area: standard_deviation'
    done
    rm $fgDir/*sprdfg*.idx
    rm $fgDir/*sprdfg*grb*
fi
######################
## Mean First Guess ##
######################
if [[ -z $file_type || $file_type == 'meanfg' ]]; then
    # First guess mean - finds all mean first guess files and subsets by param
    for fgFile in `find $in_dir | grep 'meanfg' | sort`; do
        echo "Starting fg processing"
        $subsetParamExe $fgFile -o $fgDir
        rc=$?
        if [[ $rc -ne 0 ]]; then
            >&2 echo "subsetParam Failed on $fgFile"
            exit 1
        fi
    done
    echo "Completed subsetParam on fg"
    for fgFile in $fgDir/*meanfg*; do
        $subsetLevelExe $fgFile -o $fgDir
        rc=$?
        if [[ $rc -ne 0 ]]; then
            >&2 echo "subsetParamByLevel Failed on $fgFile"
            exit 1
        fi
    done
    rm $fgDir/*meanfg*All_Levels*

    numFiles=`ls -1 $fgDir/*meanfg* | wc -l`
    counter=0
    for fgFile in $fgDir/*meanfg*; do
        counter=$(( $counter + 1 ))
        echo "file $counter/$numFiles"
        filename=`echo $fgFile | sed "s/pgrbensmeanfg/fg_mean_$year/" | sed 's/grb/nc/'`
        echo $filename
        >&2 echo "converting $fgFile to netcdf"
        #convert_ncl $fgFile $filename
        convert_cfgrib $fgFile $filename
        #rm $fgFile
        nccopy -d 6 -k nc4 -m 5G $filename ${filename}.compressed
        echo "Size before:"
        du -m $filename
        mv ${filename}.compressed $filename
        echo "Size after:"
        du -m $filename
    done
    rm $fgDir/*meanfg*.idx
    rm $fgDir/*meanfg*grb*
fi
#######################
## Observation Files ##
#######################
if [[ -z $file_type || $file_type == 'obs' ]]; then
    for obsFile in `find $in_dir -type f | grep 'psob' | sort`; do
        filename=${year}`echo $obsFile | grep -o '..........\/psob.*$' | sed 's/\//-/g'`
        cp $obsFile $obsDir/$filename
    done

    cd $obsDir; tar -cvzf psobs_$year.tgz *; cd -
    rm $obsDir/${year}*
    #dsarch -DS ds131.3 -AM -NO -NB -GN PREPOBS -DF ASCII -FF TAR.GZ -LF psobs_$year.tgz -MF psobs_$year.tgz
fi
if [[ -z $file_type || $file_type == 'sflx' ]]; then
    echo "Surface flux"
#    cp $in_dir/* $sflxDir
#    for tarFile in $sflxDir/*; do
#        tar -xvf $tarFile -C $sflxDir
#    done
#    rm $sflxDir/*.tar
#
#
#
#    for sflxFile in `find $sflxDir | grep 'meanfg' | sort`; do
#        echo "Starting fg processing"
#        $subsetParamExe $sflxFile -o $sflxDir
#        rc=$?
#        if [[ $rc -ne 0 ]]; then
#            >&2 echo "subsetParam Failed on $sflxFile"
#            exit 1
#        fi
#        rm $sflxFile
#    done
#    #echo "Completed subsetParam on fg"
#
#
#    #for sflxFile in `find $sflxDir | grep 'spreadfg' | sort`; do
#    #    echo "Starting fg processing"
#    #    $subsetParamExe $sflxFile -o $sflxDir
#    #    rc=$?
#    #    if [[ $rc -ne 0 ]]; then
#    #        >&2 echo "subsetParam Failed on $sflxFile"
#    #        exit 1
#    #    fi
#    #    rm $sflxFile
#    #done
#    #echo "Completed subsetParam on fg"
#
#    for sflxFile in $sflxDir/*meanfg*; do
#        $subsetLevelExe "$sflxFile" -o $sflxDir
#        rc=$?
#        if [[ $rc -ne 0 ]]; then
#            >&2 echo "subsetParamByLevel Failed on $sflxFile"
#            exit 1
#        fi
#    done

    #rm $fgDir/*meanfg*All_Levels*

    numFiles=`ls -1 $sflxDir/*meanfg* | wc -l`
    counter=0
    for sflxFile in $sflxDir/*meanfg*; do
        counter=$(( $counter + 1 ))
        echo "file $counter/$numFiles"
        filename=`echo $sflxFile | sed "s/sflxgrbensmeanfg/sflx_$year/" | sed 's/grb/nc/'`
        echo $filename
        >&2 echo "converting $fgFile to netcdf"
        #convert_ncl $fgFile $filename
        convert_cfgrib $sflxFile $filename
    #    #rm $fgFile
    #    nccopy -d 6 -k nc4 -m 5G $filename ${filename}.compressed
    #    echo "Size before:"
    #    du -m $filename
    #    mv ${filename}.compressed $filename
    #    echo "Size after:"
    #    du -m $filename
    done
    #rm $fgDir/*meanfg*.idx
    #rm $fgDir/*meanfg*grb*





fi
