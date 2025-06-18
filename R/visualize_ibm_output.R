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

met <- read_csv("./02_stratified/inputs/met.csv") %>%
  mutate(ShortWave = ifelse(hour(time) %in% c(19:23,0:6),0,ShortWave))
write.csv(met, "./02_stratified/inputs/met.csv", row.names = FALSE)
the_depths = c(0.1, 0.33, 0.66, 1, 1.33, 1.66, 2, 2.33, 2.66, 3, 3.33, 3.66, 4, 4.33, 4.66, 5, 5.33, 5.66, 6, 6.33, 6.66, 7, 7.33, 7.66, 8, 8.33, 8.66, 9, 9.25)
wq_init_vals = c(359.1481,370.4191,373.3269,373.455,351.2606,341.9009,340.3638,360.9128,369.3069,397.7706,378.5396,378.5887,134.808,15.6059,8.509375,4.36468,3.5225,215.0834,279.5306,291.72187,293.40718,294.77,95.6459,295.7434,296.3697,296.7306,296.4591,295.5828,291.5922,0.388,0.39,0.395,0.4,0.42,0.44345,0.46,0.48,0.5,0.525,0.55,0.5543,0.6,0.7,0.9,1.164,1.5,2,2.3,2.7161,2.85,3,3.5,4.2,4.2,4.3,4.4,4.54545,4.6,0.6,0.6,0.6,0.6,0.6,0.6,0.6,0.6,0.6,0.6,0.6,0.6,0.6,0.6,0.6,0.6,0.6,0.6,0.6,0.6,0.6,0.6,0.6,0.6,0.6,0.6,0.6,0.6,0.6,0.055,0.055,0.055,0.055,0.055,0.055,0.055,0.055,0.055,0.055,0.055,0.055,0.055,0.055,0.055,0.055,0.055,0.055,0.055,0.055,0.055,0.055,0.055,0.055,0.055,0.055,0.055,0.055,0.055,24,24,24,24,24,24,24,24,24,24,24,24,24,24,24,24,24,24,24,24,24,24,24,24,24,24,24,24,24)
29*5
oxy <- wq_init_vals[1:29]
plot(oxy, the_depths, type = "l")


# Set current nc file
current_scenario_folder = "./02_stratified"
nc_file <- file.path(paste0(current_scenario_folder, "/output/output.nc"))

# Get list of output vars
nc <- ncdf4::nc_open(nc_file)
vars <- names(nc$var)
names(nc$dim)

# Get env vars for ptm
env_out <- list()
env_vars <- c("NIT_nit","temp","extc","radn","PHS_frp")

for(i in 1:length(env_vars)){
  env_out[[i]] <- ncdf4::ncvar_get(nc, var = env_vars[i])
}

for(i in 1:length(env_vars)){
  p <- plot_var(nc_file, var_name = env_vars[i], reference = "surface", interval = 0.1, show.legend = TRUE)
  print(p)
}

check <- env_out[[5]]

names(env_out) <- env_vars


# Retrieve relevant variables for ptm
ptm_out <- list()
ptm_vars <- vars[grep("particle",vars)]

for(i in 1:length(ptm_vars)){
  ptm_out[[i]] <- ncdf4::ncvar_get(nc, var = ptm_vars[i])
}

names(ptm_out) <- ptm_vars

n_par = 100

for(i in 15:17){ #1:length(ptm_out)
  
  plot_dat <- t(ptm_out[[i]][c(1:(n_par - 1)),])
  
  
  # Associate datetimes to output
  start <- as.POSIXct("2015-07-08 12:00:00")
  interval <- 60
  end <- as.POSIXct("2015-07-15 12:00:00")
  times <- data.frame(seq(from=start, by=interval*60, to=end))
  
  plot_dat2 <- bind_cols(times, plot_dat)
  colnames(plot_dat2)[1] <- "datetime"
  
  plot_dat3 <- plot_dat2 %>%
    pivot_longer(cols = -datetime, names_to = "particle_id",
                            values_to = "particle_attribute")
  
  if(i %in% c(6:9)){
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

check <- diag_out[["PAM_id_d_frp"]]

