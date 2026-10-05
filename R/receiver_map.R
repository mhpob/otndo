#' Receiver map
#'
#' Create a simple interactive map of receivers using a bundled version of MapLibre.
#'
#' @export
receiver_map <- function(
  data,
  styles = list(
    "Positron" = "https://basemaps.cartocdn.com/gl/positron-gl-style/style.json",
    "Dark Matter" = "https://basemaps.cartocdn.com/gl/dark-matter-gl-style/style.json",
    "Voyager" = "https://basemaps.cartocdn.com/gl/voyager-gl-style/style.json",
    "Demo Tiles" = "https://demotiles.maplibre.org/style.json"
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
      paste(collapse = ''),
    center = as.numeric(
      sf::st_coordinates(
        sf::st_centroid(
          sf::st_combine(
            data
          )
        )
      )
    ),
    bbox = as.numeric(sf::st_bbox(data)),
    styles = styles,
    init_style = styles[[1]],
    min_det = min(data$Detections),
    max_det = max(data$Detections),
    min_indiv = min(data$Individuals),
    max_indiv = max(data$Individuals)
  )

  # create widget
  htmlwidgets::createWidget(
    name = 'receiver_map',
    x,
    width = width,
    height = height,
    package = 'otndo',
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
