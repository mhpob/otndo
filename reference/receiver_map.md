# Receiver map

Create a simple interactive map of receivers using Leaflet.

## Usage

``` r
receiver_map(
  sf_data,
  backgrounds = list(`Open Waters Bathymetry` =
    "https://tiles.openwaters.io/seascape/{z}/{x}/{y}.webp", `Esri Light Gray` =
    "https://server.arcgisonline.com/ArcGIS/rest/services/Canvas/World_Light_Gray_Base/MapServer/tile/{z}/{y}/{x}",
    `Esri Street Map` =
    "https://server.arcgisonline.com/ArcGIS/rest/services/World_Street_Map/MapServer/tile/{z}/{y}/{x}",
    `Esri World Imagery` =
    "https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}"),
  width = "100%",
  height = "100vh",
  elementId = NULL
)
```

## Arguments

- sf_data:

  spatial data in sf format.

- backgrounds:

  list of URLs to XYZ endpoints of raster tile backgrounds

- width:

  width of the widget. Defaults to 100%.

- height:

  height of the widget. Defaults to 100vh.

- elementId:

  ID of the widget. Defaults to randomly-generated ID.
