td <- file.path(tempdir(), 'tests')
dir.create(td)

pbsm_files <- list.files(
  test_path('fixtures'),
  pattern = '\\.rds$',
  full.names = T
) |>
  sapply(readRDS, USE.NAMES = TRUE)


for(i in seq_along(pbsm_files)){
  write.csv(
    pbsm_files[[i]],
    file.path(
      td,
      gsub(
        "rds", "csv",
        basename(names(pbsm_files)[i])
      )
    ),
    row.names = FALSE
  )
}


pbsm <- list(
  matched = file.path(td, 'pbsm_matched.csv'),
  qualified = file.path(td, 'pbsm_qualified.csv'),
  unqualified = file.path(td, 'pbsm_unqualified.csv'),
  deployment = test_path("fixtures", "pbsm-instrument-deployment-short-form-2018.xls")
)


rm(pbsm_files, i)
