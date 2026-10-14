test_that("receiver data gives correct classes", {
  rec <- read.csv(pbsm$qualified)
  rec_spat <- prep_station_spatial(rec, "receiver")

  expect_s3_class(
    rec_spat,
    c("data.table", "data.frame"),
    exact = TRUE
  )

  expect_named(
    rec_spat,
    c(
      "station",
      "Detections",
      "Individuals",
      "longitude",
      "latitude",
      "Species"
    )
  )
})


test_that("tag data gives correct classes", {
  tag <- read.csv(pbsm$matched)
  tag_spat <- prep_station_spatial(tag, "tag")

  expect_s3_class(
    tag_spat,
    c("data.table", "data.frame"),
    exact = TRUE
  )

  expect_named(
    tag_spat,
    c(
      "station",
      "Detections",
      "Individuals",
      "longitude",
      "latitude",
      "PI",
      "detectedby",
      "Species"
    )
  )
})

test_that("Species column dropped if no species (receivers)", {
  rec <- read.csv(pbsm$qualified)
  rec$scientificname <- NA
  rec_spat <- prep_station_spatial(rec, "receiver")

  expect_named(
    rec_spat,
    c("station", "Detections", "Individuals", "longitude", "latitude")
  )
})

test_that("Species column dropped if no species (tag)", {
  tag <- read.csv(pbsm$matched)
  tag$scientificname <- NA
  tag_spat <- prep_station_spatial(tag, "tag")

  expect_named(
    tag_spat,
    c(
      "station",
      "Detections",
      "Individuals",
      "longitude",
      "latitude",
      "PI",
      "detectedby"
    )
  )
})
