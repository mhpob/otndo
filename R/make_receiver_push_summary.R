#' Create summary reports of the ACT data push
#'
#' @param matos_project MATOS project number or name that you wish to have summarized
#' @param qualified Default is NULL; OTN qualified detections will be downloaded and unzipped. If you do not wish to download your qualified detections, this argument also accepts a character vector of file paths of your qualified detections.
#' @param unqualified Default is NULL; OTN unqualified detections will be downloaded and unzipped. If you do not wish to download your unqualified detections, this argument also accepts a character vector of file paths of your unqualified detections.
#' @param update_push_log Do you wish to use an updated push log? Default is FALSE, but switch to TRUE if you haven't updated this package since the push occurred.
#' @param deployment File path of user-supplied master OTN receiver deployment metadata.
#'
#' @section Push log:
#'
#'  To keep track of when ACT data pushes occur, a log is kept
#'  \href{https://raw.githubusercontent.com/mhpob/matos/master/inst/push_log.csv}{on the package's GitHub page}. This is automatically downloaded every time you download
#'  or update the package, but you can avoid re-downloading the package by changing
#'  \code{update_push_log} to \code{TRUE}.
#'
#'
#' @section No files provided:
#'
#'  If you only provide your ACT project number or title and leave all of the
#'  arguments as their defaults, this function will ask you to log in then proceed
#'  to download all of the necessary files. If you provide already-downloaded files
#'  you can speed up this process substantially.
#'
#' @section Output:
#'
#'  This function creates an HTML report that can be viewed in your web browser.
#'
#' @export
#' @examples
#' \dontrun{
#' # Using only the ACT/MATOS project number:
#' make_receiver_push_summary(87)
#'
#' # Providing a local file:
#' make_receiver_push_summary(87, deployment = "my_master_deployment_metadata.xlsx")
#' }

make_receiver_push_summary <- function(
    matos_project = NULL,
    qualified = NULL,
    unqualified = NULL,
    update_push_log = F,
    deployment = NULL
){
  if(is.null(matos_project) & any(is.null(qualified), is.null(unqualified), is.null(deployment))){
    cli::cli_abort('Must provide an ACT/MATOS project or at least one each of qualified detections, unqualified detections, and deployment.')
  }


  # Create a temporary directory to store intermediate files
  td <- tempdir()

  # Project ----
  ##  Find project name
  if(is.numeric(matos_project)){
    project_number <- matos_project
    project_name <- get_project_name(matos_project)
  }
  if(is.character(matos_project)){
    project_name <- matos_project
    project_number <- get_project_number(matos_project)
  }
  if(is.null(matos_project)){
    project_name <- NULL
    project_number <- NULL
  }

  ##  Check that project name exists as written
  # if(length(get_project_number(matos_project)) == 0){
  #   stop('No project matching that name.')
  # }

  if(any(is.null(qualified), is.null(unqualified))){
    cli::cli_alert_info('Listing extraction files...')
    project_files <- list_extract_files(project_number, 'all')
    cli::cli_alert_success('   Done.')
  }

  # Qualified detections ----
  ##  Download qualified detections if not provided
  if(is.null(qualified)){
    cli::cli_alert_info('Downloading qualified detections...')

    qualified <- project_files[project_files$detection_type == 'qualified',]
    qualified <- lapply(qualified$url,
                        function(.){
                          get_extract_file(url = .)
                        }
    )

    qualified <- unlist(qualified)
    qualified <- grep('\\.csv$', qualified, value = T)

    cli::cli_alert_success('   Done.')
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
    cli::cli_alert_info('Downloading unqualified detections...')

    unqualified <- project_files[project_files$detection_type == 'unqualified',]
    unqualified <- lapply(unqualified$url,
                          function(.){
                            get_extract_file(url = .)
                          }
    )

    unqualified <- unlist(unqualified)
    unqualified <- grep('\\.csv$', unqualified, value = T)

    cli::cli_alert_success('   Done.')
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

  cli::cli_alert_info('Writing report...')

  file.copy(from = system.file('qmd_template',
                        'make_receiver_push_summary.qmd',
                        package = 'matos'),
            to = td)

  quarto::quarto_render(
    input = file.path(td, 'make_receiver_push_summary.qmd'),
    execute_params = list(
      project_name = project_name,
      project_number = project_number,
      qualified = qualified_filepath,
      unqualified = unqualified_filepath,
      push_log = push_log,
      deployment = deployment_filepath
    ))

  file.copy(from = file.path(td,'make_receiver_push_summary.html'),
            to = file.path(getwd(), paste0(Sys.Date(), '_receiver_push_summary.html')))

  cli::cli_alert_success('   Done.')

  unlink(td)
}

#' Utility function for make_receiver_push_summary
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

