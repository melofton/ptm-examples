# Visualize PTM model output
# Author: Mary Lofton
# Date: 23MAY25

# Purpose: visualize model output from ptm model

# Load packages
#devtools::install_github("GLEON/GLM3r")
#devtools::install_github("GLEON/glmtools")
library(ncdf4)
library(tidyverse)
library(lubridate)
library(cowplot)
library(glmtools)
library(rLakeAnalyzer)

# 01_unstratified_MH ----

# Set current nc file
current_scenario_folder = "./02_stratified"
nc_file <- file.path(paste0(current_scenario_folder, "/output/output.nc"))

# Get list of output vars
nc <- ncdf4::nc_open(nc_file)
vars <- names(nc$var)
names(nc$dim)

# Get env vars for ptm
env_out <- list()
env_vars <- c("NIT_nit","temp")

for(i in 1:length(env_vars)){
  env_out[[i]] <- ncdf4::ncvar_get(nc, var = env_vars[i])
}

for(i in 1:length(env_vars)){
  p <- plot_var(nc_file, var_name = env_vars[i], reference = "surface", interval = 0.1, show.legend = TRUE)
  print(p)
}

check_no3 <- env_out[[1]]

names(env_out) <- env_vars


# Retrieve relevant variables for ptm
ptm_out <- list()
ptm_vars <- vars[grep("particle",vars)]

for(i in 1:length(ptm_vars)){
  ptm_out[[i]] <- ncdf4::ncvar_get(nc, var = ptm_vars[i])
}

names(ptm_out) <- ptm_vars

n_par = 100

for(i in 1:length(ptm_out)){ #1:length(ptm_out)
  
  plot_dat <- t(ptm_out[[i]][c(1:(n_par - 1)),])
  
  
  # Associate datetimes to output
  start <- as.POSIXct("2015-07-08 12:00:00")
  interval <- 60
  end <- as.POSIXct("2015-07-09 12:00:00")
  times <- data.frame(seq(from=start, by=interval*60, to=end))
  
  plot_dat2 <- bind_cols(times, plot_dat)
  colnames(plot_dat2)[1] <- "datetime"
  
  plot_dat3 <- plot_dat2 %>%
    pivot_longer(cols = -datetime, names_to = "particle_id",
                            values_to = "particle_attribute")
  
  if(i %in% c(6:8)){
    plot_dat3 <- plot_dat3 %>%
      filter(!particle_attribute == -9999)
  }
  
  p <- ggplot(data = plot_dat3)+
    geom_line(aes(x = datetime, y = particle_attribute, group = particle_id,
             color = particle_id))+
    ggtitle(paste(i,ptm_vars[i]))+
    theme_bw()+
    theme(legend.position = "none")
  print(p)
    
}

# now for diag vars
diag_vars <- vars[grep("PAM",vars)]

diag_out <- NULL

for(i in 1:length(diag_vars)){
  diag_out[[i]] <- ncdf4::ncvar_get(nc, var = diag_vars[i])
}

names(diag_out) <- diag_vars

for(i in 1:length(diag_out)){
  p <- plot_var(nc_file, var_name = diag_vars[i], reference = "surface", interval = 0.1, show.legend = TRUE)
  print(p)
}

plot_var(nc_file, var_name = "PAM_id_cells", reference = "surface", interval = 0.1, show.legend = TRUE)
