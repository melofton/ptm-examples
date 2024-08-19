# Build scenario driver data files 
# Author: Mary Lofton
# Date: 09APR24

# Purpose: simplify driver data files in existing FCR GLM example for PTM testing

library(tidyverse)
library(lubridate)

# Get initial conditions for scenarios 1, 3, 5, 7 (CTD profile data from FCR)

inUrl1  <- "https://pasta.lternet.edu/package/data/eml/edi/200/13/27ceda6bc7fdec2e7d79a6e4fe16ffdf" 
infile1 <- tempfile()
try(download.file(inUrl1,infile1,method="curl"))
if (is.na(file.size(infile1))) download.file(inUrl1,infile1,method="auto")


dt1 <-read.csv(infile1,header=F 
               ,skip=1
               ,sep=","  
               , col.names=c(
                 "Reservoir",     
                 "Site",     
                 "DateTime",     
                 "Depth_m",     
                 "Temp_C",     
                 "DO_mgL",     
                 "DOsat_percent",     
                 "Cond_uScm",     
                 "SpCond_uScm",     
                 "Chla_ugL",     
                 "Turbidity_NTU",     
                 "pH",     
                 "ORP_mV",     
                 "PAR_umolm2s",     
                 "DescRate_ms",     
                 "Flag_DateTime",     
                 "Flag_Temp_C",     
                 "Flag_DO_mgL",     
                 "Flag_DOsat_percent",     
                 "Flag_Cond_uScm",     
                 "Flag_SpCond_uScm",     
                 "Flag_Chla_ugL",     
                 "Flag_Turbidity_NTU",     
                 "Flag_pH",     
                 "Flag_ORP_mV",     
                 "Flag_PAR_umolm2s",     
                 "Flag_DescRate_ms"    ), check.names=TRUE)

unlink(infile1)
init <- dt1 %>%
  filter(Reservoir == "FCR" & Site == 50 & month(DateTime) %in% c(12,1,2)) %>%
  mutate(Date = date(DateTime))
unique(init$Date)
cast <- init %>%
  filter(Date == "2018-12-06")
plot(cast$Temp_C, rev(cast$Depth_m))
mean(init$Temp_C, na.rm = TRUE)
median(init$Temp_C, na.rm = TRUE)
# I think I'll just go with constant wtemp of 5.88 to keep it simple

# Scenario 1: Unstratified, No Wind, No Inflows/Outflows, Constant Air Temp + Solar

# what is a reasonable solar radiation value for January?
met <- read_csv("./FCR/inputs/met.csv") %>%
  mutate(Date = date(time)) %>%
  filter(Date >= "2016-01-01" & Date <= "2016-01-31") %>%
  select(ShortWave, LongWave, RelHum) %>%
  summarize_all(mean, na.rm = TRUE)

# # A tibble: 1 × 3
# ShortWave LongWave RelHum
# <dbl>    <dbl>  <dbl>
#   1      95.7     256.   63.3

met <- read_csv("./FCR/inputs/met.csv") %>%
  mutate(WindSpeed = 0,
         Rain = 0,
         Snow = 0,
         AirTemp = 5.88,
         ShortWave = 95.7,
         LongWave = 256.0,
         RelHum = 63.3,
         Date = date(time),
         ) %>%
  filter(Date >= "2016-01-01" & Date <= "2016-01-31") %>%
  select(-Date)
write.csv(met, "./1_unstratified/inputs/met.csv", row.names = FALSE)

# Scenario 2: Stratified, No Wind, No Inflows/Outflows

# what is a reasonable solar radiation value for July?
met <- read_csv("./FCR/inputs/met.csv") %>%
  mutate(Date = date(time)) %>%
  filter(Date >= "2015-07-08" & Date <= "2015-08-08") %>%
  select(ShortWave, LongWave, RelHum) %>%
  summarize_all(mean, na.rm = TRUE)

# # A tibble: 1 × 3
# ShortWave LongWave RelHum
# <dbl>    <dbl>  <dbl>
#   1      235.     388.   77.0

