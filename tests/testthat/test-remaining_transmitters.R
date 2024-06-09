test_that("returns ggplot object", {
  matched_dets <- read.csv(pbsm$matched)
  remain <- remaining_transmitters(
    matched_dets,
    data.frame(date = as.Date("2020-01-01"))
  )

  expect_s3_class(
    remain,
    c("gg", "ggplot"),
    exact = TRUE
  )

  expect_equal(
    min(remain$data$date),
    as.Date(min(matched_dets$datecollected))
  )
  expect_equal(
    max(remain$data$date),
    as.Date("2020-01-01")
  )
})

test_that("Errors if no release data", {
  matched_dets <- read.csv(pbsm$matched)

  remaining_transmitters(
    matched_dets[matched_dets$receiver != "release",],
    data.frame(date = as.Date("2020-01-01"))
  ) |>
    expect_error("Release date must be supplied")
})
