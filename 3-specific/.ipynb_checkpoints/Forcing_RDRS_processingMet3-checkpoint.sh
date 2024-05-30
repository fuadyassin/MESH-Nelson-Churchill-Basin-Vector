#!/bin/bash
#SBATCH --account=rpp-kshook
#SBATCH --nodes=1
#SBATCH --tasks-per-node=1
#SBATCH --mem-per-cpu=30G
#SBATCH --time=24:00:00
#SBATCH --job-name=vectForcRDRS
#SBATCH --mail-user=fuad.yassin@usask.ca
#SBATCH --mail-type=BEGIN,END,FAIL

: '
# Forcing RDRS Processing Script

This script processes climate forcing data for the vector based MESH the RDRS dataset. It performs vector processing, file merging, and unit conversions. The script is designed to run on a high-performance computing cluster using SLURM.

## Usage

You can run the script with different sections enabled based on your needs:

- To run all sections:
  sbatch Forcing_RDRS_processingMet3.sh --section1 --section2 --section3
- To run only Section 1:
  sbatch Forcing_RDRS_processingMet3.sh --section1
- To run only Section 2:
  sbatch Forcing_RDRS_processingMet3.sh --section2
- To run only Section 3:
  sbatch Forcing_RDRS_processingMet3.sh --section3

## Script Sections

### Section 1: Python Script Execution

Runs a Python script to process vector-based forcing data.

### Section 2: Merging Files

Merges yearly NetCDF files into a single file.

### Section 3: Unit Conversions

Converts units for various variables in the merged NetCDF file.

## Script Details

### Environment Setup

Loads necessary modules for cdo and nco.

### Input Variables

- basin: Basin name (e.g., "ncrb")
- start_year: Start year for forcing data (e.g., 1980)
- end_year: End year for forcing data (e.g., 2018)
- Paths to necessary files and directories.

### Output

- Merged NetCDF file with converted units.

## Example Commands

# Running Section 1 only
sbatch Forcing_RDRS_processingMet3.sh --section1

# Running Section 2 only
sbatch Forcing_RDRS_processingMet3.sh --section2

# Running Section 3 only
sbatch Forcing_RDRS_processingMet3.sh --section3

# Running all sections
sbatch Forcing_RDRS_processingMet3.sh --section1 --section2 --section3
'

module restore scimods
module load cdo
module load nco

# extensiton name for your basin
basin="ncrb"
start_year=1980       #1980 #forcing start year 
end_year=2018         #2018 #forcing end year 
# location to python code that is used to remappe to ddb
python_script_path="/home/fuaday/github-repos/MESH-Nelson-Churchill-Basin-Vector/3-specific/RDRS_MESH_vectorbased_forcingMet2.py"
# Directory where easymore outputs located (This folder the one from model agnostic easymore)
input_forcing_easymore='/scratch/fuaday/ncrb-models/easymore-outputs'
# Directory where the remapping of easymore forcing to ddb will be saved
ddb_remapped_output_forcing='/scratch/fuaday/ncrb-models/easymore-outputs2'
# geofabric for your basin
input_basin='/home/fuaday/scratch/ncrb-models/geofabric-outputs/ncrb-geofabric/ncrb_subbasins.shp'
# drainage database ddb for your basin (model agnostic output)
input_ddb='/home/fuaday/scratch/ncrb-models/MESH-ncrb/MESH_drainage_database.nc'
# Final output netcdf file name for forcing, and its directory
dir_merged_file="/scratch/fuaday/ncrb-models/easymore-outputs-merged"
merged_file="${dir_merged_file}/${basin}_rdrs_${start_year}_${end_year}_v21_allVar.nc"


# Function to run section 1: Python script execution
function run_section1 {
  local start_time=$(date +%s)
  echo "Running Section 1: Python script for vector processing"
  
  # Execute the Python script
   python "$python_script_path" "$input_forcing_easymore" "$ddb_remapped_output_forcing" "$input_basin" "$input_ddb" "$start_year" "$end_year"
  local end_time=$(date +%s)
  local elapsed_time=$((end_time - start_time))
  echo "Section 1 completed: Python script executed in $elapsed_time seconds."
}

