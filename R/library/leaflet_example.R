showSampleMapUsingLeaflet <- function(d) {
  # Demonstrates the use of the leaflet package to plot violations data onto a map.
  # The provided violations data frame will be filtered to open violations only and then
  # grouped by address. Latitude and longitude will also be extracted from the location.
  #
  #  Args:
  #    d: A violations data frame
  #
  #  Returns:
  #    A leaflet map
  
  library(leaflet)
  library(maps)
  library(rgdal)
  library(sp)
  library(rgeos)
  library(maptools)
  library(RColorBrewer)
  library(stringr)
  
  openAddressses <- d %>%
    extractViolationCoordinates() %>% 
    addressesWithOpenViolations()
  
  # by address
  qpal <- colorQuantile("Reds", openAddressses$Days.Open, n = 5)
  
  openAddressses$Gmap.Fragment <-  paste(gsub(" ", "+", openAddressses$Address), 
                                         ",Kansas+City,+MO+", 
                                         openAddressses$Zip.Code, 
                                         "/@", 
                                         openAddressses$Latitude, 
                                         ",", 
                                         openAddressses$Longitude, 
                                         sep = "")
  
  leaflet(openAddressses) %>% 
    setView(lng = -94.5783, lat = 39.0997, zoom = 11) %>% 
    addTiles() %>% 
    addCircleMarkers(radius = ~Violation.Count*.5, 
                     color = ~qpal(Days.Open), 
                     popup = sprintf("<a href='%s'><h3>%s</h3></a>
                                     <ul>
                                     <li>Opened: %s</li>
                                     <li>Mean Days Open: %d</li>
                                     <li># of Violations: %d</li>
                                     </ul>
                                     <h4>Ordinances</h4><p>%s</p>", 
                                     sprintf("http://www.google.com/maps/place/%s", openAddressses$Gmap.Fragment),
                                     openAddressses$Address, 
                                     openAddressses$Case.Opened.Date, 
                                     openAddressses$Days.Open, 
                                     openAddressses$Violation.Count,
                                     openAddressses$Ordinances)) %>% 
    addLegend(pal = qpal, values = ~Days.Open, opacity = 1)
}


