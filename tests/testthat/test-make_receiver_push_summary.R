skip_if_offline()

## Simulate OTN project
td <- file.path(tempdir(), "otndo_test_files")
dir.create(td)

download.file("https://members.oceantrack.org/data/repository/pbsm/data-and-metadata/2018/pbsm-instrument-deployment-short-form-2018.xls",
  destfile = file.path(td, "pbsm-instrument-deployment-short-form-2018.xls"),
  mode = "wb"
)


download.file("https://members.oceantrack.org/data/repository/pbsm/detection-extracts/pbsm_qualified_detections_2018.zip/@@download/file",
  destfile = file.path(td, "pbsm_qualified_detections_2018.zip"),
  mode = "wb"
)
unzip(file.path(td, "pbsm_qualified_detections_2018.zip"),
  exdir = td
)


download.file("https://members.oceantrack.org/data/repository/pbsm/detection-extracts/pbsm_unqualified_detections_2018.zip",
  destfile = file.path(td, "pbsm_unqualified_detections_2018.zip"),
  mode = "wb"
)
unzip(file.path(td, "pbsm_unqualified_detections_2018.zip"),
  exdir = td
)

qualified <- file.path(td, "pbsm_qualified_detections_2018.csv")
unqualified <- file.path(td, "pbsm_unqualified_detections_2018.csv")
deployment <- file.path(td, "pbsm-instrument-deployment-short-form-2018.xls")

test_that("Deployment metadata can be cleaned", {
  expect_no_error(clean_otn_deployment(deployment))
})


test_that("Projects are summarized", {
  expect_no_error(
    make_receiver_push_summary(
      qualified = qualified,
      unqualified = unqualified,
      deployment = deployment,
      since = "2018-05-06"
    )
  )

  expect_true(any(grepl("receiver_push_summary", list.files(getwd()))))
})


unlink(td, recursive = T)
