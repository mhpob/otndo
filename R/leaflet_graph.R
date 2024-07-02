#' Plot the leaflet graphs for detection and individual
#' @param   station_spatial is created by prep_station_spatial,which is a spatial object with the geometry
#' @export

leaflet_graph <- function(station_spatial) {
  geometry<- NULL
  df <- station_spatial |> tidyr::extract(geometry, c('lon', 'lat'), '\\((.*), (.*)\\)', convert = TRUE)
  numPal <- leaflet::colorNumeric('viridis', df $Detections)
  leaflet::leaflet(data = df) |>
    leaflet::addTiles() |>
    leaflet::addCircleMarkers( lat = ~lat, lng = ~lon,
                      color= ~numPal(df$Detections), fillColor = ~numPal(df$Detections),fillOpacity = 0.7,
                      popup =  paste("Station ", df$station , "<br>",
                                     "PI:", df$PI, "<br>",
                                    "Detections:", df$Detections, "<br>",
                                    "detectedby:", df$detectedby, "<br>",
                                    "Individuals:", df$Individuals),
                      radius = ~(df$Individuals)) |>

    leaflegend::addLegendSize(
      values = df $Individuals,
      baseSize = round(df $Individuals),
      color = 'black',
      title = 'Individual',
      shape = 'circle',
      orientation = 'horizontal',
      opacity = .5,
      fillOpacity = 0,
      breaks = round(df $Individuals),
      position = 'bottomright',
      stacked = TRUE) |>
    leaflegend::addLegendNumeric(
      pal = numPal,
      title = 'Matched Detection',
      values = df$Detections,
      fillOpacity = .5,
      decreasing = FALSE,
      orientation = 'horizontal',
      shape = 'rect',
      position = 'bottomright',
      height = 20,
      width = 100)



}

