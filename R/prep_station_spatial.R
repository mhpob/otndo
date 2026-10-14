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
  station <- Station <- . <- Detections <- Individuals <- longitude <-
    latitude <- PI <- detectedby <- NULL

  extract <- data.table::data.table(extract)
  pis <- project_contacts(extract, type)
  station_summary <- station_table(extract, type)

  if (type == "tag") {
    station_spatial <- unique(extract, by = c("station", "detectedby"))

    station_spatial <- station_spatial[, station := toupper(station)]
  } else {
    station_spatial <- unique(extract, by = "station")
  }

  station_spatial <- station_spatial[
    station_summary[, Station := toupper(Station)],
    ,
    on = c("station" = "Station")
  ]

  col_names <- c(
    "station",
    "Detections",
    "Individuals",
    "longitude",
    "latitude"
  )
  if (type == "tag") {
    col_names <- c(col_names, "PI", "detectedby")

    if ("Species" %in% names(station_summary)) {
      col_names <- c(col_names, "Species")
    }

    station_spatial <- station_spatial[, ..col_names]
  } else {
    if ("Species" %in% names(station_summary)) {
      col_names <- c(col_names, "Species")
    }

    station_spatial <- station_spatial[, ..col_names]
  }

  station_spatial
}
