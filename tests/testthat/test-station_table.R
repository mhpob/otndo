test_that("makes correct classes and names for receivers", {
  qual <- read.csv(pbsm$qualified)

  tbl_qual <- station_table(qual, type = "receiver")

  expect_s3_class(tbl_qual, c("data.table", "data.frame"), exact = TRUE)
  expect_named(tbl_qual, c("Station", "Detections", "Individuals"))

  expect_type(tbl_qual$Station, "character")
  expect_type(tbl_qual$Detections, "integer")
  expect_type(tbl_qual$Individuals, "integer")
})


test_that("makes correct classes and names for tags", {
  matched <- read.csv(pbsm$matched)

  tbl_matched <- station_table(matched, type = "tag")

  expect_s3_class(tbl_matched, c("data.table", "data.frame"), exact = TRUE)
  expect_named(tbl_matched, c("PI", "Project", "Station", "Detections", "Individuals"))

  expect_type(tbl_matched$PI, "character")
  expect_type(tbl_matched$Project, "character")
  expect_type(tbl_matched$Station, "character")
  expect_type(tbl_matched$Detections, "integer")
  expect_type(tbl_matched$Individuals, "integer")
})

test_that("is the right length for receivers", {
  qual <- read.csv(pbsm$qualified)
  tbl_qual <- station_table(qual, type = "receiver")

  expect_equal(
    length(unique(qual$station)),
    nrow(tbl_qual)
  )
})


test_that("is the right length for tags", {
  matched <- read.csv(pbsm$matched)
  tbl_match <- station_table(matched, "tag")

  expect_equal(
    length(unique(matched$station)),
    nrow(tbl_match)
  )
})
