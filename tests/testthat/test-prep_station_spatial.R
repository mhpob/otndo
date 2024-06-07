test_that("receiver data gives correct classes", {
  rec <- read.csv(qualified_path)
  rec_spat <- prep_station_spatial(rec, 'receiver')

  expect_s3_class(
    rec_spat,
    c('sf', 'data.table', 'data.frame'),
    exact = TRUE
  )

  expect_named(
    rec_spat,
    c('station', 'Detections', 'Individuals', 'geometry')
  )
})


test_that("tag data gives correct classes", {
  tag <- read.csv(matched_path)
  tag_spat <- prep_station_spatial(tag, 'tag')

  expect_s3_class(
    tag_spat,
    c('sf', 'data.table', 'data.frame'),
    exact = TRUE
  )

  expect_named(
    tag_spat,
    c('station', 'Detections', 'Individuals', "PI", "detectedby", 'geometry')
  )
})
