test_that("receiver project with multiple species is summarized", {
  qual <- read.csv(pbsm$qualified)

  tbl_qual <- prep_match_table(qual, "receiver")

  expect_equal(
    tbl_qual[`Project code` == "IBFS"]$Species,
    c("Acipenser oxyrinchus", "Acipenser brevirostrum")
  )

  expect_equal(
    tbl_qual[`Project code` == "IBFS"]$Detections,
    c(4, 2)
  )

  expect_equal(
    tbl_qual[`Project code` == "IBFS"]$Individuals,
    c(2, 1)
  )
})


test_that("networks without species info (ACT) work", {
  qual <- read.csv(pbsm$qualified)
  qual$scientificname <- NULL

  tbl_no_spp <- prep_match_table(qual, "receiver")

  # Make sure the test was set up correctly
  #   No spp info means each project should be represented once.
  expect_equal(
    nrow(tbl_no_spp),
    data.table::uniqueN(tbl_no_spp, by = "Project name")
  )

  expect_true(
    all(is.na(tbl_no_spp$Species))
  )

})
