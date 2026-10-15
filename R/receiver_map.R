#' Receiver map
#'
#' Create a simple interactive map of receivers using Leaflet.
#'
#' @param spatial_data spatial data in sf format.
#' @param backgrounds list of URLs to XYZ endpoints of raster tile backgrounds
#' @export
receiver_map <- function(
  spatial_data,
  backgrounds = list(
    "Open Waters Bathymetry" = "https://tiles.openwaters.io/seascape/{z}/{x}/{y}.webp",
    "Esri Light Gray" = "https://server.arcgisonline.com/ArcGIS/rest/services/Canvas/World_Light_Gray_Base/MapServer/tile/{z}/{y}/{x}",
    "Esri Street Map" = "https://server.arcgisonline.com/ArcGIS/rest/services/World_Street_Map/MapServer/tile/{z}/{y}/{x}",
    "Esri World Imagery" = "https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}"
  )
) {
  if ("Species" %in% names(spatial_data)) {
    spatial_data$Species <- gsub("; ", "<br>", spatial_data$Species)
  }

  normalize <- function(x) {
    (x - min(x)) /
      (max(x) - min(x))
  }

  det_palette <- grDevices::colorRampPalette(grDevices::hcl.colors(5))(256)
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
  ind_radii <- ind_radius(spatial_data$Individuals)

  ## Build tooltip HTML
  species_html <- if ("Species" %in% names(spatial_data)) {
    spec_vals <- as.character(spatial_data$Species)
    has_spec <- !is.na(spec_vals) & spec_vals != "" & spec_vals != "NA"
    ifelse(
      has_spec,
      paste0("<div><strong>Species:</strong> ", spec_vals, "</div>"),
      ""
    )
  } else {
    character(nrow(spatial_data))
  }

  tooltip_html <- paste0(
    '<div style="font-family: system-ui, sans-serif; font-size: 12px; padding: 2px; max-width: 260px;">',
    '<div><strong>Station:</strong> ',
    ifelse(
      is.na(spatial_data$station) | spatial_data$station == "",
      "N/A",
      as.character(spatial_data$station)
    ),
    '</div>',
    '<div><strong>Detections:</strong> ',
    ifelse(
      is.na(spatial_data$Detections),
      "N/A",
      as.character(spatial_data$Detections)
    ),
    '</div>',
    '<div><strong>Individuals:</strong> ',
    ifelse(
      is.na(spatial_data$Individuals),
      "N/A",
      as.character(spatial_data$Individuals)
    ),
    '</div>',
    species_html,
    '</div>'
  )

  ## Build legend HTML
  det_range <- range(spatial_data$Detections, na.rm = TRUE)
  ind_range <- range(spatial_data$Individuals, na.rm = TRUE)
  rad_range <- range(ind_radii, na.rm = TRUE) * 2

  legend_html <- sprintf(
    '
  <div style="font-weight: bold; margin-bottom: 6px;">Legend</div>
  
  <div style="margin-bottom: 8px;">
    <div style="font-size: 11px; color: #555;">Detections</div>
    <div style="display: flex; align-items: center; gap: 6px; margin-top: 3px;">
      <span>%d</span>
      <div style="background: linear-gradient(to right, %s); height: 10px; width: 90px; border-radius: 2px; border: 1px solid #ccc;"></div>
      <span>%d</span>
    </div>
  </div>

  <div>
    <div style="font-size: 11px; color: #555; margin-bottom: 4px;">Individuals</div>
    <div style="display: flex; align-items: center; gap: 10px;">
      <div style="display: flex; align-items: center; gap: 4px;">
        <span style="display: inline-block; width: %.1fpx; height: %.1fpx; border-radius: 50%%; border: 1px solid #666; background: #ccc;"></span>
        <span>%d</span>
      </div>
      <div style="display: flex; align-items: center; gap: 4px;">
        <span style="display: inline-block; width: %.1fpx; height: %.1fpx; border-radius: 50%%; border: 1px solid #666; background: #ccc;"></span>
        <span>%d</span>
      </div>
    </div>
  </div>',
    det_range[1],
    paste(det_palette[round(seq(1, 256, length.out = 5))], collapse = ", "),
    det_range[2],
    rad_range[1],
    rad_range[1],
    ind_range[1],
    rad_range[2],
    rad_range[2],
    ind_range[2]
  )

  x <- c(
    spatial_data,
    list(
      center = c(
        mean(spatial_data$latitude),
        mean(spatial_data$longitude)
      ),
      bbox = c(
        min(spatial_data$latitude),
        min(spatial_data$longitude),
        max(spatial_data$latitude),
        max(spatial_data$longitude)
      ),
      backgrounds = backgrounds,
      det_colors = det_colors(spatial_data$Detections),
      ind_radius = ind_radii,

      tooltip = tooltip_html,
      legend = legend_html
    )
  )

  # create widget
  htmlwidgets::createWidget(
    name = "receiver_map",
    x,
    package = "otndo",
    sizingPolicy = htmlwidgets::sizingPolicy(
      viewer.fill = FALSE,
      browser.fill = FALSE,
      padding = 0,
      viewer.padding = 0,
      browser.padding = 0
    )
  )
}
