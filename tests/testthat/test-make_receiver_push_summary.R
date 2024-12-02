# Pings OTN GeoServer; skip if offline
skip_if_offline()

test_that("Projects are summarized", {
  make_receiver_push_summary(
    qualified = pbsm$qualified,
    unqualified = pbsm$unqualified,
    deployment = pbsm$deployment,
    since = "2018-05-06",
    overwrite = TRUE
  ) |>
    expect_message("Asking OTN GeoServer for project information") |>
    expect_message("Writing report") |>
    expect_message("Done")

  expect_true(any(grepl("receiver_push_summary", list.files(getwd()))))
})




test_that("Zipped files are unzipped", {
  zip(gsub("csv$", "zip", pbsm$qualified), pbsm$qualified, flags = "-q")
  zip(gsub("csv$", "zip", pbsm$unqualified), pbsm$unqualified, flags = "-q")

  make_receiver_push_summary(
    qualified = gsub("csv$", "zip", pbsm$qualified),
    unqualified = gsub("csv$", "zip", pbsm$unqualified),
    deployment = pbsm$deployment,
    since = "2018-05-06",
    overwrite = TRUE
  ) |>
    expect_message("zipped files detected") |>
    expect_message("Unzipped") |>
    expect_message("zipped files detected") |>
    expect_message("Unzipped") |>
    expect_message("Asking OTN GeoServer for project information") |>
    expect_message("Writing report") |>
    expect_message("Done")
})



test_that("Renders with RMarkdown", {
  make_receiver_push_summary(
    qualified = pbsm$qualified,
    unqualified = pbsm$unqualified,
    deployment = pbsm$deployment,
    since = "2018-05-06",
    rmd = TRUE,
    overwrite = TRUE
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
    since = Sys.Date() + 1,
    overwrite = TRUE
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
    deployment = pbsm$deployment,
    overwrite = TRUE
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
    deployment = pbsm$deployment,
    overwrite = TRUE
  ) |>
    expect_message("Asking OTN GeoServer for project information") |>
    expect_message("Writing report") |>
    expect_message("Done")

  expect_true(any(grepl("receiver_push_summary", list.files(getwd()))))
})




test_that("errors with no input data", {
  expect_error(
    make_receiver_push_summary(),
    "Must provide at least one each of qualified.*unqualified detections.*deployment"
  )
})




test_that("update_push_log arg works", {
  make_receiver_push_summary(
    qualified = pbsm$qualified,
    unqualified = pbsm$unqualified,
    deployment = pbsm$deployment,
    update_push_log = TRUE,
    overwrite = TRUE
  ) |>
    expect_message("Asking OTN GeoServer for project information") |>
    expect_message("Writing report") |>
    expect_message("Done")
})




test_that("Pre-existing directory is overwritten", {
  dir.create(
    file.path(tempdir(), "otndo_files")
  )

  make_receiver_push_summary(
    qualified = pbsm$qualified,
    unqualified = pbsm$unqualified,
    deployment = pbsm$deployment,
    since = Sys.Date() + 1,
    overwrite = TRUE
  ) |>
    expect_message("Asking OTN GeoServer for project information") |>
    expect_message("Writing report") |>
    expect_message("Done")

  expect_false(dir.exists(file.path(tempdir(), "otndo_files")))
})


test_that("overwrite = FALSE works", {
  make_receiver_push_summary(
    qualified = pbsm$qualified,
    unqualified = pbsm$unqualified,
    deployment = pbsm$deployment,
    since = "2018-05-06",
    overwrite = FALSE
  ) |>
    expect_message("Asking OTN GeoServer for project information") |>
    expect_message("Writing report") |>
    expect_message("Done")

  expect_true(
    length(
      list.files(getwd(), pattern = "_\\d*_.*receiver_push_summary")
    ) >= 1
  )
})
