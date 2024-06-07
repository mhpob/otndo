test_that("makes correct classes and names for receivers", {
  qual <- read.csv(qualified_path)

  tbl <- station_table(qual, type = "receiver")

  expect_s3_class(tbl, c("data.table", "data.frame"), exact = TRUE)
  expect_named(tbl, c("Station", "Detections", "Individuals"))

  expect_type(tbl$Station, "character")
  expect_type(tbl$Detections, "integer")
  expect_type(tbl$Individuals, "integer")
})


test_that("makes correct classes and names for tags", {
  matched <- read.csv(matched_path)

  tbl <- station_table(matched, type = "tag")

  expect_s3_class(tbl, c("data.table", "data.frame"), exact = TRUE)
  expect_named(tbl, c("PI", "Project", "Station", "Detections", "Individuals"))

  expect_type(tbl$PI, "character")
  expect_type(tbl$Project, "character")
  expect_type(tbl$Station, "character")
  expect_type(tbl$Detections, "integer")
  expect_type(tbl$Individuals, "integer")
})

test_that("is the right length for receivers", {
  qual <- read.csv(qualified_path)
  tbl_qual <- station_table(qual, type = "receiver")

  expect_equal(
    length(unique(qual$station)),
    nrow(tbl_qual)
  )
})


test_that("is the right length for tags", {
  matched <- read.csv(matched_path)
  tbl_match <- station_table(matched, "tag")

  expect_equal(
    length(unique(matched$station)),
    nrow(tbl_match)
  )
})
