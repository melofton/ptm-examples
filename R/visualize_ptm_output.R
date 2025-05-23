# Visualize PTM model output
# Author: Mary Lofton
# Date: 23MAY25

# Purpose: visualize model output from ptm model

# Load packages
library(ncdf4)
library(tidyverse)
library(lubridate)
library(cowplot)
library(glmtools)
library(rLakeAnalyzer)

# 01_unstratified ----

# Set current nc file
current_scenario_folder = "./01_unstratified"
nc_file <- file.path(paste0(current_scenario_folder, "/output/output.nc"))

# Get list of output vars
nc <- ncdf4::nc_open(nc_file)
names(nc$var)
names(nc$dim)

# Retrieve relevant variables for ptm
ptm_out <- list()
ptm_vars <- c("particle_height","particle_mass","particle_diameter",
              "particle_density","particle_vvel","particle_status","particle_flag")

for(i in 1:length(ptm_vars)){
  ptm_out[[i]] <- ncdf4::ncvar_get(nc, var = ptm_vars[i])
}

names(ptm_out) <- ptm_vars

dim(ptm_out[[1]])

# Get particle status - only keeping initialized particles (n = 20)
status <- data.frame(t(ptm_out[["particle_status"]][c(1:20),]))

# Get particle flag
flag <- data.frame(t(ptm_out[["particle_flag"]][c(1:20),]))

# Get particle heights
heights <- data.frame(t(ptm_out[["particle_height"]][c(1:20),]))

# Associate datetimes to output
start <- as.POSIXct("2016-01-01 12:00:00")
interval <- 60
end <- as.POSIXct("2016-01-31 12:00:00")
times <- data.frame(seq(from=start, by=interval*60, to=end))

# Look at heights over time
heights2 <- bind_cols(times, heights)
colnames(heights2)[1] <- "datetime"
heights3 <- heights2 %>%
  pivot_longer(cols = X1:X20, names_to = "particle_id", values_to = "height_m") 

heights_plot <- ggplot(data = heights3, aes(x = datetime, y = height_m, group = particle_id, color = particle_id))+
  geom_line()+
  theme_bw()+
  theme(legend.position = "none")
heights_plot

lakeNum <- read_csv("./01_unstratified/output/lake.csv") %>%
  select(time, LakeNumber) %>%
  mutate(time = as.POSIXct(time))
min(lakeNum$LakeNumber, na.rm = TRUE)

ggplot()+
  geom_line(data = lakeNum, aes(x = time, y = LakeNumber), color = "black")+
  theme_classic()

# visualize temperature 
plot_var(nc_file, var_name = "temp", reference = "surface", interval = 0.1, show.legend = TRUE)

# visualize epsilon 
plot_var(nc_file, var_name = "epsilon", reference = "surface", interval = 0.1, show.legend = TRUE)

# 02_stratified ----

# Set current nc file
current_scenario_folder = "./02_stratified"
nc_file <- file.path(paste0(current_scenario_folder, "/output/output.nc"))

# Get list of output vars
nc <- ncdf4::nc_open(nc_file)
names(nc$var)
names(nc$dim)

# Retrieve relevant variables for ptm
ptm_out <- list()
ptm_vars <- c("particle_height","particle_mass","particle_diameter",
              "particle_density","particle_vvel","particle_status","particle_flag")

for(i in 1:length(ptm_vars)){
  ptm_out[[i]] <- ncdf4::ncvar_get(nc, var = ptm_vars[i])
}

names(ptm_out) <- ptm_vars

dim(ptm_out[[1]])

# Get particle status - only keeping initialized particles (n = 20)
status <- data.frame(t(ptm_out[["particle_status"]][c(1:20),]))

# Get particle flag
flag <- data.frame(t(ptm_out[["particle_flag"]][c(1:20),]))

# Get particle heights
heights <- data.frame(t(ptm_out[["particle_height"]][c(1:20),]))

