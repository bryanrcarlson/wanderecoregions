library(tidyverse)
library(sf)
library(tmap)

# Load and extract ----
tmap_mode("view")
visits <- read_csv("database/ecoregion-visits.csv")
epaWa <- st_read("input/us_eco_l4_state_boundaries/us_eco_l4.shp") %>% 
  filter(STATE_NAME == "Washington") %>% 
  select(US_L4CODE, US_L4NAME, US_L3NAME)

epaWaVisited <- epaWa %>% 
  filter(US_L4CODE %in% visits$US_L4CODE) %>% 
  full_join(visits) %>% 
  select(-latitude, -longitude, -date, -activity)

visitPoints <- visits %>% 
  select(-US_L4CODE) %>% 
  st_as_sf(coords = c("longitude", "latitude"), crs = 4326)


tm_shape(epaWa) +
  tm_polygons(alpha = 0) +
tm_shape(epaWaVisited) +
  tm_polygons(col = "forestgreen", alpha = 0.2) +
tm_shape(visitPoints) +
  tm_dots() +
tm_basemap(c("Esri.WorldTopoMap", "http://{s}.tiles.wmflabs.org/hikebike/{z}/{x}/{y}.png", "OpenStreetMap"))
