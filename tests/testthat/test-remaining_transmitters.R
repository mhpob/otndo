test_that("returns ggplot object", {
  matched_dets <- read.csv(matched_path)
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