met <- read_csv("./FCR/inputs/met.csv") %>%
    mutate(WindSpeed = 0,
           Rain = 0,
           Snow = 0,
           AirTemp = 25.7279,
           ShortWave = 235.0,
           LongWave = 388.0,
           RelHum = 77.0,
           Date = date(time)) %>%
    filter(Date >= "2015-07-08" & Date <= "2015-08-08") %>%
    select(-Date)
write.csv(met, "./2_stratified/inputs/met.csv", row.names = FALSE)
# why am I having to manually edit the datetime in Excel afterwards?

# Scenario 3: Unstratified, Wind, No Inflows/Outflows
met <- read_csv("./FCR/inputs/met.csv") 
hist(met$WindSpeed)
# looks like values of 1, 2, 3, 4 m/s would be reasonable

# let's do:
# 2016-01-07 at 1 m/s
# 2016-01-14 at 2 m/s
# 2016-01-21 at 3 m/s
# 2016-01-28 at 4 m/s
met <- read_csv("./FCR/inputs/met.csv") %>%
  mutate(WindSpeed = 0,
         Rain = 0,
         Snow = 0,
         AirTemp = 5.88,
         ShortWave = 95.7,
         LongWave = 256.0,
         RelHum = 63.3,
         Date = date(time)) %>%
  filter(Date >= "2016-01-01" & Date <= "2016-01-31") %>%
  mutate(WindSpeed = ifelse(Date == "2016-01-07",1,
                            ifelse(Date == "2016-01-14",2,
                                   ifelse(Date == "2016-01-21",3,
                                          ifelse(Date == "2016-01-28",4,WindSpeed))))) %>%
  select(-Date)
plot(met$time, met$WindSpeed)
write.csv(met, "./3_unstratified_wind/inputs/met.csv", row.names = FALSE)

# Scenario 4: Stratified, Wind, No Inflows/Outflows
# let's do:
# 2015-07-14 at 1 m/s
# 2015-07-22 at 2 m/s
# 2015-07-29 at 3 m/s
# 2015-08-04 at 4 m/s
met <- read_csv("./FCR/inputs/met.csv") %>%
    mutate(WindSpeed = 0,
           Rain = 0,
           Snow = 0,
           AirTemp = 25.7279,
           ShortWave = 235.0,
           LongWave = 388.0,
           RelHum = 77.0,
           Date = date(time)) %>%
    filter(Date >= "2015-07-08" & Date <= "2015-08-08") %>%
    mutate(WindSpeed = ifelse(Date == "2015-07-14",1,
                                                   ifelse(Date == "2015-07-22",2,
                                                                               ifelse(Date == "2015-07-29",3,
                                                                                                           ifelse(Date == "2015-08-04",4,WindSpeed))))) %>%
    select(-Date)
plot(met$time, met$WindSpeed)
write.csv(met, "./4_stratified_wind/inputs/met.csv", row.names = FALSE)

# Scenario 5: Lake half full, Unstratified, Constant Air Temp + Solar Radiation, No Wind, One Constant Inflows/Outflow, Inflow 5x Outflow
inf <- read_csv("./FCR/inputs/inflow1.csv")
hist(inf$FLOW)
mean(inf$FLOW, na.rm = TRUE)
median(inf$FLOW, na.rm = TRUE)
# going to use median value of 0.0248 cms * 5 to fill up lake fast and temp of 4
# so inflow stays sunk

inf <- read_csv("./FCR/inputs/inflow1.csv") %>%
  mutate(FLOW = 0.124,
         TEMP = 4,
         Date = date(time)) %>%
  filter(Date >= "2016-01-01" & Date <= "2016-01-31") %>%
  select(-Date)
plot(inf$time, inf$FLOW)
write.csv(inf, "./5_unstratified_inflow_test/inputs/inflow1.csv", row.names = FALSE)

#check to see how outflow was done
inf1 <- read_csv("./FCR/inputs/inflow1.csv") %>%
  mutate(Date = date(time)) %>%
  filter(Date >= "2015-07-08" & Date <= "2015-08-08") %>%
  select(-Date)
