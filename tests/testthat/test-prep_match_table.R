test_that("creates a js table for receiver data", {
  qual <- read.csv(qualified_path)

  tbl <- match_table(qual, "receiver")

  expect_s3_class(tbl, c("reactable", "htmlwidget"), exact = TRUE)
  expect_type(tbl$x, "list")

  # 9 columns
  expect_length(tbl$x$tag$attribs$columns, 9)

  # Correct names
  expect_equal(
    sapply(tbl$x$tag$attribs$columns, `[[`, "name"),
    c("PI", "POC", "Project name", "Network", "Project code",
      "Detections", "Individuals", "PI_emails", "POC_emails" )
  )
})



test_that("creates a js table for tag data", {
  matched <- read.csv(matched_path)

  tbl <- match_table(matched, "tag")

  expect_s3_class(tbl, c('reactable', 'htmlwidget'), exact = TRUE)
  expect_type(tbl$x, 'list')

  # 9 columns
  expect_length(tbl$x$tag$attribs$columns, 9)

  # Correct names
  expect_equal(
    sapply(tbl$x$tag$attribs$columns, `[[`, 'name'),
    c("PI", "POC", "Project name", "Network", "Project code",
      "Detections", "Individuals", "PI_emails", "POC_emails" )
  )
})
