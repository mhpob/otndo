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




test_that("No new matches since \"since\" date works", {
  make_receiver_push_summary(
    qualified = pbsm$qualified,
    unqualified = pbsm$unqualified,
    deployment = pbsm$deployment,
    since = Sys.Date() + 1
  ) |>
    expect_message("Asking OTN GeoServer for project information") |>
    expect_message("Writing report") |>
    expect_message("Done")

  expect_true(any(grepl("receiver_push_summary", list.files(getwd()))))
})




test_that("Default \"since\" date works", {
  make_receiver_push_summary(
    qualified = pbsm$qualified,
    unqualified = pbsm$unqualified,
    deployment = pbsm$deployment
  ) |>
    expect_message("Asking OTN GeoServer for project information") |>
    expect_message("Writing report") |>
    expect_message("Done")

  expect_true(any(grepl("receiver_push_summary", list.files(getwd()))))


  # Make sure at least one detection is "new"
  new_qualified <- read.csv(pbsm$qualified)
  new_qualified <- rbind(
    new_qualified,
    new_qualified[1, ]
  )

  new_qualified[nrow(new_qualified), ]$datelastmodified <- as.character(Sys.Date())
  write.csv(new_qualified, file.path(td, "new_qualified.csv"), row.names = FALSE)


  make_receiver_push_summary(
    qualified = file.path(td, "new_qualified.csv"),
    unqualified = pbsm$unqualified,
    deployment = pbsm$deployment
  ) |>
    expect_message("Asking OTN GeoServer for project information") |>
    expect_message("Writing report") |>
    expect_message("Done")

  expect_true(any(grepl("receiver_push_summary", list.files(getwd()))))
})
