test_that("creates a js table for receiver data", {
  qual <- read.csv(pbsm$qualified)

  tbl_qual <- match_table(qual, "receiver")

  expect_s3_class(tbl_qual, c("reactable", "htmlwidget"), exact = TRUE)
  expect_type(tbl_qual$x, "list")

  # 10 columns
  expect_length(tbl_qual$x$tag$attribs$columns, 10)

  # Correct names
  expect_equal(
    sapply(tbl_qual$x$tag$attribs$columns, `[[`, "name"),
    c(
      "PI", "POC", "Project name", "Network", "Project code", "Species",
      "Detections", "Individuals", "PI_emails", "POC_emails"
    )
  )
})



test_that("creates a js table for tag data", {
  matched <- read.csv(pbsm$matched)

  tbl_matched <- match_table(matched, "tag")

  expect_s3_class(tbl_matched, c("reactable", "htmlwidget"), exact = TRUE)
  expect_type(tbl_matched$x, "list")

  # 10 columns
  expect_length(tbl_matched$x$tag$attribs$columns, 10)

  # Correct names
  expect_equal(
    sapply(tbl_matched$x$tag$attribs$columns, `[[`, "name"),
    c(
      "PI", "POC", "Project name", "Network", "Project code", "Species",
      "Detections", "Individuals", "PI_emails", "POC_emails"
    )
  )
})



test_that("species columnn is dropped if no species present", {
  qual <- read.csv(pbsm$qualified)
  qual$scientificname <- NULL

  tbl_qual <- match_table(qual, "receiver")

  expect_false(tbl_qual$x$tag$attribs$columns[[6]]$show)

  expect_s3_class(tbl_qual, c("reactable", "htmlwidget"), exact = TRUE)
  expect_type(tbl_qual$x, "list")
})
