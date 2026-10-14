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
    detections <- individuals <- scientificname <- NULL

  extract <- data.table::data.table(extract)
  has_species <- any(!is.na(extract$scientificname))

  if (type == "tag") {
    pis <- project_contacts(extract, type = type)

    station_summary <- merge(
      extract[, list(detections = .N), by = c("station", "detectedby")],
      unique(extract, by = c("tagname", "station"))[,
        list(
          individuals = .N,
          long = mean(longitude),
          lat = mean(latitude)
        ),
        by = "station"
      ]
    )

    if (has_species) {
      station_summary <- merge(
        station_summary,
        unique(extract, by = c("station", "scientificname"))[, c(
          "station",
          "scientificname"
        )] |>
          _[
            scientificname != "",
            .(scientificname = paste(scientificname, collapse = "; ")),
            by = "station"
          ],
        all = TRUE
      )
    }

    data.table::setnames(station_summary, "detectedby", "project_name")

    station_summary <- merge(
      station_summary,
      pis[, list(project_name, PI)],
      by = "project_name"
    )
  } else {
    station_summary <- merge(
      extract[, list(detections = .N), by = "station"],
      unique(extract, by = c("fieldnumber", "station"))[,
        list(
          individuals = .N,
          long = mean(longitude),
          lat = mean(latitude)
        ),
        by = "station"
      ]
    )

    if (has_species) {
      station_summary <- merge(
        station_summary,
        unique(extract, by = c("station", "scientificname"))[, c(
          "station",
          "scientificname"
        )] |>
          _[
            scientificname != "",
            .(scientificname = paste(scientificname, collapse = "; ")),
            by = "station"
          ],
        all = TRUE
      )
    }
  }

  data.table::setorder(station_summary, -lat, long)

  if (type == "tag") {
    col_names <- c("PI", "project_name", "station", "detections", "individuals")
    col_names_pretty <- c(
      "PI",
      "Project",
      "Station",
      "Detections",
      "Individuals"
    )
    if (has_species) {
      col_names <- c(col_names, "scientificname")
      col_names_pretty <- c(col_names_pretty, "Species")
    }

    station_summary <- station_summary[, ..col_names]
    data.table::setnames(station_summary, col_names_pretty)
  } else {
    col_names <- c("station", "detections", "individuals")
    col_names_pretty <- c("Station", "Detections", "Individuals")
    if (has_species) {
      col_names <- c(col_names, "scientificname")
      col_names_pretty <- c(col_names_pretty, "Species")
    }

    station_summary <- station_summary[, ..col_names]
    data.table::setnames(station_summary, col_names_pretty)
  }

  station_summary[]
}
