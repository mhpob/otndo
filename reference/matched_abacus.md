# Create an abacus plot of matched detections

Create an abacus plot of matched detections

## Usage

``` r
matched_abacus(temp_dist, release)
```

## Arguments

- temp_dist:

  Data from the output of
  [`temporal_distribution()`](https://otndo.obrien.page/reference/temporal_distribution.md)

- release:

  Data frame of release times/locations; a subset of the matched
  detections data

## Examples

``` r
if (FALSE) { # \dontrun{
# Get a detection file
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


# Run temporal_distribution
temporal <- temporal_distribution(matched_dets, "tag")

# Run matched_abacus
matched_abacus(temporal$data, matched_dets[receiver == "release"])
} # }
```