# Associate datetimes to output
start <- as.POSIXct("2015-07-08 12:00:00")
interval <- 60
end <- as.POSIXct("2015-08-08 12:00:00")
times <- data.frame(seq(from=start, by=interval*60, to=end))

# get thermocline depth
temp <- get_var(file = nc_file, var_name = "temp")
depths <- 9.3 - as.numeric(sapply(strsplit(colnames(temp)[2:21], split = "_"),"[[", 2))
temp_colnames <- paste0("wtr_",depths)
colnames(temp)[2:21] <- temp_colnames
td <- ts.thermo.depth(wtr = temp, seasonal = TRUE, na.rm = TRUE) %>%
  mutate(thermo.height = 9.3 - thermo.depth,
         datetime = times$seq.from...start..by...interval...60..to...end.)

# Get heights over time
heights2 <- bind_cols(times, heights)
colnames(heights2)[1] <- "datetime"
heights3 <- heights2 %>%
  pivot_longer(cols = X1:X20, names_to = "particle_id", values_to = "height_m") %>%
  mutate(datetime = as_datetime(datetime))

heights_status_flag <- left_join(heights3, status3, by = c("datetime","particle_id")) %>%
  mutate(status = ifelse(status == 1,"alive","dead"))

my.cols <- c("gray","purple")

heights_plot <- ggplot()+
  geom_line(data = heights_status, aes(x = datetime, y = height_m, group = particle_id, color = status), linewidth = 0.5)+
  geom_line(data = td, aes(x = datetime, y = thermo.height))+
  theme_bw()+
  theme(legend.position = "none")+
  scale_color_manual(values = my.cols)
heights_plot

stacked_data <- left_join(heights_status, td, by = "datetime") %>%
  filter(!status == "dead") %>%
  mutate(position = ifelse(height_m > thermo.height, "epi",
                           ifelse(height_m <= thermo.height & height_m > 0,"hypo",
                                  ifelse(height_m == 0,"sed",NA)))) %>%
  select(-particle_id) %>%
  group_by(datetime, position) %>%
  summarize(n = n()) 

position_plot <- ggplot(data = stacked_data)+
  geom_area(aes(x = datetime, y = n, color = position, group = position, fill = position),
            stat = "identity")+
  theme(legend.position = "bottom")
position_plot

plot_grid(heights_plot, position_plot, nrow = 2)

lakeNum <- read_csv("./02_stratified/output/lake.csv") %>%
  select(time, LakeNumber) %>%
  mutate(time = as.POSIXct(time))
min(lakeNum$LakeNumber, na.rm = TRUE)

ggplot()+
  geom_line(data = lakeNum, aes(x = time, y = LakeNumber), color = "black")+
  theme_classic()

# visualize temperature 
plot_var(nc_file, var_name = "temp", reference = "surface", interval = 0.1, show.legend = TRUE)

# visualize epsilon 
plot_var(nc_file, var_name = "epsilon", reference = "surface", interval = 0.1, show.legend = TRUE)



# 07_stratified_inflow ----

# Set current nc file
current_scenario_folder = "./07_stratified_inflow"
nc_file <- file.path(paste0(current_scenario_folder, "/output/output.nc"))

# Get list of output vars
nc <- ncdf4::nc_open(nc_file)
names(nc$var)
names(nc$dim)

# visualize temperature 
plot_var(nc_file, var_name = "temp", reference = "surface", interval = 0.1, show.legend = TRUE)

# visualize epsilon 
plot_var(nc_file, var_name = "epsilon", reference = "surface", interval = 0.1, show.legend = TRUE)

# Retrieve relevant variables for ptm
ptm_out <- list()
ptm_vars <- c("particle_height","particle_mass","particle_diameter",
              "particle_density","particle_vvel","particle_status","particle_flag")

