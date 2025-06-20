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

# altering met file to have variable PAR so can check how particles respond
# met <- read_csv("./02_stratified/inputs/met.csv") %>%
#   mutate(ShortWave = ifelse(hour(time) %in% c(19:23,0:6),0,ShortWave))
# write.csv(met, "./02_stratified/inputs/met.csv", row.names = FALSE)

# Set current nc file
current_scenario_folder = "./07_stratified_inflow"
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


# Get list of internal particle variables
ptm_out <- list()
ptm_vars <- vars[grep("particle",vars)]

for(i in 1:length(ptm_vars)){
  ptm_out[[i]] <- ncdf4::ncvar_get(nc, var = ptm_vars[i])
}

names(ptm_out) <- ptm_vars

for(i in 1:length(ptm_out)){ #1:length(ptm_out)
  
  plot_dat <- data.frame(t(ptm_out[[i]]))
  status <- data.frame(t(ptm_out[["particle_status"]]))
  
  # Associate datetimes to output
  start <- as.POSIXct("2015-07-08 12:00:00")
  interval <- 60
  end <- as.POSIXct("2015-07-15 12:00:00")
  times <- data.frame(seq(from=start, by=interval*60, to=end))
  
  plot_dat2 <- bind_cols(times, plot_dat)
  colnames(plot_dat2)[1] <- "datetime"
  status2 <- bind_cols(times, status)
  colnames(status2)[1] <- "datetime"
  
  status3 <- status2 %>%
    pivot_longer(cols = X1:X10000, names_to = "particle_id", values_to = "status") %>%
    mutate(datetime = as_datetime(datetime))
  plot_dat3 <- plot_dat2 %>%
    pivot_longer(cols = -datetime, names_to = "particle_id",
                            values_to = "particle_attribute") %>%
    mutate(datetime = as_datetime(datetime))
  
  attribute_status <- left_join(plot_dat3, status3, by = c("datetime","particle_id")) %>%
    filter(!status == 0)
  
  if(i %in% c(6:9)){
    attribute_status <- attribute_status %>%
      filter(!particle_attribute == -9999)
  }
  
  lims <- as.POSIXct(strptime(c("2015-07-08 12:00", "2015-07-15 12:00"), 
                              format = "%Y-%m-%d %H:%M"))
  
  p <- ggplot(data = attribute_status)+
    geom_line(aes(x = datetime, y = particle_attribute, group = particle_id,
             color = particle_id))+
    ggtitle(paste(i,ptm_vars[i]))+
    theme_bw()+
    theme(legend.position = "none")+
    scale_x_datetime(limits = lims, expand = c(0,0))
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

check <- diag_out[["PAM_total_count"]]
plot_var(nc_file, var_name = "PAM_total_count", reference = "surface", interval = 0.1, show.legend = TRUE)

inf <- read_csv("./07_stratified_inflow/inputs/inflow1.csv")
colnames(inf)
ggplot(data = inf, aes(x = time, y = FLOW))+
  geom_line()




###############################################################################
#### Messy code to compare sims with sinking/floating particles - do not run

# sinking <- ptm_out[["particle_height"]]
# sinking1 <- t(sinking[c(1:(n_par - 1)),])
# sinking2 <- bind_cols(times, sinking1)
# colnames(sinking2)[1] <- "datetime"
# sinking3 <- sinking2 %>%
#   pivot_longer(cols = -datetime, names_to = "particle_id",
#                values_to = "particle_attribute") %>%
#   mutate(particle_id = paste0("s",particle_id)) %>%
#   add_column(sim = "sinking") %>%
#   filter(date(datetime) == "2015-07-15")
# 
# floating <- ptm_out[["particle_height"]]
# floating1 <- t(floating[c(1:(n_par - 1)),])
# floating2 <- bind_cols(times, floating1)
# colnames(floating2)[1] <- "datetime"
# floating3 <- floating2 %>%
#   pivot_longer(cols = -datetime, names_to = "particle_id",
#                values_to = "particle_attribute") %>%
#   mutate(particle_id = paste0("f",particle_id)) %>%
#   add_column(sim = "floating") %>%
#   filter(date(datetime) == "2015-07-15")
# 
# compare <- bind_rows(sinking3, floating3) 
# 
# mean_height <- compare %>%
#   group_by(sim) %>%
#   summarize(mean_height = mean(particle_attribute, na.rm = TRUE))
# 
# ggplot()+
#   geom_density(data = compare, aes(x = particle_attribute, group = sim, color = sim))+
#   geom_vline(data = mean_height, aes(xintercept = mean_height, group = sim, color = sim),
#              linetype = "dashed", linewidth = 1)+
#   theme_bw()+
#   coord_flip()+
#   ggtitle("particle height")

################################################################################

