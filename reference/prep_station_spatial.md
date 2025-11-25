# Summarize OTN extract data by station and convert to a spatial object

Summarize OTN extract data by station and convert to a spatial object

## Usage

``` r
prep_station_spatial(extract, type = c("tag", "receiver"))
```

## Arguments

- extract:

  OTN extract data

- type:

  type of extract data: "tag" or "receiver"

## Examples

``` r
if (FALSE) { # \dontrun{
# Get an extract file
download.file(
  paste0(
    "https://members.oceantrack.org/data/repository/",
    "pbsm/detection-extracts/pbsm_matched_detections_2018.zip/",
    "@download/file"
  ),
  destfile = file.path(td, "pbsm_matched_detections_2018.zip"),
  mode = "wb"
)
unzip(file.path(td, "pbsm_matched_detections_2018.zip"),
  exdir = td
)

matched_dets <- data.table::fread(
  file.path(td, "pbsm_matched_detections_2018.csv")
)

# Convert to spatial
prep_station_spatial(matched_dets, "tag")
} # }
```