for(i in 1:length(ptm_vars)){
  ptm_out[[i]] <- ncdf4::ncvar_get(nc, var = ptm_vars[i])
}

names(ptm_out) <- ptm_vars

dim(ptm_out[[1]])

# Get particle status - only keeping initialized particles (n = 20)
status <- data.frame(t(ptm_out[["particle_status"]]))

# Get particle flag
flag <- data.frame(t(ptm_out[["particle_flag"]]))

# Get particle heights
heights <- data.frame(t(ptm_out[["particle_height"]]))

# Associate datetimes to output
start <- as.POSIXct("2015-07-08 12:00:00")
interval <- 60
end <- as.POSIXct("2015-08-08 12:00:00")
times <- data.frame(seq(from=start, by=interval*60, to=end))

# get thermocline depth
temp <- get_var(file = nc_file, var_name = "temp")
depths <- as.numeric(sapply(strsplit(colnames(temp)[2:21], split = "_"),"[[", 2))
height <- 9.3 - depths
height[height < 0] <- 0
temp_colnames <- paste0("wtr_",height)
colnames(temp)[2:21] <- temp_colnames
td <- ts.thermo.depth(wtr = temp, seasonal = TRUE, na.rm = TRUE) %>%
  mutate(thermo.height = 9.3 - thermo.depth,
         datetime = times$seq.from...start..by...interval...60..to...end.)

# Get heights over time
heights2 <- bind_cols(times, heights)
colnames(heights2)[1] <- "datetime"
heights3 <- heights2 %>%
  pivot_longer(cols = X1:X10000, names_to = "particle_id", values_to = "height_m") %>%
  mutate(datetime = as_datetime(datetime))

# Get status over time
status2 <- bind_cols(times, status)
colnames(status2)[1] <- "datetime"
status3 <- status2 %>%
  pivot_longer(cols = X1:X10000, names_to = "particle_id", values_to = "status") %>%
  mutate(datetime = as_datetime(datetime))

# Get flag over time
flag2 <- bind_cols(times, flag)
colnames(flag2)[1] <- "datetime"
flag3 <- flag2 %>%
  pivot_longer(cols = X1:X10000, names_to = "particle_id", values_to = "flag") %>%
  mutate(datetime = as_datetime(datetime))

heights_status_flag <- left_join(heights3, status3, by = c("datetime","particle_id")) %>%
  left_join(., flag3, by = c("datetime","particle_id")) %>%
  filter(!flag == 3 & !height_m == -9999) %>%
  mutate(status = ifelse(status == 1,"alive","dead"))

my.cols <- c("gray","purple")

heights_plot <- ggplot()+
  geom_line(data = heights_status_flag, aes(x = datetime, y = height_m, group = particle_id, color = status), linewidth = 0.5)+
  geom_line(data = td, aes(x = datetime, y = thermo.height))+
  theme_bw()+
  theme(legend.position = "none")+
  scale_color_manual(values = my.cols)
heights_plot

stacked_data <- left_join(heights_status_flag, td, by = "datetime") %>%
  filter(!status == "dead") %>%
  mutate(position = ifelse(height_m > thermo.height, "epi",
                           ifelse(height_m <= thermo.height & height_m > 0,"hypo",
                                  ifelse(height_m == 0,"sed",NA)))) %>%
  select(-particle_id) %>%
  group_by(datetime, position) %>%
  summarize(n = n()) 

position_plot <- ggplot(data = stacked_data)+
  geom_area(aes(x = datetime, y = n, color = position, group = position, fill = position),
            stat = "identity")+
  theme(legend.position = "bottom")
position_plot

plot_grid(heights_plot, position_plot, nrow = 2)



# 08_stratified_outflow ----

# Set current nc file
current_scenario_folder = "./08_stratified_outflow"
nc_file <- file.path(paste0(current_scenario_folder, "/output/output.nc"))

# Get list of output vars
nc <- ncdf4::nc_open(nc_file)
names(nc$var)
names(nc$dim)

