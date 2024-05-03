"""
@Author: MESHworkflow
"""
### load modules
import easymore
import sys
import os
import numpy as np
import xarray as xs
import pandas as pd
import geopandas as gpd
import glob


# Command line arguments
input_directory = sys.argv[1]
output_directory = sys.argv[2]
input_basin = sys.argv[3]
input_ddb = sys.argv[4]
start_year = int(sys.argv[5])
end_year = int(sys.argv[6])

# Ensure output directory exists
os.makedirs(output_directory, exist_ok=True)

# Read basin and drainage database files
basin = gpd.read_file(input_basin)
db = xs.open_dataset(input_ddb)
lon = db.variables['lon'].values
lat = db.variables['lat'].values
segid = db.variables['subbasin'].values
db.close()

# List files based on year range
files = []
for year in range(start_year, end_year + 1):
    files.extend(glob.glob(os.path.join(input_directory, f"remapped_remapped_ncrb_model_{str(year)}*.nc")))

# Process each file
for file_path in files:
    # Open dataset
    forc = xs.open_dataset(file_path)
    lon_ease = forc.variables['longitude'].values
    lat_ease = forc.variables['latitude'].values

    # Extract indices of forcing IDs based on the drainage database
    ind = []
    for i in range(len(segid)):
        fid = np.where(np.int32(forc['COMID'].values) == segid[i])[0]
        ind = np.append(ind, fid)
    ind = np.int32(ind)

    # Create a new dataset with re-ordered data
    forc_vec = xs.Dataset()
    variables_to_process = ['RDRS_v2.1_A_PR0_SFC', 'RDRS_v2.1_P_P0_SFC', 'RDRS_v2.1_P_HU_09944', 'RDRS_v2.1_P_TT_09944',
                            'RDRS_v2.1_P_FB_SFC', 'RDRS_v2.1_P_FI_SFC', 'RDRS_v2.1_P_UVC_09944']
    for var in variables_to_process:
        forc_vec[var] = (("subbasin", "time"), forc[var].values[:, ind].transpose())
        forc_vec[var].attrs = forc[var].attrs

    # Set coordinate variables
    forc_vec.coords['time'] = forc['time'].values.copy()
    forc_vec.coords['lon'] = (["subbasin"], lon)
    forc_vec.coords['lat'] = (["subbasin"], lat)
    
    # Metadata and attributes
    forc_vec.attrs['Conventions'] = 'CF-1.6'
    forc_vec.attrs['history'] = 'Processed on Apr 06, 2024'
    forc_vec.attrs['License'] = 'The data were written by Fuad Yassin.'
    forc_vec.attrs['featureType'] = 'timeSeries'
    
    # Define coordinate system
    if 'crs' not in forc.variables:
        forc_vec['crs'] = xs.DataArray(np.int32(1), attrs={
            'grid_mapping_name': 'latitude_longitude',
            'longitude_of_prime_meridian': 0.0,
            'semi_major_axis': 6378137.0,
            'inverse_flattening': 298.257223563
        })
    else:
        forc_vec['crs'] = forc['crs'].copy()

    # Define a variable for the points and set the 'timeseries_id'
    forc_vec['subbasin'] = xs.DataArray(db['subbasin'].values.astype(np.int32).astype('S20'), dims=['subbasin'])
    forc_vec['subbasin'].attrs['cf_role'] = 'timeseries_id'
    
    # Save to netCDF
    output_path = os.path.join(output_directory, os.path.basename(file_path).replace('.nc', '_modified.nc'))
    encoding = {var: {'zlib': True, 'complevel': 6} for var in forc_vec.data_vars}
    forc_vec.to_netcdf(output_path, encoding=encoding)
    print(f"Processed and saved: {output_path}")

    # Close the dataset
    forc.close()
