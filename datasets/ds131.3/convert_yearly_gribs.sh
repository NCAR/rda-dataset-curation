#!/bin/bash

######################################################
# convert_yearly_gribs [in_dir] [out_dir] [file_type]
#
# in_dir - a parent directory to all files of needed file_type,
# out_dir - location to create directory structure and place output files
# file_type - 'spread', 'mean', 'obs', 'meanfg', 'sprdfg', 'meansflx' or 'sprdsflx'
#             This is the type of file that has special processing depending on type
#
# This program first separates by like parameter, separates into similar levels,
# converts to grib2, and finally converts to netCDF4 with custom metadata.
#

###################################################
# usage
# Displays usage, then exits
#
usage()
{
    echo "Usage:"
    echo "convert_yearly_gribs.sh [in_dir] [out_dir] [file_type]"
    echo "in_dir"
    exit 1
}
###################################################
# check_invariant [filename]
# Checks if filename argument contains string that
# indicates it's an invariant.
#
check_invariant()
{
    # PRES_convective not an invariant, but shouldn't be in input files.
    # SUNSD is only in sflx spread files and doesn't make sense in there
    local filename=$1
    echo $filename | egrep "LAND|HGT_sfc|PRES_convective|SUNSD"
    rc=$?
    if [[ $rc -eq 0 ]]; then
        return 5
    fi
    return 0
}
###################################################
# convert_g1_to_g2 [infile] [outfile]
# Wrapper of convertG12.sh to convert grib1 file to
# grib2 file
#
convert_g1_to_g2()
{
    echo "Done converting grib1 to grib2"
    local g1infile=$1
    local g2outfile=$2
    $common_dir/convertG12.sh $g1infile $g2outfile
    echo "Done converting grib1 to grib2"
}
###################################################
# convert_cfgrib [infile] [outfile]
# If possible, converts grib1 to grib2 (needed since
# cfgrib doesn't respond as well to grib1),
# then calls cfgrib to convert file.
# Additionally, adds 131.3 specific DOI and provenance.
#
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
    $common_dir/add_nc_global.py $outfile 'RDA-Curation-Repo' 'https://github.com/NCAR/rda-dataset-curation/tree/master/datasets/ds131.3'

}

###################################################
# convert_ncl [infile] [outfile]
# Uses ncl to convert to netcdf.
#
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
if [[ ! -z $file_type && $file_type != "spread" && $file_type != "mean" && $file_type != "meanfg" && $file_type != "sprdfg" && $file_type != "obs" && $file_type != "meansflx" && $file_type != "sprdsflx" ]]
then
    >&2 echo "file_type not correct. Can be 'spread', 'mean', 'obs', 'meanfg', 'sprdfg', 'meansflx' or sprdsflx"
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
invariants=invariants
anlDir="$working_dir/anl"
obsDir="$working_dir/obs"
fgDir="$working_dir/fg"
sflxDir="$working_dir/sflx"

tmp_FG="$working_dir/tmp_FG"
tmp_SFLX="$working_dir/tmp_SFLX"

mkdir $anlDir
mkdir $obsDir
mkdir $fgDir
mkdir $sflxDir

# Assignments
common_dir="../../common/"
subsetParamExe="$common_dir/subsetGrib.sh"
subsetLevelExe="$common_dir/subsetGribByLevel.sh"
isGrib1="$common_dir/isGrib1.py"
removeDim="$common_dir/removeDimension.py"

