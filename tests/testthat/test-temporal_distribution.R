test_that("returns a ggplot object for receivers", {
  rec <- read.csv(qualified_path)

  temp_dist <- temporal_distribution(rec, type = 'receiver')

  expect_s3_class(
    temp_dist,
    c('gg', 'ggplot'),
    exact = TRUE
  )

  expect_equal(
    sort(unique(temp_dist$data$trackercode)),
    sort(unique(rec$trackercode))
  )
})


test_that("returns a ggplot object for tags", {
  tag <- read.csv(matched_path)

  temp_dist <- temporal_distribution(tag, type = 'tag')

  expect_s3_class(
    temp_dist,
    c('gg', 'ggplot'),
    exact = TRUE
  )

  expect_equal(
    sort(unique(temp_dist$data$detectedby)),
    sort(unique(tag$detectedby))
  )
})