# visualize temperature 
plot_var(nc_file, var_name = "temp", reference = "surface", interval = 0.1, show.legend = TRUE)

# visualize epsilon 
plot_var(nc_file, var_name = "epsilon", reference = "surface", interval = 0.1, show.legend = TRUE)

# Retrieve relevant variables for ptm
ptm_out <- list()
ptm_vars <- c("particle_height","particle_mass","particle_diameter",
              "particle_density","particle_vvel","particle_status","particle_flag")

for(i in 1:length(ptm_vars)){
  ptm_out[[i]] <- ncdf4::ncvar_get(nc, var = ptm_vars[i])
}

names(ptm_out) <- ptm_vars

dim(ptm_out[[1]])

# Get particle status - only keeping initialized particles (n = 20)
status <- data.frame(t(ptm_out[["particle_status"]]))

# Get particle flag
flag <- data.frame(t(ptm_out[["particle_flag"]]))

# Get particle heights
heights <- data.frame(t(ptm_out[["particle_height"]]))

# Associate datetimes to output
start <- as.POSIXct("2015-07-08 12:00:00")
interval <- 60
end <- as.POSIXct("2015-08-08 12:00:00")
times <- data.frame(seq(from=start, by=interval*60, to=end))

# get thermocline depth
temp <- get_var(file = nc_file, var_name = "temp")
depths <- as.numeric(sapply(strsplit(colnames(temp)[2:21], split = "_"),"[[", 2))
height <- 9.3 - depths
height[height < 0] <- 0
temp_colnames <- paste0("wtr_",height)
colnames(temp)[2:21] <- temp_colnames
td <- ts.thermo.depth(wtr = temp, seasonal = TRUE, na.rm = TRUE) %>%
  mutate(thermo.height = 9.3 - thermo.depth,
         datetime = times$seq.from...start..by...interval...60..to...end.)

# Get heights over time
heights2 <- bind_cols(times, heights)
colnames(heights2)[1] <- "datetime"
heights3 <- heights2 %>%
  pivot_longer(cols = X1:X10000, names_to = "particle_id", values_to = "height_m") %>%
  mutate(datetime = as_datetime(datetime))

# Get status over time
status2 <- bind_cols(times, status)
colnames(status2)[1] <- "datetime"
status3 <- status2 %>%
  pivot_longer(cols = X1:X10000, names_to = "particle_id", values_to = "status") %>%
  mutate(datetime = as_datetime(datetime))

# Get flag over time
flag2 <- bind_cols(times, flag)
colnames(flag2)[1] <- "datetime"
flag3 <- flag2 %>%
  pivot_longer(cols = X1:X10000, names_to = "particle_id", values_to = "flag") %>%
  mutate(datetime = as_datetime(datetime))

heights_status_flag <- left_join(heights3, status3, by = c("datetime","particle_id")) %>%
  left_join(., flag3, by = c("datetime","particle_id")) %>%
  filter(!flag == 3 & !height_m == -9999) %>%
  mutate(status = ifelse(status == 1,"alive","dead"))

my.cols <- c("gray","purple")

heights_plot <- ggplot()+
  geom_line(data = heights_status_flag, aes(x = datetime, y = height_m, group = particle_id, color = status), linewidth = 0.5)+
  geom_line(data = td, aes(x = datetime, y = thermo.height))+
  theme_bw()+
  theme(legend.position = "none")+
  scale_color_manual(values = my.cols)
heights_plot

stacked_data <- left_join(heights_status_flag, td, by = "datetime") %>%
  filter(!status == "dead") %>%
  mutate(position = ifelse(height_m > thermo.height, "epi",
                           ifelse(height_m <= thermo.height & height_m > 0,"hypo",
                                  ifelse(height_m == 0,"sed",NA)))) %>%
  select(-particle_id) %>%
  group_by(datetime, position) %>%
  summarize(n = n()) 

