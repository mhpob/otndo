skip_if_offline()

td <- file.path(tempdir(), "test-clean_otn_deployment")
dir.create(td)

deployment <- file.path(
  td,
  "pbsm-instrument-deployment-short-form-2018.xls"
)

download.file("https://members.oceantrack.org/data/repository/pbsm/data-and-metadata/2018/pbsm-instrument-deployment-short-form-2018.xls",
  destfile = deployment,
  mode = "wb"
)



test_that("expected classes", {
  expect_s3_class(
    deployment_xl <- clean_otn_deployment(deployment),
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
  deployment_xl <- clean_otn_deployment(deployment)

  expect_equal(
    attributes(deployment_xl$deploy_date_time)$tzone,
    "UTC"
  )
  expect_equal(
    attributes(deployment_xl$recover_date_time)$tzone,
    "UTC"
  )
})

test_that("guesses sheet", {
  deployment_sheet1 <- file.path(
    td,
    "one_sheet.xlsx"
  )

  readxl::read_excel(deployment, sheet = 2) |>
    writexl::write_xlsx(deployment_sheet1)

  deployment_sheet1 <- clean_otn_deployment(deployment_sheet1)
  deployment_sheet2 <- clean_otn_deployment(deployment)

  expect_equal(
    deployment_sheet1,
    deployment_sheet2
  )
})



test_that("accepts csv", {
  deployment_csv <- file.path(
    td,
    "pbsm-instrument-deployment-short-form-2018.csv"
  )
  readxl::read_excel(deployment, sheet = 2) |>
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


test_that("errors if not a CSV or XLS(X)", {
  expect_error(
    clean_otn_deployment("abcs.doc"),
    "File type is not xls, xlsx, or csv\\."
  )
})

unlink(td, recursive = TRUE)
