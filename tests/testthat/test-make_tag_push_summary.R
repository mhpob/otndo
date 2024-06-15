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




test_that("No new detections since \"since\" date works", {
  make_tag_push_summary(
    matched = pbsm$matched,
    since = Sys.Date() + 1
  ) |>
    expect_message("Asking OTN GeoServer") |>
    expect_message("Writing report") |>
    expect_message("Done")

  expect_true(any(grepl("tag_push_summary", list.files(getwd()))))
})


test_that("Default \"since\" date works", {
  make_tag_push_summary(
    matched = pbsm$matched
  ) |>
    expect_message("Asking OTN GeoServer") |>
    expect_message("Writing report") |>
    expect_message("Done")

  expect_true(any(grepl("tag_push_summary", list.files(getwd()))))


  # Make sure at least one detection is "new"
  new_matched <- read.csv(pbsm$matched)
  new_matched <- rbind(
    new_matched,
    new_matched[1, ]
  )

  new_matched[nrow(new_matched), ]$datelastmodified <- as.character(Sys.Date())
  write.csv(new_matched, file.path(td, "new_matched.csv"), row.names = FALSE)


  make_tag_push_summary(
    matched = file.path(td, "new_matched.csv")
  ) |>
    expect_message("Asking OTN GeoServer") |>
    expect_message("Writing report") |>
    expect_message("Done")

  expect_true(any(grepl("tag_push_summary", list.files(getwd()))))
})




test_that("errors with no input data", {
  expect_error(
    make_tag_push_summary(),
    "Must provide at least one set of OTN-matched detections"
  )
})




test_that("update_push_log arg works", {
  make_tag_push_summary(
    matched = pbsm$matched,
    update_push_log = TRUE
  ) |>
    expect_message("Asking OTN GeoServer") |>
    expect_message("Writing report") |>
    expect_message("Done")
})
