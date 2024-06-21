test_datetime <- as.POSIXct("2020-04-09T11:04:59", tz = "UTC",
                            format = "%Y-%m-%dT%H:%M:%S")

test_that("converts ISO 8601", {
  expect_equal(
    convert_times("2020-04-09T11:04:59"),
    test_datetime
  )
})




test_that("converts space-separated date-times", {
  expect_equal(
    convert_times("2020-04-09 11:04:59"),
    test_datetime
  )
})




test_that("converts Excel numeric", {
  expect_equal(
    convert_times(43930.461793981),
    test_datetime
  )
})




test_that("converts Excel character", {
  expect_equal(
    convert_times("43930.461793981"),
    test_datetime
  )
})




test_that("works with vectors", {
  expect_equal(
    convert_times(c("2020-04-09T11:04:59", "2020-04-09 11:04:59",
                    "43930.461793981", 43930.461793981)),
    rep(test_datetime, 4)
  )
})
