test_that("setup.R successfully created test files", {
  expect_true(file.exists(pbsm$matched))
  expect_true(file.exists(pbsm$qualified))
  expect_true(file.exists(pbsm$unqualified))
  expect_true(file.exists(pbsm$deployment))
})
