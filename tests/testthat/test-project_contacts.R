td <- file.path(tempdir(), "matos_test_files")
dir.create(td)
library(data.table)

set_up_test_project_contacts <- function(type, td){
  file_base <- paste0("pbsm_", type, "_detections_2018")
  file_loc <- file.path(td, paste0(file_base, ".zip"))
  download.file(
    paste0(
      "https://members.oceantrack.org/data/repository/",
      "pbsm/detection-extracts/",
      paste0(file_base, ".zip")
    ),
    destfile = file_loc
  )
  unzip(file_loc,
        exdir = td)

  contacts <- file.path(td, paste0(file_base, ".csv"))

  contacts <- write_to_tempdir(
    type = type,
    files = contacts,
    temp_dir = td
  )

  contacts <- fread(contacts)
  contacts[, day := as.Date(datecollected)]

  contacts
}

matched <- set_up_test_project_contacts("matched", td)
qualified <- set_up_test_project_contacts("qualified", td)

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


test_that("returns correct class for receivers", {
  expect_s3_class(
    pi_table <- project_contacts(matched, type = "receivers"),
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
  pi_table <- project_contacts(matched, type = "receivers")

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


unlink(td, recursive = TRUE)
