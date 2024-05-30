# Define the custom library paths
custom_lib_paths <- c("/home/fuaday/R/x86_64-pc-linux-gnu-library/4.3")
#custom_lib_paths <- c("/project/6008034/Climate_Forcing_Data/assets/r-envs/exact-extract-env/v5/R-4.1/x86_64-pc-linux-gnu")

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
required_packages <- c("dplyr", "ggplot2", "terra", "raster", "sf", "exactextractr")  # Add any required packages here

# Install and load required packages
install_and_load(required_packages)

# Define your function
my_function <- function(input_data, output_file) {
  # Perform operations
  result <- mean(input_data)
  
  # Save the result to a file
  write.csv(data.frame(result), file = output_file)
}

# Read input data (if provided as a command line argument)
args <- commandArgs(trailingOnly = TRUE)
input_data <- as.numeric(unlist(strsplit(args[1], ",")))
output_file <- args[2]

# Call the function
my_function(input_data, output_file)
