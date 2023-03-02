# td <- file.path(tempdir(), 'otndo_test_files')
# dir.create(td)
#
# download.file('https://members.oceantrack.org/data/repository/pbsm/detection-extracts/pbsm_matched_detections_2018.zip',
#                destfile = file.path(td, 'pbsm_matched_detections_2018.zip'))
# unzip(file.path(td, 'pbsm_matched_detections_2018.zip'),
#       exdir = td)
#
#
# make_tag_push_summary(matched = file.path(td, 'pbsm_matched_detections_2018.csv'))


## NO TESTS YET. THIS IS A PLACEHOLDER



test_that("multiplication works", {
  expect_equal(2 * 2, 4)
})
