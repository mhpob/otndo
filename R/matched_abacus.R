#' Create an abacus plot of matched detections
#'
#' @param temp_dist Data from the output of [temporal_distribution()]
#' @param release Data frame of release times/locations; a subset of the matched
#'    detections data
#'
#' @examples
#' \dontrun{
#' # Get a detection file
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
#'
#' # Run temporal_distribution
#' temporal <- temporal_distribution(matched_dets, "tag")
#'
#' # Run matched_abacus
#' matched_abacus(temporal$data, matched_dets[receiver == "release"])
#' }
#'
#' @export

matched_abacus <- function(temp_dist, release) {
  day <- datecollected <- tagname <- detectedby_plot <- NULL


  abacus_data <- unique(temp_dist, by = c("detectedby", "day", "tagname"))
  release <- data.table::data.table(release)
  release[, day := as.Date(datecollected)]

  ggplot2::ggplot() +
    ggplot2::geom_hline(yintercept = sort(unique(release$tagname))[
      seq(2, data.table::uniqueN(release$tagname), by = 2)
    ], color = "gray90") +
    ggplot2::geom_tile(
      data = abacus_data,
      ggplot2::aes(x = day, y = tagname, fill = detectedby_plot)
    ) +
    ggplot2::geom_tile(
      data = release,
      ggplot2::aes(x = day, y = tagname), width = 0.5
    ) +
    ggplot2::scale_y_discrete(
      limits = sort(unique(release$tagname)),
      breaks = sort(unique(release$tagname))[
        seq(1, data.table::uniqueN(release$tagname), by = 2)
      ]
    ) +
    ggplot2::scale_fill_viridis_d(option = "H") +
    ggplot2::labs(
      x = NULL, y = NULL, fill = NULL,
      title = "Transmitter presence in Arrays",
      subtitle = "Note that the Y axis is alternating"
    ) +
    ggplot2::theme_minimal()
}
