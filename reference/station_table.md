# Create the station summary table

Create the station summary table

## Usage

``` r
station_table(extract, type = c("tag", "receiver"))
```

## Arguments

- extract:

  OTN detections. "Matched" detections for tag data and "qualified"
  detections for receiver data

- type:

  type of data to be summarized.

## Value

For tag data, a data.table with the PI, project, station, number of
detections, and number of individuals heard. For receiver data, a
data.table with the station, number of detections, and number of
individuals heard (assuming that the PI and POC is you).

## Examples

``` r
if (FALSE) { # \dontrun{
# Set up example data
td <- file.path(tempdir(), "otndo_example")
dir.create(td)

# For tag data
download.file(
  paste0(
    "https://members.oceantrack.org/data/repository/",
    "pbsm/detection-extracts/pbsm_matched_detections_2018.zip/@download/file"
  ),
  destfile = file.path(td, "pbsm_matched_detections_2018.zip")
)
unzip(file.path(td, "pbsm_matched_detections_2018.zip"),
  exdir = td
)

matched <- read.csv(file.path(
  td,
  "pbsm_matched_detections_2018.csv"
))

# Actually run the function
prep_station_table(matched, type = "tag")



# For receiver data
download.file(
  paste0(
    "https://members.oceantrack.org/data/repository/pbsm/",
    "detection-extracts/pbsm_qualified_detections_2018.zip/",
    "@download/file"
  ),
  destfile = file.path(td, "pbsm_qualified_detections_2018.zip"),
  mode = "wb"
)
unzip(
  file.path(td, "pbsm_qualified_detections_2018.zip"),
  exdir = td
)

qualified <- read.csv(file.path(td, "pbsm_qualified_detections_2018.csv"))

# Actually run the function
station_table(qualified, type = "receiver")

# Clean up
unlink(td, recursive = TRUE)
} # }
```
