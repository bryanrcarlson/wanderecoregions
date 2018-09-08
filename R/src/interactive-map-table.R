library(tidyverse)
library(sf)
library(leaflet)
library(DT)
library(crosstalk)
library(tmap)

#devtools::install_github("rstudio/leaflet")
#devtools::install_github("rstudio/DT")

# Help
# https://rstudio.github.io/crosstalk/

# Load and prepare ----
#pubLands <- st_read("input/WA_PublicLandsInventory_2014_PublicInfo/WA_PublicLandsInventory_2014_PublicInfo.shp")
pubLands <- st_read("input/WA_Major_Public_Lands_nonDNR/WA_Major_Public_Lands_nonDNR.shp")
epa <- st_read("input/us_eco_l4_state_boundaries/us_eco_l4.shp")

epa.clean <- epa %>% 
  filter(STATE_NAME == "Washington") %>% 
  select(US_L4CODE, US_L4NAME, US_L3NAME) %>% 
  st_transform(4326) %>% st_sf()

pubLands.clean <- pubLands %>% 
  select(-OBJECTID) %>% 
  st_transform(4326) %>% st_sf()

landInEco <- st_join(x = pubLands.clean, y = epa.clean) %>% 
  mutate(ID = as.numeric(row_number())) %>% 
  filter(US_L4CODE == "10h")

dt <- landInEco %>% st_set_geometry(NULL)

sdmap <- SharedData$new(data = landInEco, key = ~ID, group = "sd")
sdtable <- SharedData$new(data = dt, key = ~ID, group = "sd")

options(persistent = TRUE)

map <- leaflet(sdmap) %>% addTiles() %>% addPolygons()
table <- DT::renderDataTable({
  datatable(sdtable, style="bootstrap", class="compact", width="100%",
                   options=list(deferRender=T, scrollY=300, scroller=T))},
  server = FALSE)

bscols(map, table)

browsable(ta)
interactiveLands <- bscols(
  leaflet(sdmap) %>% addTiles() %>% addPolygons(),
  datatable(sdtable, style="bootstrap", class="compact", width="100%",
            options=list(deferRender=T, scrollY=300, scroller=T))
)


# The map and table do not interact, why?
# maybe help? https://rstudio-pubs-static.s3.amazonaws.com/204407_2550c7ab4f674516a03a8a2ebce17111.html#

# Attempt #2 ----
# https://stackoverflow.com/questions/42974140/crosstalk-filter-polylines-in-leaflet
shapes_to_filter <- as(landInEco, "Spatial")
sd_map <- SharedData$new(shapes_to_filter, key = ~ID, group = "foo")
sd_df <- SharedData$new(as.data.frame(shapes_to_filter@data), key = ~ID, group = "foo")


bscols(
  filter_select("filterid", "Select Filter Label", sd_df, ~OWNER),
  leaflet() %>% addProviderTiles("OpenStreetMap") %>% 
  addPolygons(data = sd_map),
  datatable(sd_df)
)
# Filter interacts with datatable, but polygons don't respond
#----

# Attempt #3 ----
# From: https://github.com/rstudio/crosstalk/issues/28
shared_poly_df <- landInEco %>% as.data.frame() %>% SharedData$new(key = ~ID, group = "mew")
shared_poly <- landInEco %>%SharedData$new(key = ~ID, group = "mew")
bscols(
  leaflet() %>% addProviderTiles("OpenStreetMap") %>% 
    addPolygons(data = shared_poly),
  datatable(shared_poly_df)
)
# Map it
#tmap_mode("view")
#landInEco %>% 
#  filter(US_L4CODE == "10f") %>%
#  tm_shape() +
#  tm_polygons(alpha = 0.5)

# Save data table
# https://rstudio.github.io/DT/
widget <- interactiveLands %>% 
  saveWidget(file = "landsInEcoIntractive.html")
