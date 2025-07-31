test_that("writes and converts deployment data", {
  deployment_filepath <- write_to_tempdir(
    type = "deployment",
    files = pbsm$deployment,
    temp_dir = td
  )

  expect_true(file.exists(deployment_filepath))


  deployment <- data.table::fread(deployment_filepath)

  expect_named(
    deployment,
    c(
      "stationname", "receiver", "internal_transmitter", "deploy_date_time",
      "deploy_lat", "deploy_long", "recover_date_time"
    )
  )

  expect_s3_class(
    deployment$deploy_date_time,
    "POSIXct"
  )
  expect_s3_class(
    deployment$recover_date_time,
    "POSIXct"
  )

  expect_type(
    deployment$deploy_lat,
    "double"
  )

  expect_type(
    deployment$deploy_lon,
    "double"
  )
})


test_that("works with multiple deployment files", {
  skip("Test TBD")
})

test_that("works with multiple qualified and unqualified files", {
  skip("Test TBD")
})
