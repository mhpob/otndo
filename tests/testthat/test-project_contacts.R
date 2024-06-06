skip_if_offline()

test_that("returns correct class for tags", {
  matched <- read.csv(matched_path)

  expect_s3_class(
    pi_table <- project_contacts(matched, type = "tag"),
    c("data.table", "data.frame"),
    exact = TRUE
  )

  expect_type(
    pi_table$project_name,
    "character"
  )
  expect_type(
    pi_table$PI,
    "character"
  )
  expect_type(
    pi_table$POC,
    "character"
  )
  expect_type(
    pi_table$PI_emails,
    "character"
  )
  expect_type(
    pi_table$POC_emails,
    "character"
  )
})

test_that("right things are returned for tags", {
  matched <- read.csv(matched_path)

  pi_table <- project_contacts(matched, type = "tag")

  expect_equal(
    ncol(pi_table),
    5
  )

  expect_named(
    pi_table,
    c("project_name", "PI", "POC", "PI_emails", "POC_emails")
  )

  # contains emails
  expect_true(
    all(grepl("@", pi_table$PI_emails))
  )
  expect_true(
    all(grepl("@", pi_table$POC_emails))
  )
})


test_that("returns correct class for receivers", {
  qualified <- read.csv(qualified_path)

  expect_s3_class(
    pi_table <- project_contacts(qualified, type = "receivers"),
    c("data.table", "data.frame"),
    exact = TRUE
  )

  expect_type(
    pi_table$project_name,
    "character"
  )
  expect_type(
    pi_table$PI,
    "character"
  )
  expect_type(
    pi_table$POC,
    "character"
  )
  expect_type(
    pi_table$PI_emails,
    "character"
  )
  expect_type(
    pi_table$POC_emails,
    "character"
  )
})

test_that("right things are returned for receivers", {
  qualified <- read.csv(qualified_path)

  pi_table <- project_contacts(qualified, type = "receivers")

  expect_equal(
    ncol(pi_table),
    5
  )

  expect_named(
    pi_table,
    c("project_name", "PI", "POC", "PI_emails", "POC_emails")
  )

  # contains emails
  expect_true(
    all(grepl("@", pi_table$PI_emails))
  )
  expect_true(
    all(grepl("@|", pi_table$POC_emails))
  )
})
