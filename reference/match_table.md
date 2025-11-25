# Create a reactable table of matched detections

Create a reactable table of matched detections

## Usage

``` r
match_table(extract, type = c("tag", "receiver"))
```

## Arguments

- extract:

  matched (transmitter) or qualified (receiver) OTN detections

- type:

  Tag or receiver data? Takes values of "tag" and "receiver"; defaults
  to "tag".

## Examples

``` r
if (FALSE) { # \dontrun{
# Receiver
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

qualified_dets <- data.table::fread(
  file.path(td, "pbsm_qualified_detections_2018.csv")
)

match_table(
  extract = qualified_dets,
  type = "receiver"
)

# Transmitters
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

match_table(
  extract = matched_dets,
  type = "tag"
)
} # }
```
