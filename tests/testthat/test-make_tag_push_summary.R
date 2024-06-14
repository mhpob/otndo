# Pings OTN GeoServer; skip if offline
skip_if_offline()


test_that("Non-ACT projects are summarized", {
  make_tag_push_summary(
    matched = pbsm$matched,
    since = "2018-05-06"
  ) |>
    expect_message("Asking OTN GeoServer") |>
    expect_message("Writing report") |>
    expect_message("Done")

  expect_true(any(grepl("tag_push_summary", list.files(getwd()))))
})




test_that("Renders with RMarkdown", {
  make_tag_push_summary(
    matched = pbsm$matched,
    since = "2018-05-06",
    rmd = TRUE
  ) |>
    expect_message("Asking OTN GeoServer") |>
    expect_message("Writing report") |>
    expect_message("RMarkdown") |>
    expect_message("Done")

  expect_true(any(grepl("tag_push_summary", list.files(getwd()))))
})




test_that("summarizes with no new detections", {
  skip("Bug still exists")
})
