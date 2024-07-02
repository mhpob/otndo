#' Plot the leaflet graphs for detection and individual
#'
#' @param station_spatial sf spatial data/frame created by prep_station_spatial
#'
#' @export

leaflet_graph <- function(station_spatial) {
  numPal <- leaflet::colorNumeric(
    "viridis",
    station_spatial$Detections,
    reverse = FALSE
  )

  numPal_rev <- leaflet::colorNumeric(
    "viridis",
    station_spatial$Detections,
    reverse = TRUE
  )


  leaflet::leaflet(data = station_spatial) |>
    leaflet::addTiles() |>
    leaflet::addCircleMarkers(
      color = ~ numPal(Detections),
      fillColor = ~ numPal(Detections),
      fillOpacity = 0.7,
      radius = ~ Individuals,
      popup = paste(
        "Station:", station_spatial$station, "<br>",
        "PI:", station_spatial$PI, "<br>",
        "Detections:", station_spatial$Detections, "<br>",
        "Project:", station_spatial$detectedby, "<br>",
        "Individuals:", station_spatial$Individuals
      )
    ) |>
    leaflet::addLegend(
      position = "bottomright",
      pal = numPal_rev,
      values = ~ Detections,
      title = "Matched Detections",
      labFormat = leaflet::labelFormat(
        transform = function(x) sort(x, decreasing = TRUE)
      )
    )
}
