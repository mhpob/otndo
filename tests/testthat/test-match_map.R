skip_if_offline()

test_that("mapping works", {
  otn <- otn_query(c('MDWEA', 'TAILWINDS'))

  map_out <- match_map(otn)

  expect_s3_class(
    map_out,
    c('gg', 'ggplot'),
    exact = TRUE
  )
})
