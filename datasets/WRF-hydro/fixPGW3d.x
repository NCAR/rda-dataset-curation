#! /bin/tcsh
#PBS -N log3d.pgw
#PBS -l select=1:ncpus=1:mem=4GB
#PBS -l walltime=10:00:00
#PBS -q rda
#PBS -A P43713000
#PBS -j oe

module load conda
conda activate npl

conda activate /glade/work/rdadata/conda-envs/pg-casper
source ~/my.rdadata.tcshrc
source ~/.tcshrc

set srcd = '/glade/campaign/ncar/USGS_Water/CONUS404_PGW'
set wrkd = '/lustre/desc1/gdex/work/rpconroy/CONUS404_PGW/'

set wydir = 'WY1980'
set iy4 = '1980'
set amn = '01'

cd "$srcd/$wydir"
cp -p wrf3d_d01_"$iy4"-"$amn"-01_??:00:00 "$wrkd"/
cd "$wrkd"

set constants = '/lustre/desc1/gdex/work/rpconroy/CONUS404_PGW/wrfconstants_usgs404.nc'

foreach inf (wrf3d_d01_"$iy4"-"$amn"-??_??:00:00)
  if ( -f tmp.nc ) then
   echo '**** tmp.nc exists, quit, check'
   exit
  endif
  if ( ! -d ORIG ) mkdir ORIG
  cp "$inf" tmp.nc
  mv "$inf" ORIG/
  set outf = "$inf"'.nc'
  ncap2 -h -O -v -s 'Time=XTIME' tmp.nc "$outf"
  if ( ! -f USGS_latlon_fixed.nc ) cp /USGS_latlon_fixed.nc .
  if ( ! -f USGS_XLATXLONG_U.nc )  cp /glade/campaign/collections/rda/transfer/chifan/USGS404/USGS_XLATXLONG_U.nc .
  if ( ! -f USGS_XLATXLONG_V.nc )  cp /glade/campaign/collections/rda/transfer/chifan/USGS404/USGS_XLATXLONG_V.nc .
  if ( ! -f lev_ilev.nc )          cp /glade/campaign/collections/rda/transfer/chifan/USGS404/lev_ilev.nc .
  ncks -h -A USGS_latlon_fixed.nc "$outf"
  ncks -h -A USGS_XLATXLONG_U.nc "$outf"
  ncks -h -A USGS_XLATXLONG_V.nc "$outf"
  ncks -h -A tmp.nc "$outf"
  ncks -h -A lev_ilev.nc "$outf"
  ncatted -h -a cell_methods,,d,, "$outf"
  ncatted -h -a FieldType,,d,, "$outf"
  ncatted -h -a MemoryOrder,,d,, "$outf"
  ncatted -h -a description,U,m,c,"U-component of wind with respect to model grid" "$outf"
  ncatted -h -a description,V,m,c,"V-component of wind with respect to model grid" "$outf"
  ncatted -h -a description,W,m,c,"W-component of wind" "$outf"

# cp -p "$outf" /glade/campaign/collections/rda/work/chifan/USGSout/
# echo 'rm tmp.nc '"$inf"
  echo '..done '"$inf"'     rm tmp.nc '`rm tmp.nc`
end
echo '....all finished'
exit
