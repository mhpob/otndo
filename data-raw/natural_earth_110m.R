ne_github <- "https://raw.githubusercontent.com/nvkelso/natural-earth-vector/master/110m_physical/"

dir.create("ne_coastline", showWarnings = FALSE)

# Download files
for (i in c("shp", "shx", "dbf", "prj")) {
  file_url <- paste0(ne_github, "ne_110m_coastline.", i)
  dest <- file.path("ne_coastline", paste0("ne_110m_coastline.", i))
  download.file(file_url, destfile = dest, mode = "wb")
}

natural_earth_110m <- sf::st_read("ne_coastline", quiet = TRUE) |>
  sf::st_coordinates() |>
  data.frame()

names(natural_earth_110m) <- c("longitude", "latitude", "id")

usethis::use_data(natural_earth_110m, overwrite = TRUE)

unlink("ne_coastline", recursive = TRUE)
