library(tidyverse)
library(sf)
library(tmap)
library(DT)

# Help
# https://gis.stackexchange.com/questions/140504/extracting-intersection-areas-in-r

# Load and prepare ----
#pubLands <- st_read("input/WA_PublicLandsInventory_2014_PublicInfo/WA_PublicLandsInventory_2014_PublicInfo.shp")
pubLands <- st_read("input/WA_Major_Public_Lands_nonDNR/WA_Major_Public_Lands_nonDNR.shp")
epa <- st_read("input/us_eco_l4_state_boundaries/us_eco_l4.shp")

epa.clean <- epa %>% 
  filter(STATE_NAME == "Washington") %>% 
  select(US_L4CODE, US_L4NAME, US_L3NAME) %>% 
  st_transform(4326) 

pubLands.clean <- pubLands %>% 
  select(-OBJECTID) %>% 
  st_transform(4326)

landInEco <- st_join(x = pubLands.clean, y = epa.clean)

# Map it
#tmap_mode("view")
#landInEco %>% 
#  filter(US_L4CODE == "10f") %>%
#  tm_shape() +
#  tm_polygons(alpha = 0.5)

# Save data table
# https://rstudio.github.io/DT/
widget <- landInEco %>% 
  st_set_geometry(NULL) %>% 
  filter(NAME != "") %>% 
  datatable() %>% 
  saveWidget(file = "landsInEco.html")
