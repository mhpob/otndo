skip_if_offline()

## Simulate project
td <- file.path(tempdir(), "otndo_test_files")
dir.create(td)

download.file(
  "https://members.oceantrack.org/data/repository/pbsm/detection-extracts/pbsm_matched_detections_2018.zip/@@download/file",
  destfile = file.path(td, "pbsm_matched_detections_2018.zip"),
  mode = 'wb'
)
unzip(file.path(td, "pbsm_matched_detections_2018.zip"),
  exdir = td
)

matched <- file.path(td, "pbsm_matched_detections_2018.csv")



test_that("Non-ACT projects are summarized", {
  expect_no_error(
    make_tag_push_summary(
      matched = matched,
      since = "2018-05-06"
    )
  )

  expect_true(any(grepl("tag_push_summary", list.files(getwd()))))
})


unlink(td, recursive = T)


