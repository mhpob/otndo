#' Receiver map
#'
#' Create a simple interactive map of receivers using Leaflet.
#'
#' @export
receiver_map <- function(
  data,
  styles = list(
    "Open Waters Bathymetry" = "https://tiles.openwaters.io/seascape/{z}/{x}/{y}.webp",
    "Esri Light Gray" = "https://server.arcgisonline.com/ArcGIS/rest/services/Canvas/World_Light_Gray_Base/MapServer/tile/{z}/{y}/{x}",
    "Esri Street Map" = "https://server.arcgisonline.com/ArcGIS/rest/services/World_Street_Map/MapServer/tile/{z}/{y}/{x}",
    "Esri World Imagery" = "https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}"
  ),
  width = "100%",
  height = "100vh",
  elementId = NULL
) {
  tmp <- tempfile(fileext = ".geojson")
  sf::st_write(
    data,
    tmp,
    quiet = TRUE,
    delete_dsn = TRUE
  )

  x <- list(
    geojson = jsonlite::fromJSON(tmp, simplifyVector = FALSE),
    center = as.numeric(
      sf::st_coordinates(
        sf::st_centroid(
          sf::st_combine(data)
        )
      )
    ),
    bbox = as.numeric(sf::st_bbox(data)),
    styles = styles,
    min_det = min(data$Detections, na.rm = TRUE),
    max_det = max(data$Detections, na.rm = TRUE),
    min_indiv = min(data$Individuals, na.rm = TRUE),
    max_indiv = max(data$Individuals, na.rm = TRUE)
  )

  unlink(tmp)

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
