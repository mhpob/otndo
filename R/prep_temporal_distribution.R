#'
prep_temporal_distribution <- function(matched, type = c('tag', 'receiver')){
  matched <- data.table::data.table(matched)

  if (type == "receiver") {
    matched[, day := as.Date(datecollected)]
    matched <- unique(matched, by = c("trackercode", "day"))

    return(matched)
  }
  if (type == "tag") {
    proj_order_ns <- matched[, .(lat = median(latitude)), by = "detectedby"]
    setorder(proj_order_ns, lat)

    matched[, detectedby_plot := factor(
      gsub(".*\\.", "", detectedby),
      ordered = T,
      levels = gsub(".*\\.", "",
                    proj_order_ns$detectedby)
    )]

    matched <- unique(matched, by = c("detectedby", "day"))

    return(matched)
  }
}
