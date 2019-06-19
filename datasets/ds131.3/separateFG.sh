#!/bin/bash
#
# separates fg
#

usage()
{
    echo "Usage: "
    echo "    ./seaparateFG.sh [in dir] [out_dir]"
    exit 1
}

if [[ $# -lt 2 ]]; then
    usage
fi

in_dir=$1
out_dir=$2


for fgFile in `find $in_dir | grep 'meanfg' | sort`; do
    newFilename=`echo $fgFile | sed 's/pgrbensmeanfg/pgrbensmeananl/'`
    newFilename=`basename $newFilename`
    remFilename=`echo $fgFile | sed 's/pgrbensmeanfg/pgrbensmean_fgonly/'`
    remFilename=`basename $remFilename`
    echo "./separate.sh FG_anl_vars_grib1.txt $fgFile $outdir/$newFilename $outdir/$remFilename"
    ./separate.sh separateRegex/FG_anl_vars_grib1.txt $fgFile $out_dir/$newFilename $out_dir/$remFilename
    echo "./separate.sh FG_anl_vars_grib2.txt $fgFile $outdir/$newFilename $outdir/$remFilename"
    ./separate.sh separateRegex/FG_anl_vars_grib2.txt $fgFile $out_dir/$newFilename $out_dir/$remFilename
done
