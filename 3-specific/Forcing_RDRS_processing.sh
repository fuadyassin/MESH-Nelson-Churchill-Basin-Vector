#!/bin/bash
#SBATCH --account=rpp-kshook
#SBATCH --nodes=1
#SBATCH --tasks-per-node=1
#SBATCH --mem-per-cpu=30G
#SBATCH --time=10:00:00
#SBATCH --job-name=extRDRS
#SBATCH --mail-user=fuad.yassin@usask.ca
#SBATCH --mail-type=BEGIN,END,FAIL

# To run both sections: sbatch Forcing_RDRS_processing.sh --section1 --section2 --section3
# To run only Section 1: sbatch Forcing_RDRS_processing.sh --section1
# To run only Section 2: sbatch Forcing_RDRS_processing.sh --section2
# To run only Section 3: sbatch Forcing_RDRS_processing.sh --section3

module restore scimods
module load cdo
module load nco

# Directories and file names
dir1="/scratch/fuaday/ncrb-models/easymore-outputs"
dir2="/scratch/fuaday/ncrb-models/easymore-outputs-merged"
basin="ncrb"
start_year=1980       #1980
end_year=1982         #2018
merged_file="${dir2}/${basin}_rdrs_${start_year}_${end_year}_v21_allVar.nc"
python_script_path="/home/fuaday/github-repos/MESH-Nelson-Churchill-Basin-Vector/3-specific/RDRS_MESH_vectorbased_forcingImp.py"

# Set input and output directories
input_forcing='/scratch/fuaday/ncrb-models/easymore-outputs'
output_forcing='/scratch/fuaday/ncrb-models/easymore-outputs3'
input_basin='/home/fuaday/scratch/ncrb-models/geofabric-outputs/ncrb-geofabric/ncrb_subbasins.shp'
input_ddb='/home/fuaday/scratch/ncrb-models/MESH-ncrb/MESH_drainage_database.nc'



# Function to run section 1: Python script execution
function run_section1 {
  echo "Running Section 1: Python script for vector processing"
  # Execute the Python script
   python "$python_script_path" "$input_forcing" "$output_forcing" "$input_basin" "$input_ddb" "$start_year" "$end_year"
  echo "Section 1 completed: Python script executed"
}


# Function to run section 2: Merging files
function run_section2 {
  echo "Running Section 2: Merging files"
  if [ ! -d "$dir2" ]; then
      mkdir -p "$dir2"
      echo "Directory created: $dir2"
  else
      echo "Directory already exists: $dir2"
  fi
  # Prepare the command to merge files
  merge_cmd="cdo mergetime"
  # Loop through each year and add it to the merge command
  for (( year=$start_year; year<=$end_year; year++ ))
  do
      merge_cmd+=" ${dir1}/remapped_remapped_ncrb_model_${year}*.nc"
  done
  # Execute the merge command
  $merge_cmd "$merged_file"
  #cdo mergetime "${dir1}/remapped_remapped_ncrb_model_*.nc" "$merged_file"
  echo "Section 2 completed: Files merged"
}


# Function to run section 3: Unit conversions
function run_section2 {
  echo "Running Section 3: Converting units"
  ncatted -O -a units,RDRS_v2.1_P_TT_09944,o,c,"K" "$merged_file"
  ncatted -O -a units,RDRS_v2.1_P_P0_SFC,o,c,"Pa" "$merged_file"
  ncatted -O -a units,RDRS_v2.1_P_UVC_09944,o,c,"m s-1" "$merged_file"
  ncatted -O -a units,RDRS_v2.1_A_PR0_SFC,o,c,"mm s-1" "$merged_file"
  
  tem2_file="${dir2}/${basin}_tem2.nc"
  tem1_file="${dir2}/${basin}_tem1.nc"

  echo "RDRS_v2.1_P_TT_09944=RDRS_v2.1_P_TT_09944 + 273.15"
  cdo -z zip -b F32 aexpr,'RDRS_v2.1_P_TT_09944=RDRS_v2.1_P_TT_09944 + 273.15' "$merged_file" "$tem2_file"
  echo "RDRS_v2.1_P_P0_SFC=RDRS_v2.1_P_P0_SFC * 100.0"
  cdo -z zip -b F32 aexpr,'RDRS_v2.1_P_P0_SFC=RDRS_v2.1_P_P0_SFC * 100.0' "$tem2_file" "$tem1_file"
  echo "RDRS_v2.1_P_UVC_09944=RDRS_v2.1_P_UVC_09944 * 0.514444"
  cdo -z zip -b F32 aexpr,'RDRS_v2.1_P_UVC_09944=RDRS_v2.1_P_UVC_09944 * 0.514444' "$tem1_file" "$tem2_file"
  echo "RDRS_v2.1_A_PR0_SFC=RDRS_v2.1_A_PR0_SFC / 3.6"
  cdo -z zip -b F32 aexpr,'RDRS_v2.1_A_PR0_SFC=RDRS_v2.1_A_PR0_SFC / 3.6' "$tem2_file" "$tem1_file"
  echo "Section 3 completed: Units converted"
  mv "$tem1_file" "$merged_file"

  # Clean up temporary files
  rm "$tem1_file" "$tem2_file"
}


# Main execution logic based on command-line arguments
for arg in "$@"
do
    case $arg in
        --section1)
            run_section1
            ;;
        --section2)
            run_section2
            ;;
        --section3)
            run_section3
            ;;
    esac
done
