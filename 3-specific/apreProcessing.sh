#!/bin/bash
#SBATCH --account=rpp-kshook
#SBATCH --nodes=1
#SBATCH --tasks-per-node=1
#SBATCH --mem-per-cpu=30G
#SBATCH --time=6:00:00
#SBATCH --job-name=extRDRS
#SBATCH --mail-user=fuad.yassin@usask.ca
#SBATCH --mail-type=BEGIN
#SBATCH --mail-type=END
#SBATCH --mail-type=FAIL

module load cdo
dir1="/scratch/fuaday/ncrb-models/easymore-outputs"
dir2="/scratch/fuaday/ncrb-models/easymore-outputs-merged"
basin="ncrb"
merged_file="${dir2}/${basin}_rdrs_1980_2018_v21_wholeVar.nc"

# section 1
# Check if the directory exists
if [ ! -d "$dir2" ]; then
    # Directory does not exist, so create it
    mkdir -p "$dir2"
    echo "Directory created: $dir2"
else
    echo "Directory already exists: $dir2"
fi

cdo mergetime "${dir1}/remapped_remapped_ncrb_model_*.nc" "$merged_file"

# Section 2
ncatted -O -a units,RDRS_v2.1_P_TT_09944,o,c,"K" "$merged_file"
ncatted -O -a units,RDRS_v2.1_P_P0_SFC,o,c,"Pa" "$merged_file"
ncatted -O -a units,RDRS_v2.1_P_UVC_09944,o,c,"m s-1" "$merged_file"
ncatted -O -a units,RDRS_v2.1_A_PR0_SFC,o,c,"mm s-1" "$merged_file"

# Convert temperature from "deg_C" to "K"
cdo -z zip -b F32 aexpr,'RDRS_v2.1_P_TT_09944=RDRS_v2.1_P_TT_09944 + 273.15' "$merged_file" tem2.nc
# Convert pressure from "mb" to "Pa"
cdo -z zip -b F32 aexpr,'RDRS_v2.1_P_P0_SFC=RDRS_v2.1_P_P0_SFC * 100.0' tem2.nc tem1.nc
# Convert wind speed from "knots" to "m/s"
cdo -z zip -b F32 aexpr,'RDRS_v2.1_P_UVC_09944=RDRS_v2.1_P_UVC_09944 * 0.514444' tem1.nc tem2.nc
# Convert precipitation from "m" over the hour to a rate "mm/s" = "kg m-2 s-1"
cdo -z zip -b F32 aexpr,'RDRS_v2.1_A_PR0_SFC=RDRS_v2.1_A_PR0_SFC / 3.6' tem2.nc "$merged_file"

# Clean up temporary files
rm tem1.nc tem2.nc





# # Extract each variable and save as separate file
# for var in RDRS_v2.1_P_HU_09944 RDRS_v2.1_A_PR0_SFC RDRS_v2.1_P_P0_SFC RDRS_v2.1_P_FB_SFC RDRS_v2.1_P_FI_SFC RDRS_v2.1_P_TT_09944 RDRS_v2.1_P_UVC_09944
    # do
        # cdo selname,$var rdrs_1980_2018_v21_wholeVarTimeseries.nc $basin'_'$var'_1980_2018'.nc
    # done

# # Adjust units Pressure from "mb" to "Pa"
# cdo mulc,100 $basin'_RDRS_v2.1_P_P0_SFC_1980_2018'.nc tmp.nc
# rm $basin'_RDRS_v2.1_P_P0_SFC_1980_2018'.nc
# cdo setattribute,RDRS_v2.1_P_P0_SFC@units=Pa tmp.nc $basin'_RDRS_v2.1_P_P0_SFC_1980_2018'.nc
# rm tmp.nc

# # Temperature from "deg_C" to "K"
# cdo addc,273.16 $basin'_RDRS_v2.1_P_TT_09944_1980_2018'.nc tmp.nc
# rm $basin'_RDRS_v2.1_P_TT_09944_1980_2018'.nc
# cdo setattribute,RDRS_v2.1_P_TT_09944@units=K tmp.nc $basin'_RDRS_v2.1_P_TT_09944_1980_2018'.nc
# rm tmp.nc

# # Wind speed from "knts" to "m/s"
# cdo mulc,0.5144444444444444 $basin'_RDRS_v2.1_P_UVC_09944_1980_2018'.nc tmp.nc
# rm $basin'_RDRS_v2.1_P_UVC_09944_1980_2018'.nc
# cdo setattribute,RDRS_v2.1_P_UVC_09944@units="m s-1" tmp.nc $basin'_RDRS_v2.1_P_UVC_09944_1980_2018'.nc
# rm tmp.nc

# # Precipitation from "m" over the hour to a rate "mm/s" = "kg m-2 s-1"
# cdo divc,3.6 $basin'_RDRS_v2.1_A_PR0_SFC_1980_2018'.nc tmp.nc
# cdo setattribute,RDRS_v2.1_A_PR0_SFC@units="mm s-1" tmp.nc $basin'_RDRS_v2.1_A_PR0_SFC_1980_2018mms'.nc
# rm tmp.nc


# # Clip and Interpolate for the basin grid
# for var in RDRS_v2.1_P_HU_09944 RDRS_v2.1_A_PR0_SFC RDRS_v2.1_P_P0_SFC RDRS_v2.1_P_FB_SFC RDRS_v2.1_P_FI_SFC RDRS_v2.1_P_TT_09944 RDRS_v2.1_P_UVC_09944
    # do
    # cdo -b F32 remapbil,$basin'_gridInformation'.grd $basin'_'$var'_1980_2018'.nc 'MESH_'$basin'_'$var'_1980_2018'.nc
    # done

# lon1=-120.000
# lon2=-89.000
# lat1=45.000
# lat2=61.000


# for var in RDRS_v2.1_P_HU_09944 RDRS_v2.1_A_PR0_SFC RDRS_v2.1_P_P0_SFC RDRS_v2.1_P_FB_SFC RDRS_v2.1_P_FI_SFC RDRS_v2.1_P_TT_09944 RDRS_v2.1_P_UVC_09944
    # do
        # cdo sellonlatbox,$lon1,$lon2,$lat1,$lat2 $dir1/$basin'_'$var'_1980_2018'.nc $dir1/'a'$basin'_'$var'_1980_2018'.nc
    # done