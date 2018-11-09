library(htmlwidgets)
library(htmltools)
library(tidyverse)
library(sf)
library(DT)
library(tmap)

pubLands <- st_read("input/WA_Major_Public_Lands_nonDNR/WA_Major_Public_Lands_nonDNR.shp")
epa <- st_read("input/us_eco_l4_state_boundaries/us_eco_l4.shp")

epaWa <- epa %>% 
  filter(STATE_NAME == "Washington") %>% 
  select(US_L4CODE, US_L4NAME, US_L3NAME)

#--- Public Lands Table ---
epa.clean <- epaWa %>% 
  st_transform(4326) %>% st_sf()

pubLands.clean <- pubLands %>% 
  select(-OBJECTID) %>% 
  filter(!is.na(NAME)) %>% 
  st_transform(4326) %>% st_sf()

landInEco <- st_join(x = pubLands.clean, y = epa.clean) %>% 
  mutate(ID = as.numeric(row_number()))

dt <- landInEco %>% st_set_geometry(NULL) %>% datatable(options = list(pageLength = 5))

htmlwidgets::saveWidget(dt, file = "pubLandsTable.html", selfcontained = TRUE)

#--- Explore map
map <- tm_shape(epaWa) +
  tm_polygons(alpha = 0.1) +
  tm_basemap(c("http://{s}.tiles.wmflabs.org/hikebike/{z}/{x}/{y}.png", "Esri.WorldTopoMap", "Esri.WorldGrayCanvas", "OpenStreetMap"))
lmap <- tmap_leaflet(map)
htmlwidgets::saveWidget(lmap, file = "exploreMap.html", selfcontained = TRUE)
