#'
#'
prep_station_spatial <- function(matched, type = c("tag", "receiver")) {
  matched <- data.table::data.table(matched)

  if (type == "tag") {
    station_spatial <- unique(matched, by = c("station", "detectedby"))

    station_spatial <- station_spatial[, station := toupper(station)]
  } else {
    station_spatial <- unique(matched, by = "station")
  }


  station_spatial <- station_spatial[
    station_summary[, Station := toupper(Station)], ,
    on = c("station" = "Station")
  ]


  if (type == "tag") {
    station_spatial <- station_spatial[, .(
      station, Detections, Individuals,
      longitude, latitude, PI, detectedby
    )]
  } else {
    station_spatial <- station_spatial[, .(
      station, Detections, Individuals, longitude, latitude
    )]
  }

  sf::st_as_sf(
    station_spatial,
    coords = c("longitude", "latitude"),
    crs = 4326
  )

  # For use if switching to leaflet
  # station_center <- st_centroid(st_union(station_spatial))
  # station_center <- st_coordinates(station_center)
}
