skip_if_offline()

test_that("creates a named list with correct types", {
  otn <- otn_query("PBSM")

  expect_type(otn, "list")
  expect_named(
    otn,
    c(
      "otn_resources_metadata_points",
      "project_metadata"
    )
  )

  expect_s3_class(otn[[1]], "data.frame")
  expect_s3_class(otn[[2]], "data.frame")

  expect_named(
    otn$otn_resources_metadata_points,
    c(
      "FID", "collectioncode", "report", "resource_full_name", "ocean",
      "seriescode", "status", "collaborationtype", "totalrecords",
      "id", "the_geom"
    )
  )
  expect_named(
    otn$project_metadata,
    c(
      "FID", "collectioncode", "id", "seriescode", "collaborationtype",
      "shortname", "longname", "citation", "abstract", "institutioncode",
      "ocean", "country", "state", "local_area", "locality", "westbl",
      "eastbl", "southbl", "northbl", "status", "usage", "website",
      "sdate", "edate", "node", "database", "db_location", "datacentre",
      "the_geom"
    )
  )
})


test_that("is node agnostic", {
  with_network <- otn_query(c("ACT.MDWEA", "ACT.TAILWINDS", "OTN.PBSM"))
  without_network <- otn_query(c("MDWEA", "TAILWINDS", "PBSM"))

  # FID is query-unique, so drop that one...
  expect_identical(
    with_network$otn_resources_metadata_points[, -"FID"],
    without_network$otn_resources_metadata_points[, -"FID"]
  )
  # ...and test it here.
  expect_false(
    identical(
      with_network$otn_resources_metadata_points$FID,
      without_network$otn_resources_metadata_points$FID
    )
  )

  expect_identical(
    with_network$project_metadata,
    without_network$project_metadata
  )
})
