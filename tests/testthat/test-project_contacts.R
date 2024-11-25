skip_if_offline()

matched <- read.csv(pbsm$matched)

test_that("returns correct class for tags", {
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



qualified <- read.csv(pbsm$qualified)

test_that("returns correct class for receivers", {
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




test_that("Multiple sets of tag PIs per project are summarized", {
  matched_multiple_pis <- matched
  matched_multiple_pis[matched_multiple_pis$detectedby == "HFX", ][1, "contact_pi"] <-
    c("Matthew Apostle (matt@bible), Mary Mother (mary@bible)")


  pi_table <- project_contacts(matched_multiple_pis, "tag")

  expect_false(
    any(
      duplicated(pi_table$project_name)
    )
  )

  expect_match(
    pi_table[pi_table$project_name == "HFX", ]$PI,
    "Matthew Apostle, Mary Mother, Dave Hebert, Robert Lennox, Fred Whoriskey",
    fixed = TRUE
  )

  expect_match(
    pi_table[pi_table$project_name == "HFX", ]$PI_emails,
    "matt@bible,mary@bible,david.hebert@dfo-mpo.gc.ca,robert.lennox@dal.ca,fwhoriskey@dal.ca",
    fixed = TRUE
  )
})

test_that("Multiple sets of receiver PIs per project are summarized", {
  qual_multiple_pis <- qualified
  qual_multiple_pis[qual_multiple_pis$trackercode == "TAG", ][1, "tag_contact_pi"] <-
    c("Matthew Apostle (matt@bible), Mary Mother (mary@bible)")

  pi_table <- project_contacts(qual_multiple_pis, "receiver")

  expect_false(
    any(
      duplicated(pi_table$project_name)
    )
  )

  expect_match(
    pi_table[pi_table$project_name == "TAG", ]$PI,
    "Matthew Apostle, Mary Mother, Barbara Block",
    fixed = TRUE
  )

  expect_match(
    pi_table[pi_table$project_name == "TAG", ]$PI_emails,
    "matt@bible,mary@bible,bblock@stanford.edu",
    fixed = TRUE
  )
})
