test_that("expected classes", {
  expect_s3_class(
    deployment_xl <- clean_otn_deployment(pbsm$deployment),
    c("tbl_df", "tbl", "data.frame"),
    exact = TRUE
  )
  expect_named(
    deployment_xl,
    c(
      "stationname", "receiver", "internal_transmitter", "deploy_date_time",
      "deploy_lat", "deploy_long", "recover_date_time"
    )
  )
  expect_type(deployment_xl$stationname, "character")
  expect_type(deployment_xl$receiver, "character")
  expect_s3_class(deployment_xl$deploy_date_time, c("POSIXct", "POSIXt"),
                  exact = TRUE
  )
  expect_type(deployment_xl$deploy_lat, "double")
  expect_type(deployment_xl$deploy_long, "double")
  expect_s3_class(deployment_xl$recover_date_time, c("POSIXct", "POSIXt"),
                  exact = TRUE
  )
})




test_that("date times are parsed", {
  deployment_xl <- clean_otn_deployment(pbsm$deployment)

  expect_equal(
    attributes(deployment_xl$deploy_date_time)$tzone,
    "UTC"
  )
  expect_equal(
    attributes(deployment_xl$recover_date_time)$tzone,
    "UTC"
  )
})




test_that("Works when no header present", {
  deployment_sheet1 <- file.path(
    td,
    "no_header.xlsx"
  )

  dep <- readxl::read_excel(pbsm$deployment, sheet = 2, skip = 3)

  writexl::write_xlsx(
    list(
      readme = data.frame(),
      deployment = dep
    ),
    deployment_sheet1
  )

  expect_equal(
    clean_otn_deployment(deployment_sheet1),
    clean_otn_deployment(pbsm$deployment)
  )
})


test_that("guesses sheet", {
  deployment_sheet1 <- file.path(
    td,
    "one_sheet.xlsx"
  )

  readxl::read_excel(pbsm$deployment, sheet = 2, skip = 3) |>
    writexl::write_xlsx(deployment_sheet1)

  expect_equal(
    clean_otn_deployment(deployment_sheet1),
    clean_otn_deployment(pbsm$deployment)
  )
})



test_that("accepts csv with header", {
  deployment_csv <- file.path(
    td,
    "pbsm-instrument-deployment-short-form-2018.csv"
  )
  readxl::read_excel(pbsm$deployment,
    sheet = 2, col_names = FALSE,
    .name_repair = "minimal"
  ) |>
    write.table(deployment_csv,
      row.names = FALSE, col.names = FALSE,
      sep = ",", na = ""
    )

  expect_s3_class(
    deployment_csv <- clean_otn_deployment(deployment_csv),
    "data.frame"
  )
  expect_named(
    deployment_csv,
    c(
      "stationname", "receiver", "internal_transmitter", "deploy_date_time",
      "deploy_lat", "deploy_long", "recover_date_time"
    )
  )
  expect_type(deployment_csv$stationname, "character")
  expect_type(deployment_csv$receiver, "character")
  expect_s3_class(deployment_csv$deploy_date_time, c("POSIXct", "POSIXt"),
                  exact = TRUE
  )
  expect_type(deployment_csv$deploy_lat, "double")
  expect_type(deployment_csv$deploy_long, "double")
  expect_s3_class(deployment_csv$recover_date_time, c("POSIXct", "POSIXt"),
                  exact = TRUE
  )

  expect_equal(
    attributes(deployment_csv$deploy_date_time)$tzone,
    "UTC"
  )
  expect_equal(
    attributes(deployment_csv$recover_date_time)$tzone,
    "UTC"
  )
})




test_that("accepts csv without header", {
  deployment_csv <- file.path(
    td,
    "pbsm-instrument-deployment-short-form-2018.csv"
  )
  readxl::read_excel(pbsm$deployment, sheet = 2, skip = 3) |>
    write.csv(deployment_csv, row.names = FALSE)

  expect_s3_class(
    deployment_csv <- clean_otn_deployment(deployment_csv),
    "data.frame"
  )
  expect_named(
    deployment_csv,
    c(
      "stationname", "receiver", "internal_transmitter", "deploy_date_time",
      "deploy_lat", "deploy_long", "recover_date_time"
    )
  )
  expect_type(deployment_csv$stationname, "character")
  expect_type(deployment_csv$receiver, "character")
  expect_s3_class(deployment_csv$deploy_date_time, c("POSIXct", "POSIXt"),
    exact = TRUE
  )
  expect_type(deployment_csv$deploy_lat, "double")
  expect_type(deployment_csv$deploy_long, "double")
  expect_s3_class(deployment_csv$recover_date_time, c("POSIXct", "POSIXt"),
    exact = TRUE
  )

  expect_equal(
    attributes(deployment_csv$deploy_date_time)$tzone,
    "UTC"
  )
  expect_equal(
    attributes(deployment_csv$recover_date_time)$tzone,
    "UTC"
  )
})




test_that("Correct names when no internal transmitter columns", {
  deployment_sheet1 <- file.path(
    td,
    "no_transmitter.xlsx"
  )

  dep <- readxl::read_excel(pbsm$deployment, sheet = 2, skip = 3)

  writexl::write_xlsx(
    dep[, !names(dep) %in% c('TRANSMITTER', 'TRANSMIT_MODEL')],
    deployment_sheet1
  )

  expect_named(
    clean_otn_deployment(deployment_sheet1),
    c("stationname", "receiver", "deploy_date_time", "deploy_lat", "deploy_long",
      "recover_date_time")
  )
})




test_that("errors if not a CSV or XLS(X)", {
  expect_error(
    clean_otn_deployment("abcs.doc"),
    "File type is not xls, xlsx, or csv\\."
  )
})
