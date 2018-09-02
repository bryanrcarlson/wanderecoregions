library(tidyverse)
library(sf)
library(tmap)

# Load and extract ----
epa <- st_read("input/us_eco_l4_state_boundaries/us_eco_l4.shp")

epaWa <- epa %>% 
  filter(STATE_NAME == "Washington")

# Map it ----
tmap_mode("view")
tm_shape(epaWa) +
  tm_polygons(alpha = 0.6)
