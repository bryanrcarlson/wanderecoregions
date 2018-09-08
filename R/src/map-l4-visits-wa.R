library(tidyverse)
library(sf)
library(tmap)

# Load and extract ----

visits <- read_csv("database/ecoregion-visits.csv")
epaWa <- st_read("input/us_eco_l4_state_boundaries/us_eco_l4.shp") %>% 
  filter(STATE_NAME == "Washington") %>% 
  select(US_L4CODE, US_L4NAME, US_L3NAME) #%>%

epaWaVisited <- epaWa %>% 
  filter(US_L4CODE %in% visits$US_L4CODE) %>% 
  full_join(visits)

# Map it ----
tm_shape(epaWa) +
  tm_polygons(alpha = 0) +
tm_shape(epaWaVisited) +
  tm_polygons()
