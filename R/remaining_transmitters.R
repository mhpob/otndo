#' Estimate transmitters remaining in the system
#'
#' This function estimates the transmitters remaining in the system by finding
#' the last date of detection for each transmitter and summing all available
#' transmitters in a given day. This is a very coarse measure and likely to be
#' very inaccurate with sparse data or short time scales.
#'
#' @param matched matched OTN transmitter detections
#' @param push_log data.frame containing the date of the most-recent data push.
#'    This requirement is very likely to change in the future.
#'
#' @examples
#' \dontrun{
#' #' # Set up example data
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
#' # Run remaining_transmitters()
#' remaining_transmitters(matched_dets, data.frame(date = as.Date('2020-01-01')))
#' }
#'
#'
#' @export
remaining_transmitters <- function(matched, push_log) {
  last_record <- matched[, list(last_record = max(datecollected)), by = "tagname"]
  transmitter_life <- last_record[
    matched[receiver == 'release', list(tagname, datecollected)],
    ,
    on = "tagname"
  ]
  data.table::setnames(transmitter_life, "datecollected", "first_record")
  transmitter_life[, last_record := data.table::fifelse(
    is.na(last_record),
    first_record,
    last_record
  )]

  transmitter_life[, ":="(first_record = as.Date(first_record),
    last_record = as.Date(last_record))]

  date_seq <- data.table::data.table(
    date = seq(
      min(transmitter_life$first_record, na.rm = T),
      push_log$date[nrow(push_log)],
      by = "day"
    )
  )

  date_seq[, remaining := sapply(
    date,
    function(.) {
      sum(
        data.table::between(
          .,
          transmitter_life$first_record,
          transmitter_life$last_record
        ) == T
      )
    }
  )]

  ggplot2::ggplot(data = date_seq) +
    ggplot2::geom_step(ggplot2::aes(x = date, y = remaining)) +
    ggplot2::labs(x = NULL, y = "Project transmitters remaining") +
    ggplot2::theme_minimal()
}