position_plot <- ggplot(data = stacked_data)+
  geom_area(aes(x = datetime, y = n, color = position, group = position, fill = position),
            stat = "identity")+
  theme(legend.position = "bottom")
position_plot

plot_grid(heights_plot, position_plot, nrow = 2)









# 01_unstratified_MH ----

# Set current nc file
current_scenario_folder = "./01_unstratified_MH"
nc_file <- file.path(paste0(current_scenario_folder, "/output/output.nc"))

# Get list of output vars
nc <- ncdf4::nc_open(nc_file)
names(nc$var)
names(nc$dim)

# Retrieve relevant variables for ptm
ptm_out <- list()
ptm_vars <- c("particle_height","particle_mass","particle_diameter",
              "particle_density","particle_vvel","particle_status","particle_flag")

for(i in 1:length(ptm_vars)){
  ptm_out[[i]] <- ncdf4::ncvar_get(nc, var = ptm_vars[i])
}

names(ptm_out) <- ptm_vars

dim(ptm_out[[1]])

# Get particle diameter - only keeping initialized particles (n = 20)
diameter <- data.frame(t(ptm_out[["particle_diameter"]][c(1:20),]))

# Get particle vvel - only keeping initialized particles (n = 20)
vvel <- data.frame(t(ptm_out[["particle_vvel"]][c(1:20),]))

# Get particle heights
heights <- data.frame(t(ptm_out[["particle_height"]][c(1:20),]))

# Associate datetimes to output
start <- as.POSIXct("2016-01-01 12:00:00")
interval <- 60
end <- as.POSIXct("2016-01-31 12:00:00")
times <- data.frame(seq(from=start, by=interval*60, to=end))


# Get diameters over time
diameter2 <- bind_cols(times, diameter)
colnames(diameter2)[1] <- "datetime"
diameter3 <- diameter2 %>%
  pivot_longer(cols = X1:X20, names_to = "particle_id", values_to = "diameter_m") %>%
  mutate(datetime = as_datetime(datetime))

# Get vvel over time
vvel2 <- bind_cols(times, vvel)
colnames(vvel2)[1] <- "datetime"
vvel3 <- vvel2 %>%
  pivot_longer(cols = X1:X20, names_to = "particle_id", values_to = "vvel") %>%
  mutate(datetime = as_datetime(datetime))

# Get heights over time
heights2 <- bind_cols(times, heights)
colnames(heights2)[1] <- "datetime"
heights3 <- heights2 %>%
  pivot_longer(cols = X1:X20, names_to = "particle_id", values_to = "height_m") %>%
  mutate(datetime = as_datetime(datetime)) %>%
  filter(!particle_id == "X20")

diameter_plot <- ggplot()+
  geom_line(data = diameter3, aes(x = datetime, y = diameter_m, group = particle_id, color = particle_id), linewidth = 0.5)+
  theme_bw()+
  theme(legend.position = "none")
diameter_plot

vvel_plot <- ggplot()+
  geom_line(data = vvel3, aes(x = datetime, y = vvel, group = particle_id, color = particle_id), linewidth = 0.5)+
  theme_bw()+
  theme(legend.position = "none")
vvel_plot

heights_plot <- ggplot()+
  geom_line(data = heights3, aes(x = datetime, y = height_m, group = particle_id, color = particle_id), linewidth = 0.5)+
  theme_bw()+
  theme(legend.position = "none")
heights_plot

# visualize temperature 
plot_var(nc_file, var_name = "PTM_total_count", reference = "surface", interval = 0.1, show.legend = TRUE)

# visualize epsilon 
plot_var(nc_file, var_name = "epsilon", reference = "surface", interval = 0.1, show.legend = TRUE)

# visualize temperature 
plot_var(nc_file, var_name = "PTM_total_vvel", reference = "surface", interval = 0.1, show.legend = TRUE)
