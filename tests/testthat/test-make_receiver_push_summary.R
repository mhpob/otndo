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
    expect_output("Output created") |>
    expect_message("Done")

  expect_true(any(grepl("receiver_push_summary", list.files(getwd()))))
})
