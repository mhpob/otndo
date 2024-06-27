#' @param extract OTN station_spatial
#' @export
#'



leaflet_graph <- function(station_spatial) {
  df <- station_spatial %>% tidyr::extract(geometry, c('lon', 'lat'), '\\((.*), (.*)\\)', convert = TRUE)
  df %>%  as.data.frame()
  numPal <- colorNumeric('viridis', df $Detections)
  leaflet::leaflet(data = df) %>%
    addTiles() %>%
    addCircleMarkers( lat = ~lat, lng = ~lon,
                      color= ~numPal(Detections), fillColor = ~numPal(Detections),fillOpacity = 0.7, popup =  paste("Station ", df$station , "<br>",
                                                                                                                    "PI:", df$PI, "<br>",
                                                                                                                    "Detections:", df$Detections, "<br>",
                                                                                                                    "detectedby:", df$detectedby, "<br>",
                                                                                                                    "Individuals:", df$Individuals),
                      radius = ~Individuals) %>%

    leaflegend::addLegendSize(
      values = df $Individuals,
      baseSize = 1,
      color = 'black',
      title = 'Individual',
      shape = 'circle',
      orientation = 'horizontal',
      opacity = .5,
      fillOpacity = 0,
      breaks = 5,
      position = 'bottomright') %>%
    leaflegend::addLegendNumeric(
      pal = numPal,
      title = 'Matched Detection',
      shape = 'stadium',
      values = df $Detections,
      fillOpacity = .5,
      decreasing = TRUE,
      position = 'bottomright')



}

