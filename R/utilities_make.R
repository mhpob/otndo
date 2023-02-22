#' Place where functions live for the make_*_summary family of functions
#'
#' @param deployment blah blah blah document here
#' @param type blah blah blah document here
#' @param files blah blah blah document here
#' @param matos_project blah
#' @param project_files blah
#' @param temp_dir blahblah
#' @param detection_file blah
#'
#'
#' @name utilities-make
#' @keywords internal
clean_otn_deployment <- function(deployment){

  # check for header
  if(ncol(readxl::read_excel(deployment,
                             sheet = 2,
                             range = 'A1')) == 0){
    deployment <- readxl::read_excel(deployment, sheet = 2,
                                     skip = 3)
  }else{
    deployment <- readxl::read_excel(deployment, sheet = 2)
  }

  names(deployment) <- tolower(gsub(' .*', '', names(deployment)))
  deployment <- deployment[!is.na(deployment$deploy_date_time),]

  deployment$deploy_date_time  <-  as.POSIXct(deployment$deploy_date_time,
                                              tz = 'UTC',
                                              format = '%Y-%m-%dT%H:%M:%S')
  deployment$recover_date_time <-  as.POSIXct(deployment$recover_date_time,
                                              tz = 'UTC',
                                              format = '%Y-%m-%dT%H:%M:%S')

  deployment <- deployment[!is.na(deployment$deploy_date_time) &
                             !is.na(deployment$recover_date_time),]
  deployment$receiver <- paste(deployment$ins_model_no,
                               deployment$ins_serial_no,
                               sep = '-')
  deployment$stationname <- deployment$station_no

  if('transmitter' %in% names(deployment)){
    deployment$internal_transmitter <- deployment$transmitter
    deployment[, c('stationname', 'receiver', 'internal_transmitter',
                   'deploy_date_time', 'deploy_lat', 'deploy_long',
                   'recover_date_time')]
  }else(
    deployment[, c('stationname', 'receiver',
                   'deploy_date_time', 'deploy_lat', 'deploy_long',
                   'recover_date_time')]
  )

}

#' @rdname utilities-make
#' @keywords internal
act_file_download <- function(type, temp_dir = NULL, matos_project = NULL,
                              project_files = NULL){
  cli::cli_alert_info(paste('Downloading', type, 'detections...'))


  if(type == 'deployment'){
    # list project files and select deployment metadata
    files <- list_project_files(matos_project)

    files <- files[grepl('Deployment', files$file_type),]
  }else{
    # select the appropriate detection type
    files <- project_files[project_files$detection_type == type,]
  }

  # ping the server and download the file(s).
  files <- lapply(files$url,
                  function(.){
                    get_extract_file(url = .,
                                     out_dir = temp_dir)
                  }
  )


  files <- unlist(files)

  if(type != 'deployment'){
    files <- grep('\\.csv$', files, value = T)
  }

  cli::cli_alert_success('   Done.')

  files
}

#' @rdname utilities-make
#' @keywords internal
provided_file_unzip <- function(files, temp_dir){

  to_unzip <- grep('\\.zip$', files, value = T)

  cli::cli_alert_info(paste(length(to_unzip), 'zipped files detected...'))

  unzipped <- lapply(to_unzip,
                     function(.){
                       unzip(.,
                             exdir = temp_dir,
                             setTimes = FALSE)
                     })

  unzipped <- unlist(unzipped)

  unzipped <- grep('\\.csv$', unzipped, value = T)

  cli::cli_alert_success('   Unzipped.')

  unzipped
}

#' @rdname utilities-make
#' @keywords internal
write_to_tempdir <- function(type, files, temp_dir){

  if(type == 'deployment'){
    # Read in and clean deployment data
    files <- lapply(files,
                    clean_otn_deployment)
  }else{
    # Select and read in csv files for qualified and unqualified detections
    files <- lapply(files, read.csv)
  }

  #  Bind files together
  files <- do.call(rbind, files)

  ##  Write file to temporary directory
  filepath <- file.path(temp_dir, paste0(type, '.csv'))
  write.csv(files, filepath,
            row.names = F)


  filepath
}


#' @rdname utilities-make
#' @keywords internal

extract_proj_name <- function(detection_file){
  # Pull in the first row of the data ser in order to grab the collection code
  project <- read.csv(detection_file, nrows = 1)$collectioncode
  project <- gsub('OTN.', '', project)
  project <- gsub('^PROJ', 'ACT.PROJ', project)

  otn_metadata_query <- paste0("https://members.oceantrack.org/geoserver/otn/ows?service=WFS&version=1.0.0&request=GetFeature&typeName=otn:",
                               "otn_resources_metadata_points",
                               "&outputFormat=csv&CQL_FILTER=collectioncode='",
                               project,
                               "'") |>
    URLencode()

  list(project_name = otn_metadata_query$resource_full_name,
       project_code = gsub('.*\\.', '', otn_metadata_query$collectioncode))
}
