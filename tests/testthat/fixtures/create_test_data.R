# This was last run on 25 November, 2024
library(data.table)

td <- file.path(tempdir(), "otndo_test_files")
dir.create(td)

## Qualified detections
download.file("https://members.oceantrack.org/data/repository/pbsm/detection-extracts/pbsm_qualified_detections_2018.zip/@@download/file",
  destfile = file.path(td, "pbsm_qualified_detections_2018.zip"),
  mode = "wb",
  quiet = TRUE
)
unzip(file.path(td, "pbsm_qualified_detections_2018.zip"),
  exdir = td
)


qual <- fread(file.path(td, "pbsm_qualified_detections_2018.csv"))

qual <- qual[, .(
  collectioncode, datelastmodified, datecollected, trackercode,
  fieldnumber, station, latitude, longitude, tag_contact_pi,
  tag_contact_poc, scientificname
)]

# sample a subset
set.seed(8675309)
qual <- qual[sample(1:.N, 100)]

# Make a fake second individual to test that multiple indivs are summarized
qual[grepl("A69-9001-246", fieldnumber)][1:2, "fieldnumber"] <- "A69-9001-24614"
# Make a fake third individual that is a different species in the same project
qual[grepl("A69-9001-246", fieldnumber)][3:4, "fieldnumber"] <- "A69-9001-24615"
qual[fieldnumber == "A69-9001-24615", "scientificname"] <- "Acipenser brevirostrum"

saveRDS(data.frame(qual), "tests/testthat/fixtures/pbsm_qualified.rds")




## Unqualified detections
download.file("https://members.oceantrack.org/data/repository/pbsm/detection-extracts/pbsm_unqualified_detections_2018.zip/@@download/file",
  destfile = file.path(td, "pbsm_unqualified_detections_2018.zip"),
  mode = "wb",
  quiet = TRUE
)
unzip(file.path(td, "pbsm_unqualified_detections_2018.zip"),
  exdir = td
)


unqual <- fread(file.path(td, "pbsm_unqualified_detections_2018.csv"))

unqual <- unqual[, .(
  collectioncode, datelastmodified, datecollected,
  fieldnumber, station, latitude, longitude
)]

# sample a subset
set.seed(8675309)
unqual <- unqual[sample(1:.N, 100)]
saveRDS(data.frame(unqual), "tests/testthat/fixtures/pbsm_unqualified.rds")




## Deployment records
# download.file("https://members.oceantrack.org/data/repository/pbsm/data-and-metadata/archived-records/2018/pbsm-instrument-deployment-short-form-2018.xls/@@download/file",
#   destfile = file.path(
#     "tests/testthat/fixtures",
#     "pbsm-instrument-deployment-short-form-2018.xls"
#   ),
#   mode = "wb",
#   quiet = TRUE
# )

# Fake header lines were added by hand for testing against sheets that contain
#   a standard 3 line header
# Literally just 3 lines at the top with some text in them.


## Matched detections
download.file(
  "https://members.oceantrack.org/data/repository/pbsm/detection-extracts/pbsm_matched_detections_2018.zip/@@download/file",
  destfile = file.path(td, "pbsm_matched_detections_2018.zip"),
  mode = "wb",
  quiet = TRUE
)
unzip(file.path(td, "pbsm_matched_detections_2018.zip"),
  exdir = td
)

matched <- fread(file.path(td, "pbsm_matched_detections_2018.csv"))

matched <- matched[, .(
  collectioncode, scientificname, commonname, datelastmodified, detectedby,
  station, receiver, tagname, datecollected, longitude, latitude,
  citation, contact_poc, contact_pi
)]

# Randomly select up to 5 detections per project
set.seed(8675309)
matched <- rbind(
  matched[, .SD[sample(.N, ifelse(.N >= 5, 5, .N))], detectedby],
  # Need to retain some release data
  matched[receiver == "release"],
  # Need to retain some "new" data
  matched[datelastmodified >= "2018-05-06"][5]
)
saveRDS(data.frame(matched), "tests/testthat/fixtures/pbsm_matched.rds")
