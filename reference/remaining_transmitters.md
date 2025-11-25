# Estimate transmitters remaining in the system

This function estimates the transmitters remaining in the system by
finding the last date of detection for each transmitter and summing all
available transmitters in a given day. This is a very coarse measure and
likely to be very inaccurate with sparse data or short time scales.

## Usage

``` r
remaining_transmitters(matched, push_log, release = NULL)
```

## Arguments

- matched:

  matched OTN transmitter detections

- push_log:

  data.frame containing the date of the most-recent data push. This
  requirement is very likely to change in the future.

- release:

  Optional. Data frame of release times/locations; a subset of the
  matched detections data

## Examples

``` r
if (FALSE) { # \dontrun{
#' # Set up example data
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

# Run remaining_transmitters()
remaining_transmitters(matched_dets, data.frame(date = as.Date("2020-01-01")))
} # }
```
