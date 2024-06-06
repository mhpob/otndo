skip_if_offline()


test_that("Non-ACT projects are summarized", {
  expect_no_error(
    make_tag_push_summary(
      matched = matched_path,
      since = "2018-05-06"
    )
  )

  expect_true(any(grepl("tag_push_summary", list.files(getwd()))))
})
