# Visualize PTM model output
# Author: Mary Lofton
# Date: 08MAY24

# Purpose: visualize model output from ptm model

# Load packages
library(ncdf4)

# Set current nc file
current_scenario_folder = "./1_unstratified"
nc_file <- file.path(paste0(current_scenario_folder, "/output/output.nc"))

# Get list of output vars
nc <- ncdf4::nc_open(nc_file)
names(nc$var)

# Retrieve relevant variables for ptm
ptm_out <- list()
ptm_vars <- c("Particle_Height","Particle_Mass","Particle_Diameter",
              "Particle_Density","Particle_Velocity","Particle_vvel")

for(i in 1:length(ptm_vars)){
  ptm_out[[i]] <- ncdf4::ncvar_get(nc, var = ptm_vars[i])
}

names(ptm_out) <- ptm_vars
