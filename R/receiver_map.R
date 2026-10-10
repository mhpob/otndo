#' Receiver map
#'
#' Create a simple interactive map of receivers using Leaflet.
#'
#' @param sf_data spatial data in sf format.
#' @param backgrounds list of URLs to XYZ endpoints of raster tile backgrounds
#' @param width width of the widget. Defaults to 100%.
#' @param height height of the widget. Defaults to 100vh.
#' @param elementId ID of the widget. Defaults to randomly-generated ID.
#' @export
receiver_map <- function(
  sf_data,
  backgrounds = list(
    "Open Waters Bathymetry" = "https://tiles.openwaters.io/seascape/{z}/{x}/{y}.webp",
    "Esri Light Gray" = "https://server.arcgisonline.com/ArcGIS/rest/services/Canvas/World_Light_Gray_Base/MapServer/tile/{z}/{y}/{x}",
    "Esri Street Map" = "https://server.arcgisonline.com/ArcGIS/rest/services/World_Street_Map/MapServer/tile/{z}/{y}/{x}",
    "Esri World Imagery" = "https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}"
  ),
  width = "100%",
  height = "100vh",
  elementId = NULL
) {
  sf_df <- as.data.frame(sf::st_drop_geometry(sf_data))
  coords <- sf::st_coordinates(sf_data)
  sf_df$lat <- coords[, 2]
  sf_df$lon <- coords[, 1]

  normalize <- function(x) {
    (x - min(x)) /
      (max(x) - min(x))
  }

  det_palette <- colorRampPalette(hcl.colors(5))(256)
  det_colors <- function(dets) {
    if (length(dets) <= 1) {
      "#0800ff"
    } else {
      det_palette[(normalize(dets) * (256 - 1)) + 1]
    }
  }

  ind_radius <- function(indivs) {
    if (length(indivs) <= 1) {
      4
    } else {
      4 + normalize(indivs) * 10
    }
  }

  det_palette <- colorRampPalette(hcl.colors(7))(256)
  ind_radii <- ind_radius(sf_df$Individuals)

  x <- c(
    sf_df,
    list(
      center = as.numeric(
        sf::st_coordinates(
          sf::st_centroid(
            sf::st_combine(sf_data)
          )
        )
      ),
      bbox = as.numeric(sf::st_bbox(sf_data)),
      backgrounds = backgrounds,
      det_colors = det_colors(sf_df$Detections),
      ind_radius = ind_radii,

      legend = list(
        det_min = min(sf_df$Detections, na.rm = TRUE),
        det_max = max(sf_df$Detections, na.rm = TRUE),
        color_min = det_palette[1],
        color_max = det_palette[256],
        ind_min = min(sf_df$Individuals, na.rm = TRUE),
        ind_max = max(sf_df$Individuals, na.rm = TRUE),
        rad_min = min(ind_radii, na.rm = TRUE),
        rad_max = max(ind_radii, na.rm = TRUE)
      )
    )
  )

  # create widget
  htmlwidgets::createWidget(
    name = "receiver_map",
    x,
    width = width,
    height = height,
    package = "otndo",
    elementId = elementId,
    sizingPolicy = htmlwidgets::sizingPolicy(
      viewer.fill = TRUE,
      browser.fill = TRUE,
      padding = 0,
      viewer.padding = 0,
      browser.padding = 0
    )
  )
}
