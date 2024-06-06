#' Create an abacus plot of detections by project
#'
#' @param extract OTN data extract file
#' @param type Transmitter (tag) or receiver detections?
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
#'     "pbsm/detection-extracts/pbsm_matched_detections_2018.zip"
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
#' temporal_distribution(matched, "tag")
#' }
#'
#' @export
temporal_distribution <- function(extract, type = c("tag", "receiver")) {
  extract <- data.table::data.table(extract)

  if(length(grep("^tag", names(extract))) == 0) {
    # run this if unqualified detections were supplied
    subtitle <- "Temporal distribution of unmatched detections by project"

    extract[, day := as.Date(datecollected)]
    extract <- unique(extract, by = c("station", "day"))
    extract[, detectedby_plot := station]

  } else {

    if (type == "receiver") {
      extract[, day := as.Date(datecollected)]
      extract <- unique(extract, by = c("trackercode", "day"))
      extract[, detectedby_plot := gsub(".*\\.", "", trackercode)]
    }
    if (type == "tag") {
      proj_order_ns <- extract[, list(lat = median(latitude)), by = "detectedby"]
      data.table::setorder(proj_order_ns, lat)

      extract[, detectedby_plot := factor(
        gsub(".*\\.", "", detectedby),
        ordered = T,
        levels = gsub(
          ".*\\.", "",
          proj_order_ns$detectedby
        )
      )]
      extract[, day := as.Date(datecollected)]

      extract <- unique(extract, by = c("detectedby", "day"))
    }

    subtitle <- "Temporal distribution of detections by project"

  }
  ggplot2::ggplot(extract) +
    ggplot2::geom_tile(ggplot2::aes(x = day, y = detectedby_plot)) +
    ggplot2::labs(
      x = "", y = "",
      subtitle = subtitle
    ) +
    ggplot2::theme_minimal()
}
