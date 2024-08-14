library(dplyr)
library(leaflet) 
library(DT)
library(crosstalk)
library(shinydashboard)
#library(tidyverse)
library (sf)


dashboardSidebar(disable = TRUE)

## read in data
baycts<-read.csv("./data/Adjusted_Seal Abundance by Bay Unit 1993-2018_with_Lat-Lon.csv")
baycenters<-read.csv("./data/baycenters.csv")

baycts<-merge(baycts, baycenters, by = "BAYNUM", all.x=TRUE)

baycts<- select(baycts, LONG, LAT, BAYCODE, Bayunit=BAYDESC, Year, Nonpups=Estimate.Nonpups, Pups=Estimate.Pups)
baycts$Bayunit<-as.factor(baycts$Bayunit)
#bays<-st_read("./data/BayPolys.shp")
bays<-sf::read_sf("./data/BayPolys/BayPolys.shp")


# Wrap data frame in SharedData
sd <- SharedData$new(baycts)


DT1<-datatable(
  sd,filter = list(
    position = 'top', clear = FALSE
  ),
  extensions =  c('Select', 'Buttons'),   options = list(select = list(style = 'os', items = 'row'),dom = 'Bfrtip',
                                                         #columnDefs = list(list(visible=FALSE, targets = 1:3)), 
                                                         columnDefs= list(list(visible=FALSE, targets = 1:3), list(className='dt-center', targets = 4:7)), 
                                                         autoWidth = TRUE, include.rownames= FALSE, buttons =  list(list(extend = 'collection',  buttons = c('csv', 'excel', 'pdf', 'print'), text = 'Download')
  )),
)  
  
ltlf5<- leaflet(sd) %>% 
  
  addProviderTiles(providers$Esri.WorldImagery) %>% 
  addPolygons(data = bays, 
              fillColor = ~colorQuantile("YlOrRd", BAYNUM)(BAYNUM),
              fillOpacity = 0.6,       
              color = "darkgrey",      
              weight = 1.5, 
              highlightOptions = highlightOptions(color = "white", weight = 2
                                                  )
  ) %>%
    addCircleMarkers(
    lng = ~LONG,
    lat = ~LAT,
    radius = 3,
    color = 'yellow',
    popup = ~Bayunit,
    
  )   



body <- dashboardBody(
#mainPanel(width=10,
  fluidRow(
    # App title ----
    titlePanel(tagList(img(src = 'noaanefsclogo.PNG'),br(),title='Harbor Seal Pupping Data - by Bay Unit'),
               tags$head(tags$link(rel = "icon", type = "image/png", href = "favicon.png")
               )
    ),
  ),
  fluidRow(

    column(6,ltlf5, p(HTML("<b>Interactive map: Use the bracket tool in the corner of this map and drag the corners to select bay units of interest. Make sure to include the polygon center (yellow dot) in your selection.
                       Or just use the filters in the datatable at left to select data.</b>")), h4(style="text-align: justify;","The Northeast Fisheries Science Center has been conducting aerial surveys of harbor seals since 1983 to monitor the abundance of the population in U.S. waters. Surveys are flown during the pupping season when animals are concentrated on the coast of Maine and timed to coincide with peak pupping estimated to be around the end of May. Surveys are flown from a NOAA Twin Otter at 230m within 2 hours of low tide using a hand-held Canon camera and fixed 300mm lens. Close to 1,000 ledges are surveyed and grouped into bay units (polygons on this map) for analysis. The data linked to this map is the estimated abundance of both pups and non-pups by bay unit each year from 1993-2018. For more information, see ", 
                       tags$a(href="https://onlinelibrary.wiley.com/doi/full/10.1111/mms.12873",  target="_blank", rel="noopener noreferrer","Sigourney et al. 2020"))),
    
    column(6,DT1),  p(style="text-align: justify;","*These estimates have been recomputed from Sigourney et al. 2020 to report the mean annual abundance of non-pups and pups in each bay unit, so total abundance (i.e. summing across bay units) may not match exactly with those reported in Sigourney et al. 2020.")
 

)
)
