test_that("tag_push_summary warns of deprecation", {
  make_tag_push_summary(
    matched = pbsm$matched,
    since = "2018-05-06",
    overwrite = TRUE
  ) |>
    expect_message("is deprecated") |>
    expect_message("Please switch")
})
