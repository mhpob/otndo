#' Plot the leaflet graphs for detection and individual
#'
#' @param station_spatial sf spatial data/frame created by prep_station_spatial
#'
#' @export

leaflet_graph <- function(station_spatial) {
  geometry <- NULL
  df <- station_spatial |> tidyr::extract(geometry, c("lon", "lat"), "\\((.*), (.*)\\)", convert = TRUE)
  numPal <- leaflet::colorNumeric("viridis", df$Detections)


# test 3


  leaflet::leaflet(data = df) |>
    leaflet::addTiles() |>
    leaflegend::addSymbolsSize(values = ~df$Individuals,
                   lat = ~lat,
                   lng = ~lon,
                   shape = 'circle',
                   color =  ~numPal(Detections),
                   fillColor = ~numPal(Detections),
                   opacity = .5,
                   baseSize = 5,
                   popup =  paste("<strong> Station:", df$station , "<br>",
                                  "<strong> Location:", "(", df$lon, df$lat,  ")" , "<br>",
                                  "<strong> PI:", df$PI, "<br>",
                                  "<strong> Detectedby:", df$detectedby, "<br>",
                                  "<strong> Detections:", df$Detections, "<br>",
                                  "<strong> Individuals:", df$Individuals)) |>
    leaflegend::  addLegendSize(
      values =  df$Individuals,
      baseSize = 5,
      color = 'black',
      title = 'Individual',
      shape = 'circle',
      orientation = 'horizontal',
      opacity = .5,
      fillOpacity = 0,
      breaks = min((max(df$Individuals)-min((df$Individuals))),7),
      position = 'bottomright',
      stacked = T)|>
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
