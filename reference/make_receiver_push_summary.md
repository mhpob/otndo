# Create summary reports of receiver project data from the OTN data push

Create summary reports of receiver project data from the OTN data push

## Usage

``` r
make_receiver_push_summary(
  qualified = NULL,
  unqualified = NULL,
  update_push_log = FALSE,
  deployment = NULL,
  out_dir = getwd(),
  since = NULL,
  rmd = FALSE,
  overwrite = FALSE
)
```

## Arguments

- qualified, unqualified:

  Default is NULL: a character vector of file paths of your
  qualified/unqualified detections. These can be CSVs or zipped folders.

- update_push_log:

  Do you wish to use an updated push log? Default is FALSE, but switch
  to TRUE if you haven't updated this package since the push occurred.

- deployment:

  File path of user-supplied master OTN receiver deployment metadata.

- out_dir:

  Defaults to working directory. In which directory would you like to
  save the report?

- since:

  Date in YYYY-MM-DD format. Summarizes what's new since the provided
  date.

- rmd:

  Logical. Compile via RMarkdown rather than Quarto?

- overwrite:

  Logical. Overwrite existing file?

## Push log

To keep track of when ACT data pushes occur, a log is kept [on the
package's GitHub
page](https://raw.githubusercontent.com/mhpob/otndo/master/inst/push_log.csv).
This is automatically downloaded every time you download or update the
package, but you can avoid re-downloading the package by changing
`update_push_log` to `TRUE`.

You can get similar behavior by providing a date to the `since`
argument.

## Output

This function creates an HTML report that can be viewed in your web
browser.

## Examples

``` r
if (FALSE) { # \dontrun{
td <- file.path(tempdir(), "matos_test_files")
dir.create(td)

download.file(
  paste0(
    "https://members.oceantrack.org/data/repository/pbsm/",
    "data-and-metadata/archived-records/2018/",
    "pbsm-instrument-deployment-short-form-2018.xls/",
    "@download/file"
  ),
  destfile = file.path(td, "pbsm-instrument-deployment-short-form-2018.xls"),
  mode = "wb"
)


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

download.file(
  paste0(
    "https://members.oceantrack.org/data/repository/pbsm/",
    "detection-extracts/pbsm_unqualified_detections_2018.zip/",
    "@download/file"
  ),
  destfile = file.path(td, "pbsm_unqualified_detections_2018.zip"),
  mode = "wb"
)
unzip(
  file.path(td, "pbsm_unqualified_detections_2018.zip"),
  exdir = td
)

qualified_files <- file.path(td, "pbsm_qualified_detections_2018.csv")
unqualified_files <- file.path(td, "pbsm_unqualified_detections_2018.csv")
deployment_files <- file.path(td, "pbsm-instrument-deployment-short-form-2018.xls")


make_receiver_push_summary(
  qualified = qualified_files,
  unqualified = unqualified_files,
  deployment = deployment_files,
  since = "2018-11-01"
)
} # }
```
