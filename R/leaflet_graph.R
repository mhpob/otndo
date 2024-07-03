#' Plot the leaflet graphs for detection and individual
#'
#' @param station_spatial sf spatial data/frame created by prep_station_spatial
#'
#' @export

leaflet_graph <- function(station_spatial) {
  geometry <- NULL
  df <- station_spatial |> tidyr::extract(geometry, c("lon", "lat"), "\\((.*), (.*)\\)", convert = TRUE)
  numPal <- leaflet::colorNumeric("viridis", df$Detections)
  
  
  if(max(df$Individuals)<31){
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
      baseSize =  max(quakes$mag),
      color = 'black',
      title = 'Individual',
      shape = 'circle',
      orientation = 'horizontal',
      opacity = .5,
      fillOpacity = 0,
      breaks = min((max(quakes$mag)-min((quakes$mag))),5),
      position = 'bottomright',
      stacked = F) |>
    leaflegend::addLegendNumeric(
      pal = numPal,
      title = 'Matched Detections',
      values = df$Detections,
      fillOpacity = .5,
      decreasing = FALSE,
      orientation = 'horizontal',
      shape = 'rect',
      position = 'bottomright',
      height = 20,
      width = 100
    )}else{
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
        baseSize =  max(quakes$mag),
        color = 'black',
        title = 'Individual',
        shape = 'circle',
        orientation = 'horizontal',
        opacity = .5,
        fillOpacity = 0,
        breaks = min((max(quakes$mag)-min((quakes$mag))),7),
        position = 'bottomright',
        stacked = T) |>
      leaflegend::addLegendNumeric(
        pal = numPal,
        title = 'Matched Detections',
        values = df$Detections,
        fillOpacity = .5,
        decreasing = FALSE,
        orientation = 'horizontal',
        shape = 'rect',
        position = 'bottomright',
        height = 20,
        width = 100
      )
  }
  
}
