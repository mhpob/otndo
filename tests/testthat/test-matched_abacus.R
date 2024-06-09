test_that("returns a ggplot object", {
  tag <- read.csv(pbsm$matched)
  t_dist <- temporal_distribution(tag, "tag")

  m_ab <- matched_abacus(t_dist$data, tag[tag$receiver == "release", ])

  expect_s3_class(
    m_ab,
    c("gg", "ggplot"),
    exact = TRUE
  )
})
