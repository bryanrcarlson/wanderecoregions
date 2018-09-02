library(tidyverse)
library(sf)
library(tmap)

# Help
* https://gis.stackexchange.com/questions/140504/extracting-intersection-areas-in-r

# Load and prepare ----
pubLands <- st_read("input/WA_PublicLandsInventory_2014_PublicInfo/WA_PublicLandsInventory_2014_PublicInfo.shp")
epa <- st_read("input/us_eco_l4_state_boundaries/us_eco_l4.shp")

epaWa <- epa %>% 
  filter(STATE_NAME == "Washington")
pubLandsSlim <- pubLands %>% 
  select(OwnerType, OwnerName)
epaWA84 <- st_transform(epaWa, 4326)
pubLandsSlim84 <- st_transform(pubLandsSlim, 4326)


st_join(x = pubLandsSlim84, y = epaWA84) %>% 
  st_write("output/join.csv")
