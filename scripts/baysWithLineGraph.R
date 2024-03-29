library(tidyverse)
library(lubridate)
library(readr)
library(leaflet)
library(rgdal)
library(leafpop)
library(sf)

#### note the graphs do not correspond to polys!! See https://stackoverflow.com/questions/64455149/leaflet-popup-graphs-dont-correspond-to-map
bays<-st_read("./data/BayPolys.shp")

baynames<-read.csv("./data/MaineBayUnits.csv")


bays2 <- merge(bays, baynames, by.x="BAYNUM", by.y="BAYNUM")
#rename BAYCODE to Bayunit
bays2 <- bays2 %>% dplyr::rename(Bayunit = BAYCODE)
bays2<- bays2[order(bays2$Bayunit),]

baycts<-read_csv("./data/Seal Abundance by Bay Unit 1993-2018 (1).csv")

my_list <- list()  
#i="CASB"
loop<-for (i in unique(baycts$Bayunit)) {
  BAYNUM<-baycts%>% filter(Bayunit==i)
  plot<-ggplot(na.omit(BAYNUM), aes(x = Year, y = Estimate.Pups)) + 
    geom_bar(stat = "identity")+labs(title = i)
  my_list[[i]] <- plot
}
###or this is the fix on stack overflow, but still doesn't get it right
# my_list <- lapply(baycts$Bayunit, function(i) {
#   baycts %>%
#     filter(Bayunit == i) %>%
#     ggplot(aes(x = Year, y = Estimate.Pups)) +
#     geom_line() +
# #    scale_x_date(date_breaks = "1 month",date_labels = "%b") +
#     labs(title = i)
# })



m1 <- leaflet() %>%
  addTiles() %>%
  addPolygons(data = bays2, 
              fillColor = "red",
              fillOpacity = 0.6,       
              color = "darkgrey",      
              weight = 1.5, 
            popup = popupGraph(my_list)
  )
m1


