test_that("returns a ggplot object", {
  dep <- clean_otn_deployment(pbsm$deployment)

  gantt <- deployment_gantt(dep)

  expect_s3_class(
    gantt,
    c("gg", "ggplot"),
    exact = TRUE
  )

  expect_equal(
    sort(unique(gantt$data$stationname)),
    sort(unique(dep$stationname))
  )
})
