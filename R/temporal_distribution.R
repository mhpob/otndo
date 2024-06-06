#'
temporal_distribution <- function(matched, type = c("tag", "receiver")) {
  matched <- data.table::data.table(matched)

  if (type == "receiver") {
    matched <- unique(matched, by = c("trackercode", "day"))
    matched[, detectedby_plot := gsub(".*\\.", "", trackercode)]
  }
  if (type == "tag") {
    proj_order_ns <- matched[, list(lat = median(latitude)), by = "detectedby"]
    data.table::setorder(proj_order_ns, lat)

    matched[, detectedby_plot := factor(
      gsub(".*\\.", "", detectedby),
      ordered = T,
      levels = gsub(
        ".*\\.", "",
        proj_order_ns$detectedby
      )
    )]

    matched <- unique(matched, by = c("detectedby", "day"))
  }

  ggplot2::ggplot(matched) +
    ggplot2::geom_tile(ggplot2::aes(x = day, y = detectedby_plot)) +
    ggplot2::labs(
      x = "", y = "",
      subtitle = "Temporal distribution of detections by project"
    ) +
    ggplot2::theme_minimal()
}
