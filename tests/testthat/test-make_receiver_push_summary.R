skip_if_offline()


test_that("Deployment metadata can be cleaned", {
  expect_no_error(clean_otn_deployment(deployment_path))
})


test_that("Projects are summarized", {
  expect_no_error(
    make_receiver_push_summary(
      qualified = qualified_path,
      unqualified = unqualified_path,
      deployment = deployment_path,
      since = "2018-05-06"
    )
  )

  expect_true(any(grepl("receiver_push_summary", list.files(getwd()))))
})


unlink(td, recursive = T)
