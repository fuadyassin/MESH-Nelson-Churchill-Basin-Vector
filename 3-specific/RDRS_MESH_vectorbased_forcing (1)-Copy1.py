"""
@Author: MESHworkflow
"""
#### loading EASYMORE
from easymore.easymore import easymore
### load modules
import os
import numpy as np
import xarray as xs
import pandas as pd
import geopandas as gpd
# 
### define input file
input_forcing  = '/scratch/fuaday/ncrb-models/easymore-outputs-merged/ncrbbb_rdrs_1980_2018_v21_wholeVarTimeseries.nc'
output_forcing = '/scratch/fuaday/ncrb-models/easymore-outputs-merged/MESH_input_ncrb_RDRS_v2p1_1980_2018.nc'
input_basin    = '/home/fuaday/scratch/ncrb-models/geofabric-outputs/ncrb-geofabric/ncrb_subbasins.shp'
input_ddb      = '/home/fuaday/scratch/ncrb-models/MESH-ncrb/MESH_drainage_database.nc'

#
### reading input basin
basin = gpd.read_file(input_basin)
#
### reading input netcdf files db
db = xs.open_dataset(input_ddb)
db.close()
### reading for control check 
lon = db.variables['lon'].values
lat = db.variables['lat'].values
segid =  db.variables['seg_id'].values
#
### reading input forcing
forc = xs.open_dataset(input_forcing)
forc.close()
lon_ease = forc.variables['longitude'].values
lat_ease = forc.variables['latitude'].values
# 
### reorder input forcing
forc_vec = xs.Dataset(
    coords={
        "time": forc['time'].values.copy(),
        "lon": (["subbasin"], lon),
        "lat": (["subbasin"], lat), 
        }
        )
##
# for n in ['pr','hus','wind','ps','ta','rsds','rlds']:	
for n in ['RDRS_v2p1_P_P0_SFC','RDRS_v2p1_P_HU_09944','RDRS_v2p1_P_TT_09944',
          'RDRS_v2p1_A_PR0_SFC','RDRS_v2p1_P_FB_SFC','RDRS_v2p1_P_FI_SFC',
          'RDRS_v2p1_P_UVC_09944','RDRS_v2p1_P_WDC_09944']:   
    forc_vec[n] = (("subbasin", "time"), forc[n].values.transpose())
    forc_vec[n].coords["time"]          = forc['time'].values.copy()
    forc_vec[n].coords["lon"]           = (["subbasin"], lon)
    forc_vec[n].coords["lat"]           = (["subbasin"], lat)
    forc_vec[n].attrs["long_name"]      = forc[n].long_name
    forc_vec[n].attrs["units"]          = forc[n].units
    forc_vec[n].attrs["grid_mapping"]   = 'crs'
    forc_vec[n].encoding['coordinates'] = 'time lon lat'
## 
### update meta data attribuetes
forc_vec.attrs['Conventions'] = 'CF-1.6'
forc_vec.attrs['License']     = 'The data were written by Zelalem T.'
forc_vec.attrs['history']     = 'Created on Mar 07, 2023'
forc_vec.attrs['featureType'] = 'timeSeries'         
###
# editing lat attribute
forc_vec['lat'].attrs['standard_name'] = 'latitude'
forc_vec['lat'].attrs['units']         = 'degrees_north'
forc_vec['lat'].attrs['axis']          = 'Y'
###  
# editing lon attribute
forc_vec['lon'].attrs['standard_name'] = 'longitude'
forc_vec['lon'].attrs['units']         = 'degrees_east'
forc_vec['lon'].attrs['axis']          = 'X'
### 
# editing time attribute
forc_vec['time'].attrs['standard_name'] = 'time'
forc_vec['time'].attrs['axis']          = 'T'
forc_vec['time'].encoding['calendar']   = 'gregorian'
forc_vec.encoding.update(unlimited_dims = 'time')
## 
### coordinate system (Add the 'crs' itself (if none found)).
if (forc.variables.get('crs') is None):
   forc_vec['crs'] = ([], np.int32(1))
   forc_vec['crs'].attrs.update(grid_mapping_name = 'latitude_longitude', longitude_of_prime_meridian = 0.0, semi_major_axis = 6378137.0, inverse_flattening = 298.257223563)
else:
   forc_vec['crs'] = forc['crs'].copy()
##	
### Define a variable for the points and set the 'timeseries_id' (required for some viewers).
forc_vec['subbasin'] = (['subbasin'], db['seg_id'].values.astype(np.int32).astype('S20'))
forc_vec['subbasin'].attrs['cf_role'] = 'timeseries_id'
## 
### save to netcdf
comp = dict(zlib=True, complevel=6)
encoding = {var: comp for var in forc_vec.data_vars}
forc_vec.to_netcdf(output_forcing, encoding=encoding)