# Receiver map

Create a simple interactive map of receivers using Leaflet.

## Usage

``` r
receiver_map(
  spatial_data,
  backgrounds = list(`Open Waters Bathymetry` =
    "https://tiles.openwaters.io/seascape/{z}/{x}/{y}.webp", `Esri Light Gray` =
    "https://server.arcgisonline.com/ArcGIS/rest/services/Canvas/World_Light_Gray_Base/MapServer/tile/{z}/{y}/{x}",
    `Esri Street Map` =
    "https://server.arcgisonline.com/ArcGIS/rest/services/World_Street_Map/MapServer/tile/{z}/{y}/{x}",
    `Esri World Imagery` =
    "https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}")
)
```

## Arguments

- spatial_data:

  spatial data in sf format.

- backgrounds:

  list of URLs to XYZ endpoints of raster tile backgrounds
