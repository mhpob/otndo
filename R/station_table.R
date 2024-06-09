#' Create the station summary table
#'
#' @param extract OTN detections. "Matched" detections for tag data and "qualified"
#'  detections for receiver data
#' @param type type of data to be summarized.
#'
#' @examples
#' \dontrun{
#' # Set up example data
#' td <- file.path(tempdir(), "otndo_example")
#' dir.create(td)
#'
#' # For tag data
#' download.file(
#'   paste0(
#'     "https://members.oceantrack.org/data/repository/",
#'     "pbsm/detection-extracts/pbsm_matched_detections_2018.zip/@@download/file"
#'   ),
#'   destfile = file.path(td, "pbsm_matched_detections_2018.zip")
#' )
#' unzip(file.path(td, "pbsm_matched_detections_2018.zip"),
#'   exdir = td
#' )
#'
#' matched <- read.csv(file.path(
#'   td,
#'   "pbsm_matched_detections_2018.csv"
#' ))
#'
#' # Actually run the function
#' prep_station_table(matched, type = "tag")
#'
#'
#'
#' # For receiver data
#' download.file(
#'   paste0(
#'     "https://members.oceantrack.org/data/repository/pbsm/",
#'     "detection-extracts/pbsm_qualified_detections_2018.zip/",
#'     "@@download/file"
#'   ),
#'   destfile = file.path(td, "pbsm_qualified_detections_2018.zip"),
#'   mode = "wb"
#' )
#' unzip(
#'   file.path(td, "pbsm_qualified_detections_2018.zip"),
#'   exdir = td
#' )
#'
#' qualified <- read.csv(file.path(td, "pbsm_qualified_detections_2018.csv"))
#'
#' # Actually run the function
#' station_table(qualified, type = "receiver")
#'
#' # Clean up
#' unlink(td, recursive = TRUE)
#' }
#'
#' @returns For tag data, a data.table with the PI, project, station, number of
#'  detections, and number of individuals heard. For receiver data, a data.table
#'  with the station, number of detections, and number of individuals heard
#'  (assuming that the PI and POC is you).
#'
#' @export
station_table <- function(extract, type = c("tag", "receiver")) {
  longitude <- latitude <- project_name <- PI <- lat <- long <- station <-
    detections <- individuals <- NULL

  extract <- data.table::data.table(extract)

  if (type == "tag") {
    pis <- project_contacts(extract, type = type)

    station_summary <- merge(
      extract[, list(detections = .N), by = c("station", "detectedby")],
      unique(extract, by = c("tagname", "station"))[, list(
        individuals = .N,
        long = mean(longitude),
        lat = mean(latitude)
      ),
      by = "station"
      ]
    )

    data.table::setnames(station_summary, "detectedby", "project_name")

    station_summary <- merge(
      station_summary,
      pis[, list(project_name, PI)],
      by = "project_name"
    )
  } else {
    station_summary <- merge(
      extract[, list(detections = .N), by = "station"],
      unique(extract, by = c("fieldnumber", "station"))[, list(
        individuals = .N,
        long = mean(longitude),
        lat = mean(latitude)
      ),
      by = "station"
      ]
    )
  }

  data.table::setorder(station_summary, -lat, long)

  if (type == "tag") {
    station_summary <- station_summary[, list(
      PI, project_name, station,
      detections, individuals
    )]
    data.table::setnames(station_summary, c(
      "PI", "Project", "Station",
      "Detections", "Individuals"
    ))
  } else {
    station_summary <- station_summary[, list(station, detections, individuals)]
    data.table::setnames(station_summary, c("Station", "Detections", "Individuals"))
  }

  station_summary[]
}
