#' Create an abacus plot of matched detections
#'
#' @param temp_dist Output of `temporal_distribution`
#' @param release Data frame of release times/locations.
#'
#' @export

matched_abacus <- function(temp_dist, release){
  abacus_data <- unique(temp_dist, by = c("detectedby", "day", "tagname"))

  ggplot2::ggplot() +
    ggplot2::geom_hline(yintercept = sort(unique(release$tagname))[
      seq(2, data.table::uniqueN(release$tagname), by = 2)
    ], color = "gray90") +
    ggplot2::geom_tile(
      data = abacus_data,
      ggplot2::aes(x = day, y = tagname, fill = detectedby_plot)
    ) +
    ggplot2::geom_tile(data = release,
                       ggplot2::aes(x = day, y = tagname), width = 0.5) +
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