inf2 <- read_csv("./FCR/inputs/inflow2.csv") %>%
  mutate(Date = date(time)) %>%
  filter(Date >= "2015-07-08" & Date <= "2015-08-08") %>%
  select(-Date)
out <- read_csv("./FCR/inputs/outflow.csv") %>%
  mutate(Date = date(time)) %>%
  filter(Date >= "2015-07-08" & Date <= "2015-08-08") %>%
  select(-Date)

inf_sum <- inf1 %>%
  mutate(FLOW_ALL = FLOW + inf2$FLOW)
plot(inf_sum$time, inf_sum$FLOW_ALL, type = "l")
lines(out$time, out$FLOW, col = "red")
# sweet they are the same, so we can just subtract SSS inflow from outflow for later scenarios

out <- read_csv("./FCR/inputs/outflow.csv") %>%
  mutate(Date = date(time),
         FLOW = 0.0248) %>%
  filter(Date >= "2016-01-01" & Date <= "2016-01-31") %>%
  select(-Date)
plot(out$time, out$FLOW)
write.csv(out, "./5_unstratified_inflow/inputs/outflow.csv", row.names = FALSE)

# Scenario 6: Lake half full, Unstratified, Constant Air Temp + Solar Radiation, No Wind, One Constant Inflows/Outflow, Outflow 5x Inflow
inf <- read_csv("./FCR/inputs/inflow1.csv")
hist(inf$FLOW)
mean(inf$FLOW, na.rm = TRUE)
median(inf$FLOW, na.rm = TRUE)
# going to use median value of 0.0248 cms and temp of 4
# so inflow stays sunk

inf <- read_csv("./FCR/inputs/inflow1.csv") %>%
  mutate(FLOW = 0.0248,
         TEMP = 4,
         Date = date(time)) %>%
  filter(Date >= "2016-01-01" & Date <= "2016-01-31") %>%
  select(-Date)
plot(inf$time, inf$FLOW)
write.csv(inf, "./6_unstratified_outflow/inputs/inflow1.csv", row.names = FALSE)

out <- read_csv("./FCR/inputs/outflow.csv") %>%
  mutate(Date = date(time),
         FLOW = 0.0248*5) %>%
  filter(Date >= "2016-01-01" & Date <= "2016-01-31") %>%
  select(-Date)
plot(out$time, out$FLOW)
write.csv(out, "./6_unstratified_outflow/inputs/outflow.csv", row.names = FALSE)

# Scenario 7: Lake half full, Stratified, No Wind, One Constant Inflows/Outflow, Inflow 5x Outflow
inf <- read_csv("./FCR/inputs/inflow1.csv") %>%
  filter(month(time) %in% c(7,8))
hist(inf$TEMP)
mean(inf$TEMP, na.rm = TRUE)
# going to use value of 10.6136 degrees C; this will sink to bottom

inf <- read_csv("./FCR/inputs/inflow1.csv") %>%
  mutate(FLOW = 0.0248*5,
         TEMP = 10.6136,
         Date = date(time)) %>%
  filter(Date >= "2015-07-08" & Date <= "2015-08-08") %>%
  select(-Date)
plot(inf$time, inf$FLOW)
write.csv(inf, "./7_stratified_inflow/inputs/inflow1.csv", row.names = FALSE)

out <- read_csv("./FCR/inputs/outflow.csv") %>%
  mutate(Date = date(time),
         FLOW = 0.0248) %>%
  filter(Date >= "2015-07-08" & Date <= "2015-08-08") %>%
  select(-Date)
write.csv(out, "./7_stratified_inflow/inputs/outflow.csv", row.names = FALSE)

# Scenario 8: Stratified, No Wind, One Constant Inflows/Outflow, Outflow 5x Inflow
inf <- read_csv("./FCR/inputs/inflow1.csv") %>%
  filter(month(time) %in% c(7,8))
hist(inf$TEMP)
mean(inf$TEMP, na.rm = TRUE)
# going to use value of 10.6136 degrees C; this will sink to bottom

