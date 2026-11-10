test_that("receiver_push_summary warns of deprecation", {
  make_receiver_push_summary(
    qualified = pbsm$qualified,
    unqualified = pbsm$unqualified,
    deployment = pbsm$deployment,
    since = "2018-05-06",
    overwrite = TRUE
  ) |>
    expect_message("is deprecated") |>
    expect_message("Please switch")
})
