test_that("setup.R successfully created test files", {
  expect_true("pbsm" %in% ls())
  expect_true("td" %in% ls())
  expect_true(dir.exists(td))

  expect_true(file.exists(pbsm$matched))
  expect_true(file.exists(pbsm$qualified))
  expect_true(file.exists(pbsm$unqualified))
  expect_true(file.exists(pbsm$deployment))
})
