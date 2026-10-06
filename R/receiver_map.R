#' Receiver map
#'
#' Create a simple interactive map of receivers using Leaflet.
#'
#' @export
receiver_map <- function(
  data,
  styles = list(
    "Positron" = "https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png",
    "Dark Matter" = "https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png",
    "Voyager" = "https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}{r}.png",
    "OpenStreetMap" = "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png"
  ),
  width = "100%",
  height = "100vh",
  elementId = NULL
) {
  sf::st_write(
    data,
    file.path(tempdir(), "temporary_data.geojson"),
    quiet = TRUE,
    delete_dsn = TRUE
  )

  x <- list(
    geojson = readLines(file.path(tempdir(), "temporary_data.geojson")) |>
      paste(collapse = ""),
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
