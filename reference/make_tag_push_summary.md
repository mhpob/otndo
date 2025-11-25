# Create summary reports of receiver project data from the OTN data push

Create summary reports of receiver project data from the OTN data push

## Usage

``` r
make_tag_push_summary(
  matched = NULL,
  update_push_log = FALSE,
  since = NULL,
  sensor_decoding = NULL,
  out_dir = getwd(),
  rmd = FALSE,
  overwrite = FALSE
)
```

## Arguments

- matched:

  This argument also accepts a character vector of file paths of your
  matched detections. These can be CSVs or zipped folders.

- update_push_log:

  Do you wish to use an updated push log? Default is FALSE, but switch
  to TRUE if you haven't updated this package since the push occurred.

- since:

  date in YYYY-MM-DD format. Provides a summary of detections that were
  matched/edited since that date.

- sensor_decoding:

  Not yet implemented. Will be a place to provide information to decode
  and summarize sensor data,

- out_dir:

  Defaults to working directory. In which directory would you like to
  save the report?

- rmd:

  Logical. Compile via RMarkdown rather than Quarto?

- overwrite:

  Logical. Overwrite existing file?

## Examples

``` r
if (FALSE) { # \dontrun{
# The code below downloads some matched detections from OTN, then calls the function.
td <- file.path(tempdir(), "matos_test_files")
dir.create(td)

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

# Provide the detection file(s) to the \code{matched} argument, with an
# optional date to the \code{since} argument to summarize what was new since
# that date.
make_tag_push_summary(
  matched = file.path(
    td,
    "pbsm_matched_detections_2018.csv"
  ),
  since = "2018-11-01"
)
} # }
```