# Function to run section 2: Merging files
function run_section2 {
  local start_time=$(date +%s)
  echo "Running Section 2: Merging files"
  if [ ! -d "$dir_merged_file" ]; then
      mkdir -p "$dir_merged_file"
      echo "Directory created: $dir_merged_file"
  else
      echo "Directory already exists: $dir_merged_file"
  fi
  # Prepare the command to merge files
  merge_cmd="cdo mergetime"
  # Loop through each year and add it to the merge command
  for (( year=$start_year; year<=$end_year; year++ ))
  do
      merge_cmd+=" ${ddb_remapped_output_forcing}/remapped_remapped_ncrb_model_${year}*.nc"
  done
  # Execute the merge command
  $merge_cmd "$merged_file"
  
  local end_time=$(date +%s)
  local elapsed_time=$((end_time - start_time))
  echo "Section 2 completed: Files merged in $elapsed_time seconds."
}

# Function to run section 3: Unit conversions
function run_section3 {
  local start_time=$(date +%s)
  echo "Running Section 3: Converting units"
  ncatted -O -a units,RDRS_v2.1_P_TT_09944,o,c,"K" "$merged_file"
  ncatted -O -a units,RDRS_v2.1_P_P0_SFC,o,c,"Pa" "$merged_file"
  ncatted -O -a units,RDRS_v2.1_P_UVC_09944,o,c,"m s-1" "$merged_file"
  ncatted -O -a units,RDRS_v2.1_A_PR0_SFC,o,c,"mm s-1" "$merged_file"
  ## Set the attribute units for variables
  #ncatted -O -a units,RDRS_v2.1_P_TT_09944,o,c,"K" \
  #      -a units,RDRS_v2.1_P_P0_SFC,o,c,"Pa" \
  #      -a units,RDRS_v2.1_P_UVC_09944,o,c,"m s-1" \
  #      -a units,RDRS_v2.1_A_PR0_SFC,o,c,"mm s-1" \
  #      "$merged_file"
  
  # Define the output file for the transformed data
  temp_file="${dir_merged_file}/${basin}_temp.nc"
  
  # Perform all arithmetic operations in one step and output to a new file
  cdo -z zip -b F32 -expr,'RDRS_v2.1_P_TT_09944=RDRS_v2.1_P_TT_09944 + 273.15; RDRS_v2.1_P_P0_SFC=RDRS_v2.1_P_P0_SFC * 100.0; RDRS_v2.1_P_UVC_09944=RDRS_v2.1_P_UVC_09944 * 0.514444; RDRS_v2.1_A_PR0_SFC=RDRS_v2.1_A_PR0_SFC / 3.6' "$merged_file" "$temp_file"
#   # Perform arithmetic transformations one at a time with ncap2
#   ncap2 -O -s 'RDRS_v2.1_P_TT_09944=RDRS_v2.1_P_TT_09944 + 273.15' "$merged_file" "$merged_file"
#   ncap2 -O -s 'RDRS_v2.1_P_P0_SFC=RDRS_v2.1_P_P0_SFC * 100.0' "$merged_file" "$merged_file"
#   ncap2 -O -s 'RDRS_v2.1_P_UVC_09944=RDRS_v2.1_P_UVC_09944 * 0.514444' "$merged_file" "$merged_file"
#   ncap2 -O -s 'RDRS_v2.1_A_PR0_SFC=RDRS_v2.1_A_PR0_SFC / 3.6' "$merged_file" "$merged_file"
  # Replace the original file with the updated one
  # cdo -z zip -b F32 aexpr,'RDRS_v2.1_P_TT_09944=RDRS_v2.1_P_TT_09944 + 273.15' "$merged_file" "$tem2_file"
  # cdo -z zip -b F32 aexpr,'RDRS_v2.1_P_P0_SFC=RDRS_v2.1_P_P0_SFC * 100.0' "$tem2_file" "$tem1_file"
  # cdo -z zip -b F32 aexpr,'RDRS_v2.1_P_UVC_09944=RDRS_v2.1_P_UVC_09944 * 0.514444' "$tem1_file" "$tem2_file"
  # cdo -z zip -b F32 aexpr,'RDRS_v2.1_A_PR0_SFC=RDRS_v2.1_A_PR0_SFC / 3.6' "$tem2_file" "$tem1_file"
  mv "$temp_file" "$merged_file"
  
  local end_time=$(date +%s)
  local elapsed_time=$((end_time - start_time))
  echo "Section 3 completed: Units converted in $elapsed_time seconds."
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
