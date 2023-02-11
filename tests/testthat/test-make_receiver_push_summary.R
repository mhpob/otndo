## THIS TEST SHOULDNT WORK
## I DONT ACTUALLY KNOW WHAT A TEST DOES
### JUST PUTTING THIS HERE SINCE ITS GOOD DUMMY CODE

test_that("multiplication works", {
  library(matos)

  # make temporary directory
  td <- tempdir()

  download.file('https://members.oceantrack.org/data/repository/pbsm/data-and-metadata/2018/pbsm-instrument-deployment-short-form-2018.xls',
                destfile = file.path(td, 'pbsm-instrument-deployment-short-form-2018.xls'),
                mode = 'wb')


  download.file('https://members.oceantrack.org/data/repository/pbsm/detection-extracts/pbsm_qualified_detections_2018.zip',
                destfile = file.path(td, 'pbsm_qualified_detections_2018.zip'))
  unzip(file.path(td, 'pbsm_qualified_detections_2018.zip'),
        exdir = td)


  download.file('https://members.oceantrack.org/data/repository/pbsm/detection-extracts/pbsm_unqualified_detections_2018.zip',
                destfile = file.path(td, 'pbsm_unqualified_detections_2018.zip'))
  unzip(file.path(td, 'pbsm_unqualified_detections_2018.zip'),
        exdir = td)


  make_receiver_push_summary(qualified = file.path(td, 'pbsm_qualified_detections_2018.csv'),
                             unqualified = file.path(td, 'pbsm_unqualified_detections_2018.csv'),
                             deployment = file.path(td, 'pbsm-instrument-deployment-short-form-2018.xls'))
  unlink(td, recursive = T)

  expect_equal(2 * 2, 4)
})
