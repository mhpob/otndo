# Create an abacus plot of detections by project

Create an abacus plot of detections by project

## Usage

``` r
temporal_distribution(extract, type = c("tag", "receiver"))
```

## Arguments

- extract:

  OTN data extract file

- type:

  Transmitter (tag) or receiver detections?

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

temporal_distribution(matched, "tag")
} # }
```
