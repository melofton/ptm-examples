# Visualize PTM model output
# Author: Mary Lofton
# Date: 08MAY24

# Purpose: visualize model output from ptm model

# Load packages
library(ncdf4)
library(tidyverse)
library(lubridate)
library(cowplot)
library(glmtools)

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

# Get particle status
status <- data.frame(t(ptm_out[["particle_status"]]))
hist(ptm_out[["particle_status"]])
hist(unname(unlist(status[720,])))

# Get particle flag
flag <- data.frame(t(ptm_out[["particle_flag"]]))
hist(ptm_out[["particle_flag"]])
hist(unname(unlist(flag[720,])))

# Get particle heights
heights <- data.frame(t(ptm_out[["particle_height"]]))
hist(ptm_out[["particle_height"]])
hist(unname(unlist(heights[720,])))

# Plot status vs flag
sed_status <- data.frame(particle_flag = unname(unlist(flag[720,])),
                         particle_status = unname(unlist(status[720,])))
ggplot(data = sed_status, aes(x = particle_flag, y = particle_status))+
  geom_point(position=position_jitter(width=0.05, height=0.05), alpha = 0.4, color = "darkgreen")+
  ggtitle("sed_deactivation = .false.")+
  ylim(c(-0.05,1.05))+
  #xlim(c(0,1))+
  theme_classic()

# Plot particle height vs flag
flag_height <- data.frame(particle_flag = unname(unlist(flag[720,])),
                          particle_height = unname(unlist(heights[720,])),
                          particle_status = factor(unname(unlist(status[720,]))))
ggplot(data = flag_height, aes(x = particle_flag, y = particle_height, group = particle_status, color = particle_status))+
  geom_point(alpha = 0.4)+
  ggtitle("sed_deactivation = .false.")+
  geom_hline(yintercept = 0.02)+
  theme_classic()

start <- as.POSIXct("2016-01-01 12:00:00")
interval <- 60

end <- start + as.difftime(30, units="days")

times <- data.frame(seq(from=start, by=interval*60, to=end)[1:720])

heights2 <- bind_cols(times, heights)
colnames(heights2)[1] <- "datetime"
heights3 <- heights2 %>%
  pivot_longer(cols = X1:X100, names_to = "particle_id", values_to = "height_m")

lakeNum <- read_csv("./01_unstratified/output/lake.csv") %>%
  select(time, LakeNumber) %>%
  mutate(time = as.POSIXct(time))
min(lakeNum$LakeNumber, na.rm = TRUE)

p1 <- ggplot()+
  geom_line(data = heights3, aes(x = datetime, y = height_m, group = particle_id, color = particle_id))+
  theme_classic()+
  ylim(c(0,9.3))+
  theme(legend.position = "none")
p2 <- ggplot()+
  geom_line(data = lakeNum, aes(x = time, y = LakeNumber), color = "black")+
  theme_classic()

plot_grid(p1, p2, nrow = 2, rel_heights = c(1.5,1))

# visualize temperature for stratified example sim

temp_heatmap <- plot_var_nc(nc_file, var_name = "temp", reference = "surface", interval = 0.1, show.legend = TRUE)
temp_heatmap


