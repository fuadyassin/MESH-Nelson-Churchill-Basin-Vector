library(dplyr)
library(terra)
library(sf)

# Define the custom library paths
custom_lib_paths <- c("/home/fuaday/R/x86_64-pc-linux-gnu-library/4.3")
# Uncomment and use this path if needed
# custom_lib_paths <- c("/project/6008034/Climate_Forcing_Data/assets/r-envs/exact-extract-env/v5/R-4.1/x86_64-pc-linux-gnu")

# Set the custom library paths
.libPaths(custom_lib_paths)

# Function to install and load necessary packages
install_and_load <- function(packages) {
  for (pkg in packages) {
    if (!require(pkg, character.only = TRUE)) {
      install.packages(pkg, repos = "http://cran.us.r-project.org")
      library(pkg, character.only = TRUE)
    }
  }
}

# List of required packages
required_packages <- c("dplyr", "ggplot2", "terra", "raster", "sf", "exactextractr")

# Install and load required packages
install_and_load(required_packages)
#######################################################################################################################
basin_aggregation <- function(input_basin, input_river, min_subarea, min_slope, min_length) {
########################################################################################################################
output_basin <- input_basin
output_river <- input_river
##
output_river$slope[output_river$slope < min_slope] <- min_slope
output_river$lengthkm[output_river$lengthkm < min_length] <- min_length
##
output_basin$agg <- output_basin$COMID
output_basin$aggdown <- output_basin$NextDownID
##
agg_basin <- output_basin[,c("agg","unitarea","aggdown","uparea")]
########################################################################################################################
######### Aggregated the headwaters sub-basins ##################################################################################
#################################################################################################################################  
for (qq in 1 : length(output_basin$COMID)) {
##
small_subbasin = agg_basin[!(agg_basin$agg %in% agg_basin$aggdown),]               ## select headwaters sub-basins
small_subbasin = small_subbasin[small_subbasin$unitarea < min_subarea,]            ## select sub-basins with less than the minimum area
if (length(small_subbasin$unitarea) > 0) {
xx = small_subbasin[order(-small_subbasin$uparea,-small_subbasin$aggdown),]        ## rearrange the order of the aggregation
## 
for (i in 1 : length(xx$agg)) {
output_basin$aggdown[which(output_basin$agg == xx$agg[i])] <- output_basin$NextDownID[which(output_basin$COMID == xx$aggdown[i])]
output_basin$agg[which(output_basin$agg == xx$agg[i])] <- xx$aggdown[i]
}
##
agg_basin = aggregate(output_basin[,c("unitarea")] %>% as.data.frame() %>% select(-geometry), by = list(output_basin$agg), FUN = sum)
colnames(agg_basin)[1] <- "COMID"
agg_basin = left_join(agg_basin, output_basin[,c("COMID","NextDownID","uparea")] %>% as.data.frame() %>% select(-geometry), by = "COMID")
colnames(agg_basin) <- c("agg","unitarea","aggdown","uparea")
##
}
if (length(small_subbasin$unitarea) == 0) { break }
}
##
################################################################################################################################
############ Aggregated the intermediate sub-basins ############################################################################
################################################################################################################################
for (qq in 1 : length(output_basin$COMID)) {
##
small_subbasin = agg_basin[which(agg_basin$agg %in% agg_basin$aggdown),]            ## select intermediate sub-basins excluding the outlet
small_subbasin = small_subbasin[small_subbasin$unitarea < min_subarea,]             ## select sub-basins with less than the minimum area
##
if(length(small_subbasin$unitarea) > 0) {
xx = small_subbasin[order(-small_subbasin$uparea,-small_subbasin$aggdown),]
## 
for (i in 1 : length(xx$agg)) {
##  
yy <- which(output_basin$agg == xx$agg[i])
xy <- which(output_basin$aggdown == xx$agg[i])
##
if (length(xy) > 0) {
xz <- xy[which(output_basin$uparea[xy] == max(output_basin$uparea[xy]))]
zz <- which(output_basin$aggdown == output_basin$agg[xz])
##
output_basin$agg[which(output_basin$agg == output_basin$agg[xz])] <- output_basin$agg[yy][1]
output_basin$aggdown[which(output_basin$agg == output_basin$agg[xz])] <- output_basin$aggdown[yy][1]
##
if (length(zz) > 0) { output_basin$aggdown[zz] <- output_basin$agg[yy][1] }
##
}
}
##
agg_basin = aggregate(output_basin[,c("unitarea")] %>% as.data.frame() %>% select(-geometry), by = list(output_basin$agg), FUN = sum)
colnames(agg_basin)[1] <- "COMID"
agg_basin = left_join(agg_basin, output_basin[,c("COMID","NextDownID","uparea")] %>% as.data.frame() %>% select(-geometry), by = "COMID")
colnames(agg_basin) <- c("agg","unitarea","aggdown","uparea")
##
}
if (length(small_subbasin$unitarea) == 0) { break }
}
##
###############################################################################################################################
agg_basin = aggregate(output_basin[,c("unitarea")], st_drop_geometry(output_basin[,c("agg")]), FUN = sum)
colnames(agg_basin)[1] <- "COMID"
agg_basin = left_join(agg_basin, output_basin[,c("COMID","aggdown","uparea")] %>% as.data.frame() %>% select(-geometry), by = "COMID")
colnames(agg_basin) <- c("COMID","unitarea","NextDownID","uparea","geometry")
##
###############################################################################################################################
######### Aggregating river network based on the aggregated sub-basins
###############################################################################################################################
output_river = left_join(output_river, output_basin[,c("COMID","agg")] %>% as.data.frame() %>% select(-geometry), by = "COMID")
output_river$mask <- 0
kk = output_river$agg[!duplicated(output_river$agg)]
for (i in kk) {
xx = which(output_river$agg == i)
for (qq in 1 : 1000) {
yy <- xx[which(output_river$uparea[xx] == max(output_river$uparea[xx]))]
output_river$mask[yy] <- 1
xx = which(output_river$NextDownID == output_river$COMID[yy])
if (length(xx) < 1) { break }
}}
##
output_river = output_river[output_river$mask == 1,]
output_river$slope = output_river$slope*output_river$lengthkm
##
output_river = aggregate(output_river[,c("lengthkm","slope")], st_drop_geometry(output_river[,"agg"]), sum)
colnames(output_river)[1] <- "COMID"
output_river$slope = output_river$slope / output_river$lengthkm
output_river = left_join(output_river, agg_basin[,c("COMID","NextDownID")] %>% as.data.frame() %>% select(-geometry), by = "COMID")
output_river = left_join(output_river, input_river[,c("COMID","uparea","order")] %>% as.data.frame() %>% select(-geometry), by = "COMID")
##
aggregated_out <- list("output_basin" = agg_basin, "output_river" = output_river)
##
return(aggregated_out)
##
}

# Main script to read arguments and call the function
args <- commandArgs(trailingOnly = TRUE)

# Expecting args: input_basin_path, input_river_path, min_subarea, min_slope, min_length, output_basin_path, output_river_path
input_basin_path <- args[1]
input_river_path <- args[2]
min_subarea <- as.numeric(args[3])
min_slope <- as.numeric(args[4])
min_length <- as.numeric(args[5])
output_basin_path <- args[6]
output_river_path <- args[7]

# Read input data
input_basin <- readRDS(input_basin_path)
input_river <- readRDS(input_river_path)

# Call the function
result <- basin_aggregation(input_basin, input_river, min_subarea, min_slope, min_length)

# Save the results
saveRDS(result$output_basin, output_basin_path)
saveRDS(result$output_river, output_river_path)