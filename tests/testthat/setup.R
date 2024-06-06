td <- file.path(tempdir(), "otndo_test_files")
dir.create(td)

## Qualified detections
download.file("https://members.oceantrack.org/data/repository/pbsm/detection-extracts/pbsm_qualified_detections_2018.zip/@@download/file",
              destfile = file.path(td, "pbsm_qualified_detections_2018.zip"),
              mode = "wb",
              quiet = TRUE
)
unzip(file.path(td, "pbsm_qualified_detections_2018.zip"),
      exdir = td
)

qualified_path <- file.path(td, "pbsm_qualified_detections_2018.csv")


## Unqualified detections
download.file("https://members.oceantrack.org/data/repository/pbsm/detection-extracts/pbsm_unqualified_detections_2018.zip/@@download/file",
              destfile = file.path(td, "pbsm_unqualified_detections_2018.zip"),
              mode = "wb",
              quiet = TRUE
)
unzip(file.path(td, "pbsm_unqualified_detections_2018.zip"),
      exdir = td
)

unqualified_path <- file.path(td, "pbsm_unqualified_detections_2018.csv")


## Deployment records
download.file("https://members.oceantrack.org/data/repository/pbsm/data-and-metadata/archived-records/2018/pbsm-instrument-deployment-short-form-2018.xls/@@download/file",
              destfile = file.path(td, "pbsm-instrument-deployment-short-form-2018.xls"),
              mode = "wb",
              quiet = TRUE
)
deployment_path <- file.path(td, "pbsm-instrument-deployment-short-form-2018.xls")


## Matched detections
download.file(
  "https://members.oceantrack.org/data/repository/pbsm/detection-extracts/pbsm_matched_detections_2018.zip/@@download/file",
  destfile = file.path(td, "pbsm_matched_detections_2018.zip"),
  mode = "wb",
  quiet = TRUE
)
unzip(file.path(td, "pbsm_matched_detections_2018.zip"),
      exdir = td
)

matched_path <- file.path(td, "pbsm_matched_detections_2018.csv")
