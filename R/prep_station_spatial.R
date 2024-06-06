#' Summarize OTN extract data by station and convert to a spatial object
#'
#' @param extract OTN extract data
#' @param type type of extract data: "tag" or "receiver"
#'
#' @examples
#' \dontrun{
#' # Get an extract file
#' download.file(
#'   paste0(
#'     "https://members.oceantrack.org/data/repository/",
#'     "pbsm/detection-extracts/pbsm_matched_detections_2018.zip/",
#'     "@@download/file"
#'   ),
#'   destfile = file.path(td, "pbsm_matched_detections_2018.zip"),
#'   mode = "wb"
#' )
#' unzip(file.path(td, "pbsm_matched_detections_2018.zip"),
#'   exdir = td
#' )
#'
#' matched_dets <- data.table::fread(
#'   file.path(td, "pbsm_matched_detections_2018.csv")
#' )
#'
#' # Convert to spatial
#' prep_station_spatial(matched_dets, "tag")
#' }
#'
#' @export
prep_station_spatial <- function(extract, type = c("tag", "receiver")) {
  extract <- data.table::data.table(extract)
  pis <- project_contacts(extract, type)
  station_summary <- station_table(extract, type, pis)

  if (type == "tag") {
    station_spatial <- unique(extract, by = c("station", "detectedby"))

    station_spatial <- station_spatial[, station := toupper(station)]
  } else {
    station_spatial <- unique(extract, by = "station")
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
