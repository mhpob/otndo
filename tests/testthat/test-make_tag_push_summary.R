td <- file.path(tempdir(), 'matos_test_files')
dir.create(td)

download.file('https://members.oceantrack.org/data/repository/pbsm/detection-extracts/pbsm_matched_detections_2018.zip',
               destfile = file.path(td, 'pbsm_matched_detections_2018.zip'))
unzip(file.path(td, 'pbsm_matched_detections_2018.zip'),
      exdir = td)



test_that("multiplication works", {
  expect_equal(2 * 2, 4)
})
