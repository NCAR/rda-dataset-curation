#!/bin/bash
#
# separates fg
#

usage()
{
    echo "Usage: "
    echo "    ./seaparateSFLX.sh [in dir] [out_dir]"
    exit 1
}

if [[ $# -lt 2 ]]; then
    usage
fi

in_dir=$1
out_dir=$2

for tarFile in $in_dir/*tar; do
    tar -xvf $tarFile -C $out_dir
done

for sflxFile in `find $out_dir | grep 'sflxgrbensmeanfg' | sort`; do
    newFilename=`echo $sflxFile | sed 's/sflxgrbensmeanfg/pgrbensmeananl/'`
    newFilename=`basename $newFilename`
    remFilename=`echo $sflxFile | sed 's/sflxgrbensmeanfg/grbensmean_fgonly/'`
    remFilename=`basename $remFilename`
    echo "./separate.sh FG_anl_vars_grib2.txt $sflxFile $outdir/$newFilename $outdir/$remFilename"
    ./separate.sh SFLX_anl_vars_grib2.txt $sflxFile $out_dir/$newFilename $out_dir/$remFilename
done
