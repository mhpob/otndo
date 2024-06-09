test_that("zip files are unzipped", {
  zip(
    file.path(td, 'test.zip'),
    unlist(pbsm),
    flags = "-q"
  )

  { unzip_paths <- provided_file_unzip(file.path(td, 'test.zip'), td) }|>
    expect_message("zipped files detected") |>
    expect_message("Unzipped")

  expect_true(
    all(file.exists(unzip_paths))
  )
})
