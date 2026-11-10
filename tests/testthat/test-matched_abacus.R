test_that("returns a ggplot object with correct number of labels", {
  tag <- read.csv(pbsm$matched)
  t_dist <- temporal_distribution(tag, "tag")

  m_ab <- matched_abacus(t_dist$data, tag[tag$receiver == "release", ])

  expect_s3_class(
    m_ab,
    c("gg", "ggplot")
  )

  # Max 30 labels
  expect_equal(
    length(m_ab@scales$scales[[1]]$breaks),
    30
  )
})

test_that("drops labels if N tags < 30", {
  tag <- read.csv(pbsm$matched)
  tag <- tag[tag$tagname %in% head(tag$tagname, n = 5), ]
  t_dist <- temporal_distribution(tag, "tag")

  m_ab <- matched_abacus(t_dist$data, tag[tag$receiver == "release", ])

  testthat::expect_equal(
    length(m_ab@scales$scales[[1]]$breaks),
    5
  )
})
