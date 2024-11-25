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
