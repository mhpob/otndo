#' Place where functions live for the make_*_summary family of functions
#'
#' @param deployment Character. File path of deployment metadata.
#' @param type Character. Type of data (deployment, qualified, or unqualified).
#' @param files Character. File paths of files to be unzipped or written to a directory
#' @param temp_dir Character. File path of temporary directory
#' @param detection_file Character. File path of detections.
#'
#'
#' @name utilities-make
#' @keywords internal
clean_otn_deployment <- function(deployment) {
  file_ext <- gsub(".*\\.", "", deployment)
  if (grepl("^xls", file_ext)) {
    # Find which sheet has deployment data. If none are explicitly labeled, assume
    #   it's sheet 1
    sheet_id <- grep("dep", readxl::excel_sheets(deployment),
      ignore.case = T, value = T
    )
    if (length(sheet_id) == 0) {
      sheet_id <- 1
    }

    # Check for header: If the first row has no columns, it likely contains it.
    if (ncol(readxl::read_excel(deployment,
      sheet = sheet_id,
      range = "A1"
    )) == 0) {
      deployment <- readxl::read_excel(deployment,
        sheet = sheet_id,
        skip = 3
      )
    } else {
      deployment <- readxl::read_excel(deployment, sheet = sheet_id)
    }
  } else if (grepl("^csv$", file_ext)) {
    # Check for OTN header
    if (ncol(read.csv(deployment, nrows = 1)) == 0) {
      deployment <- read.csv(deployment, skip = 3)
    } else {
      deployment <- read.csv(deployment)
    }
  } else {
    cli::cli_abort("File type is not xls, xlsx, or csv.")
  }

  # Drop everything after a space in an Excel sheet; read.csv converts spaces
  #   to periods, so also drop everything after a period
  names(deployment) <- tolower(
    gsub("[ \\.].*", "", names(deployment))
  )

  deployment <- deployment[!is.na(deployment$deploy_date_time), ]
  deployment <- deployment[!deployment$recovered %in% c("l", "failed"), ]

  deployment$deploy_date_time <- as.POSIXct(
    deployment$deploy_date_time,
    tz = "UTC",
    tryFormats = c(
      "%Y-%m-%dT%H:%M:%S",
      "%Y-%m-%d %H:%M:%S",
      "%Y-%m-%d %H:%M:%OS"
    )
  )
  deployment$recover_date_time <- as.POSIXct(
    deployment$recover_date_time,
    tz = "UTC",
    tryFormats = c(
      "%Y-%m-%dT%H:%M:%S",
      "%Y-%m-%d %H:%M:%S",
      "%Y-%m-%d %H:%M:%OS"
    )
  )

  deployment <- deployment[!is.na(deployment$deploy_date_time) &
    !is.na(deployment$recover_date_time), ]
  deployment$receiver <- paste(deployment$ins_model_no,
    deployment$ins_serial_no,
    sep = "-"
  )
  deployment$stationname <- deployment$station_no

  if ("transmitter" %in% names(deployment)) {
    deployment$internal_transmitter <- deployment$transmitter
    deployment[, c(
      "stationname", "receiver", "internal_transmitter",
      "deploy_date_time", "deploy_lat", "deploy_long",
      "recover_date_time"
    )]
  } else {
    (
      deployment[, c(
        "stationname", "receiver",
        "deploy_date_time", "deploy_lat", "deploy_long",
        "recover_date_time"
      )]
    )
  }
}


#' @rdname utilities-make
#' @keywords internal
provided_file_unzip <- function(files, temp_dir) {
  to_unzip <- grep("\\.zip$", files, value = T)

  cli::cli_alert_info(paste(length(to_unzip), "zipped files detected..."))

  unzipped <- lapply(
    to_unzip,
    function(.) {
      unzip(.,
        exdir = temp_dir,
        setTimes = FALSE
      )
    }
  )

  unzipped <- unlist(unzipped)

  unzipped <- grep("\\.csv$", unzipped, value = T)

  cli::cli_alert_success("   Unzipped.")

  unzipped
}

#' @rdname utilities-make
#' @keywords internal
write_to_tempdir <- function(type, files, temp_dir) {
  if (type == "deployment") {
    # Read in and clean deployment data
    files <- lapply(
      files,
      clean_otn_deployment
    )
  } else {
    # Select and read in csv files for qualified and unqualified detections
    files <- lapply(files, read.csv)
  }

  #  Bind files together
  files <- do.call(rbind, files)

  ##  Write file to temporary directory
  filepath <- file.path(temp_dir, paste0(type, ".csv"))
  write.csv(files, filepath,
    row.names = F
  )


  filepath
}


#' @rdname utilities-make
#' @keywords internal

extract_proj_name <- function(detection_file) {
  # Pull in the first row of the data in order to grab the collection code
  project <- read.csv(detection_file, nrows = 1)$collectioncode

  otn_metadata_query <- paste0(
    "https://members.oceantrack.org/geoserver/otn/ows",
    "?service=WFS&version=1.0.0&request=GetFeature&typeName=otn:",
    "otn_resources_metadata_points",
    "&outputFormat=csv&CQL_FILTER=strMatches(collectioncode,'",
    paste(
      paste0(
        ".*",
        gsub(".*\\.", "", project)
      ),
      collapse = "|"
    ),
    "')=true"
  ) |>
    URLencode()

  otn_response <- read.csv(otn_metadata_query)
  list(
    project_name = otn_response$resource_full_name,
    project_code = gsub(".*\\.", "", otn_response$collectioncode)
  )
}
