# Pings OTN GeoServer; skip if offline
skip_if_offline()

test_that("Projects are summarized", {
  make_receiver_push_summary(
    qualified = pbsm$qualified,
    unqualified = pbsm$unqualified,
    deployment = pbsm$deployment,
    since = "2018-05-06"
  ) |>
    expect_message("Asking OTN GeoServer for project information") |>
    expect_message("Writing report") |>
    expect_message("Done")

  expect_true(any(grepl("receiver_push_summary", list.files(getwd()))))
})




test_that("Renders with RMarkdown", {
  make_receiver_push_summary(
    qualified = pbsm$qualified,
    unqualified = pbsm$unqualified,
    deployment = pbsm$deployment,
    since = "2018-05-06",
    rmd = TRUE
  ) |>
    expect_message("Asking OTN GeoServer for project information") |>
    expect_message("Writing report") |>
    expect_message("RMarkdown") |>
    expect_message("Done")

  expect_true(any(grepl("receiver_push_summary", list.files(getwd()))))
})




test_that("NULL \"since\" arg works", {
  make_receiver_push_summary(
    qualified = pbsm$qualified,
    unqualified = pbsm$unqualified,
    deployment = pbsm$deployment
  ) |>
    expect_message("Asking OTN GeoServer for project information") |>
    expect_message("Writing report") |>
    expect_message("Done")

  expect_true(any(grepl("receiver_push_summary", list.files(getwd()))))
})
