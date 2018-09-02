library(tidyverse)
library(sf)
library(tmap)

# Public lands ----
df <- st_read("input/WA_PublicLandsInventory_2014_PublicInfo/WA_PublicLandsInventory_2014_PublicInfo.shp")

str(df)
tmap_mode("view")

df %>% 
  select(PolygonID, OwnerType, OwnerName) %>% 
  tm_shape() +
    tm_borders()
