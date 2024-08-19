# Plot scenario driver data
# Author: Mary Lofton
# Date: 09APR24

# Purpose: plot driver met and inflow files so folks can see what is happening in each
# ptm test scenario

# Load packages
library(tidyverse)
library(lubridate)
library(cowplot)

# Manually create temperature profile initial conditions (yay.)
the_depths_unstrat = c(0.1, 0.33, 0.66, 1, 1.33, 1.66, 2, 2.33, 2.66, 3, 3.33, 3.66, 4, 4.33, 4.66, 5, 5.33, 5.66, 6, 6.33, 6.66, 7, 7.33, 7.66, 8, 8.33, 8.66, 9, 9.25)
the_temps_unstrat = c(5.88,5.88,5.88,5.88,5.88,5.88,5.88,5.88,5.88,5.88,5.88,5.88,5.88,5.88,5.88,5.88,5.88,5.88,5.88,5.88,5.88,5.88,5.88,5.88,5.88,5.88,5.88,5.88,5.88)
init_unstrat <- tibble(depth = the_depths_unstrat,
                    wtemp = the_temps_unstrat)

the_depths_strat = c(0.1, 0.33, 0.66, 1, 1.33, 1.66, 2, 2.33, 2.66, 3, 3.33, 3.66, 4, 4.33, 4.66, 5, 5.33, 5.66, 6, 6.33, 6.66, 7, 7.33, 7.66, 8, 8.33, 8.66, 9, 9.25)
the_temps_strat = c(25.7279,25.2848,24.8368,24.4897,24.0165,23.4701,23.2128,22.9678,22.7348,22.2422,21.6762,20.9439,19.9116,18.6905,17.9063,16.8599,15.8269,13.1871,12.5998,12.58,12.5726,12.5591,12.5571,12.5542,12.5292,12.527,12.5199,12.5151,12.119)
init_strat <- tibble(depth = the_depths_strat,
                       wtemp = the_temps_strat)

# Declare scenario names
scenarios <- c("01_unstratified","02_stratified","03_unstratified_wind","04_stratified_wind",
               "05_unstratified_inflow","06_unstratified_outflow","07_stratified_inflow",
               "08_stratified_outflow","09_unstratified_observed_wind_inflow",
               "10_stratified_observed_wind_inflow")


for(i in 1:length(scenarios)){
  
  if(i %in% c(1,3,5,6,9)){
    if(i == 5){
      plot_temp <- ggplot(data = init_unstrat[c(1:16),], aes(x = wtemp, y = depth))+
        scale_y_reverse()+
        geom_point()+
        ggtitle(paste0("Scenario ",i))+
        ylab("Depth (m)")+
        xlab("Water Temperature (ºC)")+
        theme_bw(base_size = 16)
    } else {
    plot_temp <- ggplot(data = init_unstrat, aes(x = wtemp, y = depth))+
      scale_y_reverse()+
      geom_point()+
      ggtitle(paste0("Scenario ",i))+
      ylab("Depth (m)")+
      xlab("Water Temperature (ºC)")+
      theme_bw(base_size = 16)
    }
  } else {
    if(i == 7){
    plot_temp <- ggplot(data = init_strat[c(1:16),], aes(x = wtemp, y = depth))+
      scale_y_reverse()+
      geom_point()+
      ggtitle(paste0("Scenario ",i))+
      ylab("Depth (m)")+
      xlab("Water Temperature (ºC)")+
      theme_bw(base_size = 16)
    } else {
      plot_temp <- ggplot(data = init_strat, aes(x = wtemp, y = depth))+
        scale_y_reverse()+
        geom_point()+
        ggtitle(paste0("Scenario ",i))+
        ylab("Depth (m)")+
        xlab("Water Temperature (ºC)")+
        theme_bw(base_size = 16)
    }
  }
  
scen_met <- read_csv(paste0("./",scenarios[i],"/inputs/met.csv"))

plot_met <- ggplot(data = scen_met, aes(x = time, y = WindSpeed))+
  geom_point()+
  ylab("Windspeed (m/s)")+
  xlab("")+
  theme_bw(base_size = 16)+
  theme(axis.text.x = element_text(angle = 45, hjust=1))

if(i %in% c(5,6,7,8)){
scen_inf <- read_csv(paste0("./",scenarios[i],"/inputs/inflow1.csv"))

plot_inf <- ggplot(data = scen_inf, aes(x = time, y = FLOW))+
  geom_point()+
  ylab("Flow (cms)")+
  xlab("")+
  theme_bw(base_size = 16)+
  theme(axis.text.x = element_text(angle = 45, hjust=1))

} else {
  plot_inf <- ggplot() + 
    theme_minimal(base_size = 16) + 
    ggtitle("No inflow/outflow") + 
    theme(panel.background = element_rect(fill = "white", color = 'white'),
          plot.title = element_text(hjust = 0.5),
          plot.background = element_rect(fill = "white", color = 'white'))
}

# create two plots in right column
right_column <- plot_grid(plot_met, plot_inf, labels = c('B', 'C'), ncol = 1)

plot_scen <- plot_grid(plot_temp, right_column, labels = c('A', ''), ncol = 2,
                       rel_widths = c(1, 1.5))

ggsave(plot_scen, filename = paste0("./plots/",scenarios[i],"/IC_drivers.png"),
       device = "png", height = 6, width = 9.5, units = "in")

}
  
