#' Plot the geographic extent of OTN projects
#'
#' @param otn_tables A list containing OTN's `otn_resources_metadata_points`
#'    GeoServer layer. Usually created using `otn_query`.
#'
#' @examples
#' match_map(
#'   otn_query("MDWEA")
#' )
#'
#' @export

match_map <- function(otn_tables) {
  latitude <- longitude <- id <- NULL

  # Convert WKT to data.table
  strip_coords <- function(geom) {
    coords <- gsub("^POLYGON \\(\\((.*)\\)\\)$", "\\1", geom) |>
      strsplit(split = ", ") |>
      lapply(function(.) {
        do.call(rbind, strsplit(., split = " ")) |>
          data.frame()
      }) |>
      data.table::rbindlist(idcol = "id")

    names(coords) <- c("id", "longitude", "latitude")

    coords[, longitude := as.numeric(longitude)]
    coords[, latitude := as.numeric(latitude)]

    coords
  }

  fmt_degree <- function(type = c("lon", "lat")) {
    type <- match.arg(type)

    function(x) {
      if (length(x) == 0) {
        return(character(0))
      }

      deg <- abs(x)

      if (type == "lon") {
        dir <- ifelse(x < 0, "\u00B0W", ifelse(x > 0, "\u00B0E", "°"))
        dir[x == 0 | abs(x) == 180] <- "°"
      } else {
        dir <- ifelse(x < 0, "\u00B0S", ifelse(x > 0, "\u00B0N", "°"))
        dir[x == 0] <- "°"
      }

      paste0(deg, dir)
    }
  }

  otn_bboxes <- otn_tables$otn_resources_metadata_points$the_geom |>
    strip_coords()

  ggplot2::ggplot() +
    ggplot2::geom_path(
      data = natural_earth_110m,
      ggplot2::aes(x = longitude, y = latitude, group = id)
    ) +
    ggplot2::geom_path(
      data = otn_bboxes,
      ggplot2::aes(x = longitude, y = latitude, group = id),
      color = "blue"
    ) +
    ggplot2::coord_quickmap(
      xlim = range(otn_bboxes$longitude) + c(-5, 5),
      ylim = range(otn_bboxes$latitude) + c(-5, 5)
    ) +
    ggplot2::scale_x_continuous(labels = fmt_degree("lon")) +
    ggplot2::scale_y_continuous(labels = fmt_degree("lat")) +
    ggplot2::labs(
      title = "Geographic extent of detected projects",
      x = NULL,
      y = NULL
    ) +
    ggplot2::theme_minimal()
}
