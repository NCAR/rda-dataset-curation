#!/bin/tcsh

module load conda
conda activate npl

conda activate /glade/work/rdadata/conda-envs/pg-casper
source ~/../chifan/my.rdadata.tcshrc
source ~/../chifan/.tcshrc

set script_dir = `dirname $0`
set script_dir = `cd $script_dir && pwd`

set srcd = '/glade/campaign/ncar/USGS_Water/CONUS404_PGW'
set srcd = '/lustre/desc1/gdex/work/rpconroy/CONUS404_PGW'
set wrkd = '/lustre/desc1/gdex/work/rpconroy/CONUS404_PGW/data'

if ( $#argv >= 1 ) then
  set inpd = "$argv[1]"
else
  set inpd = `pwd`
endif

foreach inf (`find "$inpd" -name "wrf2d_*.nc"`)
  echo "Processing: $inf"

  set constants = '/lustre/desc1/gdex/work/rpconroy/CONUS404_PGW/wrfconstants_usgs404.nc'

# done fix wrf2d_d01_1986-03-05_08:00:00
#
#  if ( -f tmp.nc ) then
#   echo '**** tmp.nc exists, quit, check'
#   exit
#  endif
  # if ( ! -d ORIG ) mkdir ORIG
  # cp "$inf" tmp.nc
  # mv "$inf" ORIG/
  set tmp = `shuf -i 0-100 -n 1`
  ncap2 -h -O -v -s 'Time=XTIME' $outf $tmp
  #  if ( ! -f USGS_latlon_fixed.nc ) cp /lustre/desc1/gdex/work/rpconroy/CONUS404_PGW/USGS_latlon_fixed.nc .
  #  if ( ! -f USGS_XLATXLONG_U.nc )  cp /lustre/desc1/gdex/work/rpconroy/CONUS404_PGW/USGS_XLATXLONG_U.nc .
  #  if ( ! -f USGS_XLATXLONG_V.nc )  cp /lustre/desc1/gdex/work/rpconroy/CONUS404_PGW/USGS_XLATXLONG_V.nc .
  #  if ( ! -f 3_layers_stag.nc ) cp /lustre/desc1/gdex/work/rpconroy/CONUS404_PGW/3_layers_stag.nc .


  ncks -h -A $srcd/USGS_latlon_fixed.nc "$inf"
  ncks -h -A $srcd/USGS_XLATXLONG_U.nc "$inf"
  ncks -h -A $srcd/USGS_XLATXLONG_V.nc "$inf"
  ncks -h -A $tmp "$inf"
# ncks -h -A lev_ilev.nc "$inf"
  ncatted -h -a cell_methods,,d,, "$inf"
  ncatted -h -a FieldType,,d,, "$inf"
  ncatted -h -a MemoryOrder,,d,, "$inf"
  rm $tmp
# echo 'rm tmp.nc '"$inf"
# echo 'rm tmp.nc '`rm tmp.nc`

  ncatted -h -a description,ACRUNSB,m,c,"Accumulated RUNSB"  "$inf"
  ncatted -h -a description,ACRUNSF,m,c,"Accumulated RUNSF"  "$inf"
  ncatted -h -a description,RECH,m,c,"Accumulated water tabel recharged" "$inf"
  ncatted -h -a long_name,RECH,c,c,"Accumulated water tabel recharged since model init time" "$inf"
  ncatted -h -a units,QSPRINGS,m,c,"mm" "$inf"
  ncatted -h -a units,RECH,m,c,"mm" "$inf"
  ncatted -h -a units,QRFS,m,c,"mm" "$inf"
  ncatted -h -a units,QSLAT,m,c,"mm" "$inf"

  ncatted -h -a long_name,ACDEWC,c,c,"Accumulated canopy dew rate, accumulated over prior 60 minutes"  "$inf"
  ncatted -h -a long_name,ACDRIPR,c,c,"Accumulated canopy precipitation drip rate, accumulated over prior 60 minutes"   "$inf"
  ncatted -h -a long_name,ACDRIPS,c,c,"Accumulated canopy snow drip rate, accumulated over prior 60 minutes"   "$inf"
  ncatted -h -a long_name,ACECAN,c,c,"Accumulated net evaporation of canopy water (evap + sublim - dew - frost), accumulated over prior 60 minutes"   "$inf"
  ncatted -h -a long_name,ACEDIR,c,c,"Accumulated net soil evaporation or snowpack sublimation (evap or sublim - dew or frost), accumulated over prior 60 minutes"   "$inf"
  ncatted -h -a long_name,ACETLSM,c,c,"Accumulated total evaporation, accumulated over prior 60 minutes"   "$inf"
  ncatted -h -a long_name,ACETRAN,c,c,"Accumulated plant transpiration, accumulated over prior 60 minutes"    "$inf"
# ncatted -h -a long_name,ACEVAC,c,c,"Accumulated canopy evaporation,acccum, accumulated over prior 60 minutes"  "$inf"
  ncatted -h -a long_name,ACEVAC,c,c,"Accumulated canopy evaporation, accumulated over prior 60 minutes"  "$inf"
  ncatted -h -a long_name,ACEVB,c,c,"Accumulated latent heat flux over bare ground, accumulated over prior 60 minutes"   "$inf"
  ncatted -h -a long_name,ACEVC,c,c,"Accumulated latent heat flux for canopy layer, accumulated over prior 60 minutes"    "$inf"
  ncatted -h -a long_name,ACEVG,c,c,"Accumulated ground latent heat flux below canopy, accumulated over prior 60 minutes"   "$inf"
  ncatted -h -a long_name,ACFROC,c,c,"Accumulated canopy frost, accumulated over prior 60 minutes"   "$inf"
  ncatted -h -a long_name,ACFRZC,c,c,"Accumulated refreezing of canopy liquid water, accumulated over prior 60 minutes"   "$inf"
  ncatted -h -a long_name,ACGHB,c,c,"Accumulated heat flux into soil or snowpack for bare ground, accumulated over prior 60 minutes" "$inf"
  ncatted -h -a long_name,ACGHFLSM,c,c,"Accumulated total ground heat flux into soil or snowpack, accumulated over prior 60 minutes" "$inf"
  ncatted -h -a long_name,ACGHV,c,c,"Accumulated heat flux into soil or snowpack under canopy, accumulated over prior 60 minutes" "$inf"
  ncatted -h -a long_name,ACINTR,c,c,"Accumulated canopy rain interception rate, accumulated over prior 60 minutes" "$inf"
  ncatted -h -a long_name,ACINTS,c,c,"Accumulated canopy snow interception rate, accumulated over prior 60 minutes" "$inf"
  ncatted -h -a long_name,ACIRB,c,c,"Accumulated net longwave radiation for bare ground, accumulated over prior 60 minutes" "$inf"
  ncatted -h -a long_name,ACIRC,c,c,"Accumulated net longwave radiation from canopy, accumulated over prior 60 minutes" "$inf"
  ncatted -h -a long_name,ACLWDNLSM,c,c,"Accumulated longwave downwelling radiation at land surface model, accumulated over prior 60 minutes"  "$inf"
  ncatted -h -a long_name,ACLWUPLSM,c,c,"Accumulated longwave upwelling radiation at land surface model, accumulated over prior 60 minutes"  "$inf"
  ncatted -h -a long_name,ACMELTC,c,c,"Accumulated canopy snow melt, accumulated over prior 60 minutes"  "$inf"
  ncatted -h -a long_name,ACPAHB,c,c,"Accumulated precipitation advected energy to bare ground, accumulated over prior 60 minutes"  "$inf"
  ncatted -h -a long_name,ACPAHG,c,c,"Accumulated precipitation advected energy to below canopy, accumulated over prior 60 minutes"  "$inf"
  ncatted -h -a long_name,ACPAHV,c,c,"Accumulated precipitation advected energy to vegetation, accumulated over prior 60 minutes" "$inf"
  ncatted -h -a long_name,ACPONDING,c,c,"Accumulated surface ponding from complete pack melt, accumulated over prior 60 minutes" "$inf"
  ncatted -h -a long_name,ACRAINLSM,c,c,"Accumulated liquid precipitation into land surface model, accumulated over prior 60 minutes"  "$inf"
  ncatted -h -a long_name,ACRUNSB,c,c,"Accumulated subsurface runoff, accumulated over prior 60 minutes"  "$inf"
  ncatted -h -a long_name,ACRUNSF,c,c,"Accumulated surface runoff, accumulated over prior 60 minutes" "$inf"
  ncatted -h -a long_name,ACSAGB,c,c,"Accumulated solar radiation absorbed by bare ground, accumulated over prior 60 minutes" "$inf"
  ncatted -h -a long_name,ACSAGV,m,c,"Accumulated solar radiation absorbed by vegetated ground, accumulated over prior 60 minutes" "$inf"
  ncatted -h -a long_name,ACSAV,c,c,"Accumulated solar radiation absorbed by vegetated fraction, accumulated over prior 60 minutes"  "$inf"
  ncatted -h -a long_name,ACSHB,c,c,"Accumulated sensible heat flux at bare fraction, accumulated over prior 60 minutes"  "$inf"
  ncatted -h -a long_name,ACSHC,c,c,"Accumulated sensible heat flux, canopy to atmosphere, accumulated over prior 60 minutes" "$inf"
  ncatted -h -a long_name,ACSHG,c,c,"Accumulated sensible heat flux from ground below canopy, accumulated over prior 60 minutes" "$inf"
  ncatted -h -a long_name,ACSNBOT,c,c,"Accumulated liquid water flux out of bottom of snowpack, accumulated over prior 60 minutes" "$inf"
  ncatted -h -a long_name,ACSNFRO,c,c,"Accumulated snowpack frost, accumulated over prior 60 minutes"  "$inf"
  ncatted -h -a long_name,ACSNOWLSM,c,c,"Accumulated frozen precipitation into land surface model, accumulated over prior 60 minutes" "$inf"
  ncatted -h -a long_name,ACSNSUB,c,c,"Accumulated snowpack sublimation, accumulated over prior 60 minutes"  "$inf"
  ncatted -h -a long_name,ACSUBC,c,c,"Accumulated canopy snow sublimation, accumulated over prior 60 minutes"  "$inf"
  ncatted -h -a long_name,ACSWDNLSM,c,c,"Accumulated shortwave radiation down at land surface model, accumulated over prior 60 minutes"  "$inf"
  ncatted -h -a long_name,ACSWUPLSM,c,c,"Accumulated shortwave radiation up at land surface model, accumulated over prior 60 minutes" "$inf"
  ncatted -h -a long_name,ACTHROR,c,c,"Accumulated canopy rain throughfall, accumulated over prior 60 minutes"  "$inf"
  ncatted -h -a long_name,ACTHROS,c,c,"Accumulated canopy snow throughfall, accumulated over prior 60 minutes"  "$inf"
  ncatted -h -a long_name,ACTR,c,c,"Accumulated transpiration, accumulated over prior 60 minutes" "$inf"

  ncatted -h -a long_name,ACSNOM,c,c,"Accumulated total liquid water out of the snowpack since model initial time" "$inf"
  ncatted -h -a description,ACSNOM,m,c,"Accumulated total liquid water out of the snowpack" "$inf"

  ncatted -h -a long_name,ACIRG,c,c,"Accumulated net longwave radiation from ground below canopy, accumulated over prior 60 minutes" "$inf"
  ncatted -h -a long_name,ACLHFLSM,c,c,"Accumulated total latent heat flux, accumulated over prior 60 minutes" "$inf"
  ncatted -h -a long_name,ACLWDNB,c,c,"Accumulated downwelling longwave radiation flux at bottom, accumulated since last bucket_J (1.0e9 J m-2) reset" "$inf"
  ncatted -h -a long_name,ACLWDNBC,c,c,"Accumulated downwelling clear sky longwave radiation flux at bottom, accumulated since last bucket_J (1.0e9 J m-2) reset" "$inf"
  ncatted -h -a long_name,ACLWDNT,c,c,"Accumulated downwelling longwave radiation flux at top, accumulated since last bucket_J (1.0e9 J m-2) reset" "$inf"
  ncatted -h -a long_name,ACLWDNTC,c,c,"Accumulated downwelling clear sky longwave radiation flux at top, accumulated since last bucket_J (1.0e9 J m-2) reset" "$inf"
  ncatted -h -a long_name,ACLWUPB,c,c,"Accumulated upwelling longwave radiation flux at bottom, accumulated since last bucket_J (1.0e9 J m-2) reset" "$inf"
  ncatted -h -a long_name,ACLWUPBC,c,c,"Accumulated upwelling clear sky longwave radiation flux at bottom, accumulated since last bucket_J (1.0e9 J m-2) reset" "$inf"
  ncatted -h -a long_name,ACLWUPT,c,c,"Accumulated upwelling longwave radiation flux at top, accumulated since last bucket_J (1.0e9 J m-2) reset" "$inf"
  ncatted -h -a long_name,ACLWUPTC,c,c,"Accumulated upwelling clear sky longwave radiation flux at top, accumulated since last bucket_J (1.0e9 J m-2) reset" "$inf"
  ncatted -h -a long_name,ACPAHLSM,c,c,"Accumulated total precipitation heat flux advected to surface, accumulated over prior 60 minutes" "$inf"
  ncatted -h -a long_name,ACQLAT,c,c,"Accumulated groundwater lateral flow, accumulated over prior 60 minutes" "$inf"
  ncatted -h -a long_name,ACQRF,c,c,"Accumulated groundwater baseflow, accumulated over prior 60 minutes" "$inf"
  ncatted -h -a long_name,ACRAINSNOW,c,c,"Acccumlated rain on snow pack, accumulated over prior 60 minutes" "$inf"
  ncatted -h -a long_name,ACSAGV,c,c,"Accumulated solar radiation absorbed by vegetated ground, accumulated over prior 60 minutes" "$inf"
  ncatted -h -a long_name,ACSHFLSM,c,c,"Acccumlated total sensible heat flux, accumulated over prior 60 minutes" "$inf"
  ncatted -h -a long_name,ACSWDNB,c,c,"Accumulated downwelling shortwave radiation flux at bottom, accumulated since last bucket_J (1.0e9 J m-2) reset" "$inf"
  ncatted -h -a long_name,ACSWDNBC,c,c,"Accumulated downwelling clear sky shortwave radiation flux at bottom, accumulated since last bucket_J (1.0e9 J m-2) reset" "$inf"
  ncatted -h -a long_name,ACSWDNT,c,c,"Accumulated downwelling shortwave radiation flux at top, accumulated since last bucket_J (1.0e9 J m-2) reset" "$inf"
  ncatted -h -a long_name,ACSWDNTC,c,c,"Accumulated downwelling clear sky shortwave radiation flux at top, accumulated since last bucket_J (1.0e9 J m-2) reset" "$inf"
  ncatted -h -a long_name,ACSWUPB,c,c,"Accumulated upwelling shortwave radiation flux at bottom, accumulated since last bucket_J (1.0e9 J m-2) reset" "$inf"
  ncatted -h -a long_name,ACSWUPBC,c,c,"Accumulated upwelling clear sky shortwave radiation flux at bottom, accumulated since last bucket_J (1.0e9 J m-2) reset" "$inf"
  ncatted -h -a long_name,ACSWUPT,c,c,"Accumulated upwelling shortwave radiation flux at top, accumulated since last bucket_J (1.0e9 J m-2) reset" "$inf"
  ncatted -h -a long_name,ACSWUPTC,c,c,"Accumulated upwelling clear sky shortwave radiation flux at top accumulated since last bucket_J (1.0e9 J m-2) reset" "$inf"
  ncatted -h -a long_name,ALBEDO,c,c,"Surface albedo including snow effects" "$inf"
  ncatted -h -a long_name,FORCPLSM,c,c,"Lowest model pressure into land surface model" "$inf"
  ncatted -h -a long_name,FORCQLSM,c,c,"Lowest model mixing ratio into land surface model" "$inf"
  ncatted -h -a long_name,FORCTLSM,c,c,"Lowest model temperature into land surface model" "$inf"
  ncatted -h -a long_name,FORCWLSM,c,c,"Lowest model wind speed into land surface model" "$inf"
  ncatted -h -a long_name,FORCZLSM,c,c,"Lowest model height above ground level into land surface model" "$inf"
  ncatted -h -a long_name,GRAUPEL_ACC_NC,c,c,"Accumulated graupel water equivalent, accumulated over prior 60 minutes" "$inf"
  ncatted -h -a long_name,I_ACLWDNB,c,c,"Bucket for downwelling longwave flux at bottom accumulated since model start time" "$inf"
  ncatted -h -a long_name,I_ACLWDNBC,c,c,"Bucket for downwelling clear sky longwave flux at bottom accumulated since model start time" "$inf"
  ncatted -h -a long_name,I_ACLWDNT,c,c,"Bucket for downwelling longwave flux at top accumulated since model start time" "$inf"
  ncatted -h -a long_name,I_ACLWDNTC,c,c,"Bucket for downwelling clear sky longwave flux at top accumulated since model start time" "$inf"
  ncatted -h -a long_name,I_ACLWUPB,c,c,"Bucket for upwelling longwave flux at bottom accumulated since model start time" "$inf"
  ncatted -h -a long_name,I_ACLWUPBC,c,c,"Bucket for upwelling clear sky longwave flux at bottom accumulated since model start time" "$inf"
  ncatted -h -a long_name,I_ACLWUPT,c,c,"Bucket for upwelling longwave flux at top accumulated since model start time" "$inf"
  ncatted -h -a long_name,I_ACLWUPTC,c,c,"Bucket for upwelling clear sky longwave flux at top accumulated since model start time" "$inf"
  ncatted -h -a long_name,I_ACSWDNB,c,c,"Bucket for downwelling shortwave flux at bottom accumulated since model start time" "$inf"
  ncatted -h -a long_name,I_ACSWDNBC,c,c,"Bucket for downwelling clear sky shortwave flux at bottom accumulated since model start time" "$inf"
  ncatted -h -a long_name,I_ACSWDNT,c,c,"Bucket for downwelling shortwave flux at top accumulated since model start time" "$inf"
  ncatted -h -a long_name,I_ACSWDNTC,c,c,"Bucket for downwelling clear sky shortwave flux at top accumulated since model start time" "$inf"
  ncatted -h -a long_name,I_ACSWUPB,c,c,"Bucket for upwelling shortwave flux at bottom accumulated since model start time" "$inf"
  ncatted -h -a long_name,I_ACSWUPBC,c,c,"Bucket for upwelling clear sky shortwave flux at bottom accumulated since model start time" "$inf"
  ncatted -h -a long_name,I_ACSWUPT,c,c,"Bucket for upwelling shortwave flux at top accumulated since model start time" "$inf"
  ncatted -h -a long_name,I_ACSWUPTC,c,c,"Bucket for upwelling clear sky shortwave flux at top accumulated since model start time" "$inf"
  ncatted -h -a long_name,MLCAPE,c,c,"Mixed-layer convective available potential energy (CAPE)" "$inf"
  ncatted -h -a long_name,MLLCL,c,c,"Mixed-layer lifting condensation level (LCL)" "$inf"
# do not use  ncatted -h -a description,MUCAPE,m,c,"MOIST-UNSTABLE CAPE" "$inf"
# do not use  ncatted -h -a long_name,MUCAPE,c,c,"Moist-unstable convective available potential energy (CAPE)" "$inf"
  ncatted -h -a long_name,MUCAPE,c,c,"Most-unstable convective available potential energy (CAPE)" "$inf"
# do not use  ncatted -h -a description,MUCINH,m,c,"MOIST-UNSTABLE CINH" "$inf"
# do not use  ncatted -h -a long_name,MUCINH,c,c,"Moist-unstable convective inhibition up to the level of free convection (CINH)" "$inf"
  ncatted -h -a long_name,MUCINH,c,c,"Most-unstable convective inhibition up to the level of free convection (CINH)" "$inf"
  ncatted -h -a long_name,PREC_ACC_NC,c,c,"Accumulated grid scale  precipitation , accumulated over prior 60 minutes" "$inf"
  ncatted -h -a long_name,QRFS,c,c,"Accumulated baseflow since model start time" "$inf"
  ncatted -h -a long_name,QSLAT,c,c,"Accumulated groundwater lateral flow since model start time" "$inf"
  ncatted -h -a long_name,QSPRINGS,c,c,"Accumulated seeping water since model start time" "$inf"
  ncatted -h -a long_name,SBCAPE,c,c,"Surface-based convective available potential energy (CAPE)" "$inf"
  ncatted -h -a long_name,SBCINH,c,c,"Surface-based convective inhibition up to the level of free convection (CINH)" "$inf"
  ncatted -h -a long_name,SBLCL,c,c,"Surface-based lifting condensation level (LCL)" "$inf"
  ncatted -h -a long_name,SNOW_ACC_NC,c,c,"Accumulated snow water equivalent, accumulated over prior 60 minutes" "$inf"
  ncatted -h -a long_name,U,c,c,"U-component wind with respect to model grid at the lowest model level" "$inf"
  ncatted -h -a long_name,U10,c,c,"U-component wind with respect to model grid at 10 meters" "$inf"
  ncatted -h -a long_name,V,c,c,"V-component wind with respect to model grid at the lowest model level" "$inf"
  ncatted -h -a long_name,V10,c,c,"V-component wind with respect to model grid at 10 meters" "$inf"
  ncatted -h -a long_name,W,c,c,"W-component wind at the lowest model level" "$inf"


  ncatted -h -a long_name,MLCINH,c,c,"Mixed-layer convective inhibition up to the level of free convection (CINH)"  "$inf"
  ncatted -h -a long_name,Q2,c,c,"Water vapor mixing ratio at 2 meters"  "$inf"

  ncatted -h -a stagger,Z,m,c," " "$inf"
  ncatted -h -a stagger,W,m,c," " "$inf"
  ncks -h -A $src/d3_layers_stag.nc "$inf"
# cp -p "$inf" /glade/campaign/collections/rda/work/chifan/USGSout/

  python $script_dir/convert_inplace.py "$inf"
end
echo '....all finished'
exit
