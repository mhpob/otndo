#' Create summary reports of the ACT data push
#'
#' @param matos_project MATOS project number or name that you wish to have summarized
#' @param qualified Default is NULL; OTN qualified detections will be downloaded and unzipped. If you do not wish to download your qualified detections, this argument also accepts a character vector of file paths of your qualified detections.
#' @param unqualified Default is NULL; OTN unqualified detections will be downloaded and unzipped. If you do not wish to download your unqualified detections, this argument also accepts a character vector of file paths of your unqualified detections.
#' @param update_push_log Do you wish to use an updated push log? Default is FALSE, but switch to TRUE if you haven't updated this package since the push occurred.
#' @param deployment File path of user-supplied master OTN receiver deployment metadata.
#'
#' @export

act_push_summary <- function(
    matos_project,
    qualified = NULL,
    unqualified = NULL,
    update_push_log = F,
    deployment = NULL
){

  # Create a temporary directory to store intermediate files
  td <- tempdir()

  # Project ----
  ##  Find project name
  if(is.numeric(matos_project)){
    project_number <- matos_project
    project_name <- get_project_name(matos_project)
  }
  if(!is.numeric(matos_project)){
    project_name <- matos_project
    project_number <- get_project_number(matos_project)
  }

  ##  Check that project name exists as written
  # if(length(get_project_number(matos_project)) == 0){
  #   stop('No project matching that name.')
  # }

  if(any(is.null(qualified), is.null(unqualified))){
    cat('\nListing extraction files...\n')
    project_files <- list_extract_files(project_number, 'all')
    cat(' Done.\n')
  }

  # Qualified detections ----
  ##  Download qualified detections if not provided
  if(is.null(qualified)){
    cat('\nDownloading qualified detections...\n')

    qualified <- project_files[project_files$detection_type == 'qualified',]
    qualified <- lapply(qualified$url,
                        function(.){
                          get_extract_file(url = .)
                        }
    )

    qualified <- unlist(qualified)
    qualified <- grep('\\.csv$', qualified, value = T)

    cat(' Done.\n')
  }

  ##  Bind files together
  qualified <- lapply(qualified, read.csv)
  qualified <- do.call(rbind, qualified)

  ##  Write file to temporary directory
  qualified_filepath <- file.path(td, 'qualified.csv')
  write.csv(qualified, qualified_filepath,
            row.names = F)



  # Unqualified detections ----
  ##  Download unqualified detections if not provided
  if(is.null(unqualified)){
    cat('\nDownloading unqualified detections...\n')

    unqualified <- project_files[project_files$detection_type == 'unqualified',]
    unqualified <- lapply(unqualified$url,
                          function(.){
                            get_extract_file(url = .)
                          }
    )

    unqualified <- unlist(unqualified)
    unqualified <- grep('\\.csv$', unqualified, value = T)

    cat(' Done.\n')
  }

  ##  Bind files together
  unqualified <- lapply(unqualified, read.csv)
  unqualified <- do.call(rbind, unqualified)

  ##  Write file to temporary directory
  unqualified_filepath <- file.path(td, 'unqualified.csv')
  write.csv(unqualified, unqualified_filepath,
            row.names = F)



  # Push log ----
  if(update_push_log == TRUE){
    push_log <- 'https://raw.githubusercontent.com/mhpob/matos/master/inst/push_log.csv'
  }else{
    push_log <- system.file("push_log.csv",
                            package="matos")
  }


  # Deployment log ----
  if(is.null(deployment)){
    deployment_files <- list_project_files(matos_project)

    deployment_files <- deployment_files[grepl('Deployment', deployment_files$file_type),]

    deployment_files <- lapply(deployment_files$url,
                        function(.){
                          get_project_file(url = .)
                        })

    deployment <- unlist(deployment_files)
  }

  deployment_data <- lapply(deployment,
                            clean_otn_deployment)
  deployment_data <- do.call(rbind, deployment_data)

  deployment_filepath <- file.path(td, 'deployment.csv')
  write.csv(deployment_data, deployment_filepath,
            row.names = F)

  cat('\nWriting report...')

  quarto::quarto_render(
    input = 'inst/qmd_template/act-push-summary.qmd',
    execute_params = list(
      project_name = project_name,
      project_number = project_number,
      qualified = qualified_filepath,
      unqualified = unqualified_filepath,
      push_log = push_log,
      deployment = deployment_filepath
    ))

  cat('Done.\n')

  unlink(td)
}

#' Utility function for act_push_summary
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
  deployment <- deployment[!is.na(deployment$otn_array),]

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
  deployment$internal_transmitter <- deployment$transmitter
  deployment <- deployment[, c('stationname', 'receiver', 'internal_transmitter',
                               'deploy_date_time', 'deploy_lat', 'deploy_long',
                               'recover_date_time')]
}
# matos_project <- 192
# qualified <- c('proj192_qualified_detections_2021.csv',
#                'proj192_qualified_detections_2022.csv')
# unqualified <- c('proj192_unqualified_detections_2021.csv',
#                  'proj192_unqualified_detections_2022.csv')
# act_push_summary(matos_project,
#                  qualified,
#                  unqualified,
# deployment = c('NAVYKENN_metadata_deployment_202205.xlsx',
#                'NAVYKENN_metadata_deployment_202210.xlsx'))