inf <- read_csv("./FCR/inputs/inflow1.csv") %>%
  mutate(FLOW = 0.0248,
         TEMP = 10.6136,
         Date = date(time)) %>%
  filter(Date >= "2015-07-08" & Date <= "2015-08-08") %>%
  select(-Date)
plot(inf$time, inf$FLOW)
write.csv(inf, "./8_stratified_outflow/inputs/inflow1.csv", row.names = FALSE)

out <- read_csv("./FCR/inputs/outflow.csv") %>%
  mutate(Date = date(time),
         FLOW = 0.0248*5) %>%
  filter(Date >= "2015-07-08" & Date <= "2015-08-08") %>%
  select(-Date)
write.csv(out, "./8_stratified_outflow/inputs/outflow.csv", row.names = FALSE)

# Scenario 7: Unstratified, Observed Wind, Observed Weir Inflow/Corresponding Outflow
met <- read_csv("./FCR/inputs/met.csv") %>%
  mutate(Rain = 0,
         Snow = 0,
         Date = date(time)) %>%
  filter(Date >= "2016-01-01" & Date <= "2016-01-31") %>%
  select(-Date)
plot(met$time, met$WindSpeed)
write.csv(met, "./7_unstratified_observed_wind_inflow/inputs/met.csv", row.names = FALSE)

inf <- read_csv("./FCR/inputs/inflow1.csv") %>%
  mutate(Date = date(time)) %>%
  filter(Date >= "2016-01-01" & Date <= "2016-01-31") %>%
  select(-Date)
plot(inf$time, inf$FLOW)
write.csv(inf, "./7_unstratified_observed_wind_inflow/inputs/inflow1.csv", row.names = FALSE)

#correct outflow to be -SSS
inf2 <- read_csv("./FCR/inputs/inflow2.csv") %>%
  mutate(Date = date(time)) %>%
  filter(Date >= "2016-01-01" & Date <= "2016-01-31") %>%
  select(-Date)

out <- read_csv("./FCR/inputs/outflow.csv") %>%
  mutate(Date = date(time)) %>%
  filter(Date >= "2016-01-01" & Date <= "2016-01-31") %>%
  mutate(FLOW = FLOW - inf2$FLOW) %>%
  select(-Date)
plot(out$time, out$FLOW)
write.csv(out, "./7_unstratified_observed_wind_inflow/inputs/outflow.csv", row.names = FALSE)

# Scenario 8: Stratified, Observed Wind, Observed Weir Inflow/Corresponding Outflow
met <- read_csv("./FCR/inputs/met.csv") %>%
    mutate(Rain = 0,
           Snow = 0,
           Date = date(time)) %>%
    filter(Date >= "2015-07-08" & Date <= "2015-08-08") %>%
    select(-Date)
plot(met$time, met$WindSpeed)
write.csv(met, "./8_stratified_observed_wind_inflow/inputs/met.csv", row.names = FALSE)

inf <- read_csv("./FCR/inputs/inflow1.csv") %>%
  mutate(Date = date(time)) %>%
  filter(Date >= "2015-07-08" & Date <= "2015-08-08") %>%
  select(-Date)
plot(inf$time, inf$FLOW)
write.csv(inf, "./8_stratified_observed_wind_inflow/inputs/inflow1.csv", row.names = FALSE)

#correct outflow to be -SSS
inf2 <- read_csv("./FCR/inputs/inflow2.csv") %>%
  mutate(Date = date(time)) %>%
  filter(Date >= "2015-07-08" & Date <= "2015-08-08") %>%
  select(-Date)

out <- read_csv("./FCR/inputs/outflow.csv") %>%
  mutate(Date = date(time)) %>%
  filter(Date >= "2015-07-08" & Date <= "2015-08-08") %>%
  mutate(FLOW = FLOW - inf2$FLOW) %>%
  select(-Date)
plot(out$time, out$FLOW)
write.csv(out, "./8_stratified_observed_wind_inflow/inputs/outflow.csv", row.names = FALSE)


