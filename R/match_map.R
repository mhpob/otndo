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
  natural_earth <- sf::st_read(
    system.file("ne_110m_coastline.gpkg",
      package = "otndo"
    ),
    quiet = T
  )

  otn_sf <- otn_tables$otn_resources_metadata_points |>
    sf::st_as_sf(wkt = "the_geom", crs = 4326)
  otn_limits <- sf::st_bbox(otn_sf)

  ggplot2::ggplot() +
    ggplot2::geom_sf(data = natural_earth) +
    ggplot2::geom_sf(data = otn_sf, fill = NA, color = "blue") +
    ggplot2::coord_sf(
      xlim = c(otn_limits["xmin"] - 5, otn_limits["xmax"] + 5),
      ylim = c(otn_limits["ymin"] - 5, otn_limits["ymax"] + 5)
    ) +
    ggplot2::labs(title = "Geographic extent of detected projects") +
    ggplot2::theme_minimal()
}
