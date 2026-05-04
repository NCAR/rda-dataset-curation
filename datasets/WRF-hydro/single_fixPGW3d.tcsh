#! /bin/tcsh
#PBS -N log3d.pgw
#PBS -l select=1:ncpus=2:mem=7GB
#PBS -l walltime=26:00:00
#PBS -q gdex
#PBS -A P43713000
#PBS -j oe

module load conda
conda activate npl

conda activate /glade/work/rdadata/conda-envs/pg-casper
source ~/../chifan/my.rdadata.tcshrc
source ~/../chifan/.tcshrc
source /lustre/desc1/gdex/work/rpconroy/CONUS404_PGW/python/venv/bin/activate.csh


set wydir = 'WY1980'
set iy4 = "$curyear"
#set amn = '01'
set amn = $curmonth
#set day = $curday
set wydir = "WY$curyear"

set srcd = '/glade/campaign/ncar/USGS_Water/CONUS404_PGW'
@ i = 1
while ( $i <= 31 )
      set day = `printf "%02d" $i`
      echo $day
      @ i++
  set wrkd = "/lustre/desc1/gdex/work/rpconroy/CONUS404_PGW/data/$iy4$amn"
  mkdir $wrkd
  
  cd "$srcd/$wydir"
  cp -p wrf3d_d01_????-"$amn"-"$day"_??:00:00 "$wrkd"/
  cd "$wrkd"
  
  set constants = '/lustre/desc1/gdex/work/rpconroy/CONUS404_PGW/wrfconstants_usgs404.nc'
  
  foreach inf (wrf3d_d01_????-"$amn"-??_??:00:00)
      set tmpfile = `</dev/urandom tr -dc A-Za-z0-9 | head -c 10`tmp.nc
    if ( -f "$tmpfile" ) then
     echo '**** tmp.nc exists, quit, check'
     exit
    endif
    if ( ! -d ORIG ) mkdir ORIG
    cp "$inf" $tmpfile
    #mv "$inf" ORIG/
    rm "$inf" 
    set outf = "$inf"'.nc'
    ncap2 -h -O -v -s 'Time=XTIME' "$tmpfile" "$outf"
    if ( ! -f USGS_latlon_fixed.nc ) cp /lustre/desc1/gdex/work/rpconroy/CONUS404_PGW/USGS_latlon_fixed.nc .
    if ( ! -f USGS_XLATXLONG_U.nc )  cp /lustre/desc1/gdex/work/rpconroy/CONUS404_PGW/USGS_XLATXLONG_U.nc .
    if ( ! -f USGS_XLATXLONG_V.nc )  cp /lustre/desc1/gdex/work/rpconroy/CONUS404_PGW/USGS_XLATXLONG_V.nc .
    if ( ! -f lev_ilev.nc )          cp /lustre/desc1/gdex/work/rpconroy/CONUS404_PGW/lev_ilev.nc .
    ncks -h -A USGS_latlon_fixed.nc "$outf"
    ncks -h -A USGS_XLATXLONG_U.nc "$outf"
    ncks -h -A USGS_XLATXLONG_V.nc "$outf"
    ncks -h -A $tmpfile "$outf"
    ncks -h -A lev_ilev.nc "$outf"
    ncatted -h -a cell_methods,,d,, "$outf"
    ncatted -h -a FieldType,,d,, "$outf"
    ncatted -h -a MemoryOrder,,d,, "$outf"
    ncatted -h -a description,U,m,c,"U-component of wind with respect to model grid" "$outf"
    ncatted -h -a description,V,m,c,"V-component of wind with respect to model grid" "$outf"
    ncatted -h -a description,W,m,c,"W-component of wind" "$outf"
  
  # cp -p "$outf" /glade/campaign/collections/rda/work/chifan/USGSout/
  # echo 'rm tmp.nc '"$inf"
    echo '..done '"$inf"'     rm $tmpfile '`rm $tmpfile`
    echo 'python converting'
    python /lustre/desc1/gdex/work/rpconroy/CONUS404_PGW/python/convert.py $outf $outf.done
    mv $outf.done `echo $outf | sed 's/:/-/g'`
    rm $outf
    echo 'done python converting'
  end
  echo "day $day finished"
end
echo '....all finished'
exit