# Config
#rmIntermediate='true' # comment out if not needed

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

    ## Do the sflx and fg anl files
    for anlFile in `find $tmp_FG | grep 'sprdanl' | sort`; do
        $subsetParamExe $anlFile -o $anlDir
        rc=$?
        if [[ $rc -ne 0 ]]; then
            >&2 echo "subsetParam Failed on $anlFile"
            exit 1
        fi
    done

    for anlFile in `find $tmp_SFLX | grep 'sprdanl' | sort`; do
        $subsetParamExe $anlFile -o $anlDir
        rc=$?
        if [[ $rc -ne 0 ]]; then
            >&2 echo "subsetParam Failed on $anlFile"
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

        check_invariant $anlFile
        rc=$?
        if [[ $rc -eq 5 ]]; then # If it's an invariant
            continue
        fi

        filename=`echo $anlFile | sed "s/pgrbenssprdanl/anl_spread_$year/" | sed 's/grb/nc/'`
        echo $filename
        >&2 echo "converting $anlFile to netcdf"
        #convert_ncl $anlFile $filename
        convert_cfgrib $anlFile $filename
        echo $filename | grep 'SNOD'
        if [[ $? -eq 0 ]]; then # Handle SNOD
            $common_dir/add_var_attr.py $filename 'standard_name' 'surface_snow_thickness'
            $common_dir/add_var_attr.py $filename 'GRIB_cfName' 'surface_snow_thickness'
        fi
        echo $filename | grep 'TMP_depth'
        if [[ $? -eq 0 ]]; then # Handle TSOIL
            newFilename=`echo $filename | sed "s/TMP/TSOIL/"`
            mv $filename $newFilename
            filename=$newFilename
            $common_dir/add_var_attr.py $filename 'standard_name' 'soil_temperature'
            $common_dir/add_var_attr.py $filename 'GRIB_cfName' 'soil_temperature'
        fi
        $common_dir/add_var_attr.py $filename 'cell_methods' 'area: standard_deviation'
        echo "Adding LSM"
        /glade/u/home/rpconroy/anaconda3/bin/python $common_dir/copyNCVariable.py -s $invariants/land.nc -d $filename -vn lsm
        $removeDim $filename 'step'
        #rm $anlFile
        nccopy -d 4 -k nc4 -m 5G $filename ${filename}.compressed
        echo "Size before:"
        du -m $filename
        mv ${filename}.compressed $filename
        echo "Size after:"
        du -m $filename
    done
    if [[ -z $rmIntermediate ]]; then
        rm $anlDir/*sprdanl*grb*
        rm $anlDir/*sprd*.idx
    fi
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

    ## do the sflx and fg anl files

    for anlFile in `find $tmp_FG | grep 'meananl' | sort`; do
        $subsetParamExe $anlFile -o $anlDir
        rc=$?
        if [[ $rc -ne 0 ]]; then
            >&2 echo "subsetParam Failed on $anlFile"
            exit 1
        fi
    done

    for anlFile in `find $tmp_SFLX | grep 'meananl' | sort`; do
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

        check_invariant $anlFile
        rc=$?
        if [[ $rc -eq 5 ]]; then # If it's an invariant
            continue
        fi

        filename=`echo $anlFile | sed "s/pgrbensmeananl/anl_mean_$year/" | sed 's/grb/nc/'`
        echo $filename
        >&2 echo "converting $anlFile to netcdf"
        convert_cfgrib $anlFile $filename
        echo $filename | grep 'SNOD'
        if [[ $? -eq 0 ]]; then # Handle SNOD
            $common_dir/add_var_attr.py $filename 'standard_name' 'surface_snow_thickness'
            $common_dir/add_var_attr.py $filename 'GRIB_cfName' 'surface_snow_thickness'
        fi
        echo $filename | grep 'TMP_depth'
        if [[ $? -eq 0 ]]; then # Handle TSOIL
            newFilename=`echo $filename | sed "s/TMP/TSOIL/"`
            mv $filename $newFilename
            filename=$newFilename
            $common_dir/add_var_attr.py $filename 'standard_name' 'soil_temperature'
            $common_dir/add_var_attr.py $filename 'GRIB_cfName' 'soil_temperature'
        fi
        echo "Adding LSM"
        /glade/u/home/rpconroy/anaconda3/bin/python $common_dir/copyNCVariable.py -s $invariants/land.nc -d $filename -vn lsm
        $removeDim $filename 'step'
        #rm $anlFile
        nccopy -d 4 -k nc4 -m 5G $filename ${filename}.compressed
        echo "Size before:"
        du -m $filename
        mv ${filename}.compressed $filename
        echo "Size after:"
        du -m $filename
    done
    if [[ -z $rmIntermediate ]]; then
        rm $anlDir/*meananl*grb*
        rm $anlDir/*meananl*.idx
    fi
fi
########################
## Spread First Guess ##
########################
if [[ -z $file_type || $file_type == 'sprdfg' ]]; then
    # First guess spread - finds all first guess files and subsets by param
    for fgFile in `find $tmp_FG | grep 'sprd_fgonly' | sort`; do
        echo "Starting fg processing"
        $subsetParamExe $fgFile -o $fgDir
        rc=$?
        if [[ $rc -ne 0 ]]; then
            >&2 echo "subsetParam Failed on $fgFile"
            exit 1
        fi
    done
    # Do SFLX spread
    for fgFile in `find $tmp_SFLX | grep 'sprd_fgonly' | sort`; do
        echo "Starting fg processing"
        $subsetParamExe $fgFile -o $fgDir
        rc=$?
        if [[ $rc -ne 0 ]]; then
            >&2 echo "subsetParam Failed on $fgFile"
            exit 1
        fi
    done



    echo "Completed subsetParam on fg"
    for fgFile in $fgDir/*sprd*; do
        $subsetLevelExe $fgFile -o $fgDir
        rc=$?
        if [[ $rc -ne 0 ]]; then
            >&2 echo "subsetParamByLevel Failed on $fgFile"
            exit 1
        fi
    done
    rm $fgDir/*sprd*All_Levels*
    numFiles=`ls -1 $fgDir/*sprd* | wc -l`
    counter=0
    for fgFile in $fgDir/*sprd*; do
        counter=$(( $counter + 1 ))
        echo "file $counter/$numFiles"

        check_invariant $fgFile
        rc=$?
        if [[ $rc -eq 5 ]]; then # If it's an invariant
            continue
        fi

        filename=`echo $fgFile | sed "s/pgrbenssprd/fg_spread_$year/" | sed 's/grb/nc/'`
        echo $filename
        >&2 echo "converting $fgFile to netcdf"
        #convert_ncl $fgFile $filename
        convert_cfgrib $fgFile $filename
        echo $filename | grep 'SNOD'
        if [[ $? -eq 0 ]]; then # Handle SNOD
            $common_dir/add_var_attr.py $filename 'standard_name' 'surface_snow_thickness'
            $common_dir/add_var_attr.py $filename 'GRIB_cfName' 'surface_snow_thickness'
        fi
        echo $filename | grep 'TMP_depth'
        if [[ $? -eq 0 ]]; then # Handle TSOIL
            newFilename=`echo $filename | sed "s/TMP/TSOIL/"`
            mv $filename $newFilename
            filename=$newFilename
            $common_dir/add_var_attr.py $filename 'standard_name' 'soil_temperature'
            $common_dir/add_var_attr.py $filename 'GRIB_cfName' 'soil_temperature'
        fi
        $removeDim $filename 'none'
        #rm $fgFile
        nccopy -d 4 -k nc4 -m 5G $filename ${filename}.compressed
        echo "Size before:"
        du -m $filename
        mv ${filename}.compressed $filename
        echo "Size after:"
        du -m $filename
        $common_dir/add_var_attr.py $filename 'cell_methods' 'area: standard_deviation'
        echo "Adding land"
        /glade/u/home/rpconroy/anaconda3/bin/python $common_dir/copyNCVariable.py -s $invariants/land.nc -d $filename -vn lsm
    done

    if [[ -z $rmIntermediate ]]; then
        rm $fgDir/*sprd*.idx
        rm $fgDir/*sprd*grb*
    fi
fi
######################
## Mean First Guess ##
######################
if [[ -z $file_type || $file_type == 'meanfg' ]]; then
    # First guess mean - finds all mean first guess files and subsets by param
    echo "Starting fg processing"
    for fgFile in `find $tmp_FG | grep 'mean_fgonly' | sort`; do
        $subsetParamExe $fgFile -o $fgDir
        rc=$?
        if [[ $rc -ne 0 ]]; then
            >&2 echo "subsetParam Failed on $fgFile"
            exit 1
        fi
    done
   # Do SFLX
    echo "Starting fg processing"
    for fgFile in `find $tmp_SFLX | grep 'mean_fgonly' | sort`; do
        $subsetParamExe $fgFile -o $fgDir
        rc=$?
        if [[ $rc -ne 0 ]]; then
            >&2 echo "subsetParam Failed on $fgFile"
            exit 1
        fi
    done

    echo "Completed subsetParam on fg"
    for fgFile in $fgDir/*mean*; do
        $subsetLevelExe $fgFile -o $fgDir
        rc=$?
        if [[ $rc -ne 0 ]]; then
            >&2 echo "subsetParamByLevel Failed on $fgFile"
            exit 1
        fi
    done
    rm $fgDir/*mean*All_Levels*

    numFiles=`ls -1 $fgDir/*mean* | wc -l`
    counter=0
    for fgFile in $fgDir/*mean*; do
        counter=$(( $counter + 1 ))
        echo "file $counter/$numFiles"

        check_invariant $fgFile
        rc=$?
        if [[ $rc -eq 5 ]]; then # If it's an invariant
            continue
        fi

        filename=`echo $fgFile | sed "s/pgrbensmean/fg_mean_$year/" | sed 's/grb.*$/nc/'`
        echo $filename
        >&2 echo "converting $fgFile to netcdf"
        #convert_ncl $fgFile $filename
        convert_cfgrib $fgFile $filename
        echo $filename | grep 'TMP_depth'
        if [[ $? -eq 0 ]]; then # Handle TSOIL
            newFilename=`echo $filename | sed "s/TMP/TSOIL/"`
            mv $filename $newFilename
            filename=$newFilename
            $common_dir/add_var_attr.py $filename 'standard_name' 'soil_temperature'
            $common_dir/add_var_attr.py $filename 'GRIB_cfName' 'soil_temperature'
        fi
        echo $filename | grep 'SNOD'
        if [[ $? -eq 0 ]]; then # Handle SNOD
            $common_dir/add_var_attr.py $filename 'standard_name' 'surface_snow_thickness'
            $common_dir/add_var_attr.py $filename 'GRIB_cfName' 'surface_snow_thickness'
        fi
        echo "Adding LSM"
        /glade/u/home/rpconroy/anaconda3/bin/python $common_dir/copyNCVariable.py -s $invariants/land.nc -d $filename -vn lsm
        $removeDim $filename 'none'
        #rm $fgFile
        nccopy -d 4 -k nc4 -m 5G $filename ${filename}.compressed
        echo "Size before:"
        du -m $filename
        mv ${filename}.compressed $filename
        echo "Size after:"
        du -m $filename
    done
    if [[ -z $rmIntermediate ]]; then
        rm $fgDir/*mean*.idx
        rm $fgDir/*mean*grb*
        rm $tmp_FG/*meananl*
    fi
fi
#######################
## Observation Files ##
#######################
if [[ -z $file_type || $file_type == 'obs' ]]; then
    for obsFile in `find $in_dir -type f | grep 'psob' | sort`; do
        filename=${year}`echo $obsFile | grep -o '..........\/psob.*$' | sed 's/\//-/g'`
        cp $obsFile $obsDir/$filename
    done
    cp $invariants/Key_for_psobs_text_files.docx $obsDir/

    cd $obsDir; tar -cvzf psobs_$year.tgz *; cd -
    rm $obsDir/${year}*
    dsarch -DS ds131.3 -AM -NO -NB -GN PSOBS -DF ASCII -FF TAR.GZ -LF $obsDir/psobs_$year.tgz -MF psobs_$year.tgz
fi
##############
## SFLX MEAN #
##############
if [[ -z $file_type || $file_type == 'meansflx' ]]; then
    echo "Surface flux"
    echo "Starting fg processing"
    for sflxFile in `find $tmp_SFLX/instant3hr | grep 'mean' | sort`; do
        $subsetParamExe $sflxFile -o $sflxDir
        rc=$?
        if [[ $rc -ne 0 ]]; then
            >&2 echo "subsetParam Failed on $sflxFile"
            exit 1
        fi
    done

    # Deal with parameters that are averages
    for i in $sflxDir/*mean*All_Levels.grb; do
        wgrib2 $i | grep -v 'ave' >/dev/null;
        file1=$?
        wgrib2 $i | grep 'ave' >/dev/null;
        file2=$?
        if [[ $file1 -eq 0 && $file2 -eq 0 ]]; then
            echo "Splitting averages from $i"
            filename="$i"
            aveFilename=`echo $i | sed 's/All_Levels.grb/ave_All_Levels.grb/'`
            wgrib2 $filename | grep ave | wgrib2 -i $filename -grib $aveFilename
            wgrib2 $filename | grep -v ave | wgrib2 -i $filename -grib $sflxDir/tmpSFLUX.grb
            mv $sflxDir/tmpSFLUX.grb $filename
        fi
    done

    # Subset by level
    for sflxFile in $sflxDir/*mean*; do
        $subsetLevelExe "$sflxFile" -o $sflxDir
        rc=$?
        if [[ $rc -ne 0 ]]; then
            >&2 echo "subsetParamByLevel Failed on $sflxFile"
            exit 1
        fi
    done
    rm $sflxDir/*mean*All_Levels*

    numFiles=`ls -1 $sflxDir/*mean* | wc -l`
    counter=0
    for sflxFile in $sflxDir/*mean*; do
        counter=$(( $counter + 1 ))
        echo "file $counter/$numFiles"

        ## Inject LAND into files;
        check_invariant $sflxFile
        rc=$?
        if [[ $rc -eq 5 ]]; then # If it's an invariant
            continue
        fi

        filename=`echo $sflxFile | sed "s/pgrbensmean/anl_mean_$year/" | sed 's/grb.*$/nc/'`
        echo $filename
        >&2 echo "converting $sflxFile to netcdf"
        convert_cfgrib $sflxFile $filename
        echo "Adding LSM"
        /glade/u/home/rpconroy/anaconda3/bin/python $common_dir/copyNCVariable.py -s $invariants/land.nc -d $filename -vn lsm
        $removeDim $filename 'step'
        #rm $fgFile
        nccopy -d 6 -k nc4 -m 5G $filename ${filename}.compressed
        echo "Size before:"
        du -m $filename
        mv ${filename}.compressed $filename
        echo "Size after:"
        du -m $filename

    done

    if [[ -z $rmIntermediate ]]; then
        rm $sflxDir/*mean*.grb
        rm $sflxDir/*mean*.idx
    fi
fi
##############
## SFLX SPRD #
##############
if [[ -z $file_type || $file_type == 'sprdsflx' ]]; then
    echo "Surface flux"
    echo "Starting fg processing"
    for sflxFile in `find $tmp_SFLX/instant3hr | grep 'sprd' | sort`; do
        $subsetParamExe $sflxFile -o $sflxDir
        rc=$?
        if [[ $rc -ne 0 ]]; then
            >&2 echo "subsetParam Failed on $sflxFile"
            exit 1
        fi
    done

    # Deal with parameters that are averages
    for i in $sflxDir/*sprd*All_Levels.grb; do
        wgrib $i | grep -v 'ave' >/dev/null;
        file1=$?
        wgrib $i | grep 'ave' >/dev/null;
        file2=$?
        if [[ $file1 -eq 0 && $file2 -eq 0 ]]; then
            echo "Splitting averages from $i"
            filename="$i"
            aveFilename=`echo $i | sed 's/All_Levels.grb/ave_All_Levels.grb/'`
            wgrib $filename | grep ave | wgrib -i $filename -grib -o $aveFilename
            wgrib $filename | grep -v ave | wgrib -i $filename -grib -o $sflxDir/tmpSFLUXsprd.grb
            mv $sflxDir/tmpSFLUXsprd.grb $filename
        fi
    done

    # Subset by level
    for sflxFile in $sflxDir/*sprd*; do
        $subsetLevelExe "$sflxFile" -o $sflxDir
        rc=$?
        if [[ $rc -ne 0 ]]; then
            >&2 echo "subsetParamByLevel Failed on $sflxFile"
            exit 1
        fi
    done
    rm $sflxDir/*sprd*All_Levels*

    numFiles=`ls -1 $sflxDir/*sprd* | wc -l`
    counter=0
    for sflxFile in $sflxDir/*sprd*; do
        counter=$(( $counter + 1 ))
        echo "file $counter/$numFiles"

        ## Inject LAND into files;
        check_invariant $sflxFile
        rc=$?
        if [[ $rc -eq 5 ]]; then # If it's an invariant
            continue
        fi

        filename=`echo $sflxFile | sed "s/pgrbenssprd/anl_spread_$year/" | sed 's/grb.*$/nc/'`
        echo $filename
        >&2 echo "converting $sflxFile to netcdf"
        convert_cfgrib $sflxFile $filename
        echo "Adding LSM"
        /glade/u/home/rpconroy/anaconda3/bin/python $common_dir/copyNCVariable.py -s $invariants/land.nc -d $filename -vn lsm
        $removeDim $filename 'step'
        #rm $fgFile
        nccopy -d 6 -k nc4 -m 5G $filename ${filename}.compressed
        echo "Size before:"
        du -m $filename
        mv ${filename}.compressed $filename
        echo "Size after:"
        du -m $filename
        $common_dir/add_var_attr.py $filename 'cell_methods' 'area: standard_deviation'

    done
    if [[ -z $rmIntermediate ]]; then
        rm $sflxDir/*sprd*grb*
        rm $sflxDir/*sprd*.idx
    fi
fi
