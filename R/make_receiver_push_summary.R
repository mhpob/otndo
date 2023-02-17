#' Create summary reports of receiver project data from the OTN data push
#'
#' @param matos_project MATOS project number or name that you wish to have summarized
#' @param qualified Default is NULL; OTN qualified detections will be downloaded and unzipped. If you do not wish to download your qualified detections, this argument also accepts a character vector of file paths of your qualified detections.
#' @param unqualified Default is NULL; OTN unqualified detections will be downloaded and unzipped. If you do not wish to download your unqualified detections, this argument also accepts a character vector of file paths of your unqualified detections.
#' @param update_push_log Do you wish to use an updated push log? Default is FALSE, but switch to TRUE if you haven't updated this package since the push occurred.
#' @param deployment File path of user-supplied master OTN receiver deployment metadata.
#' @param out_dir Defaults to working directory. In which directory would you like to save the report?
#' @param since Date in YYYY-MM-DD format. If you're an ACT-ite, this is mostly covered by the embedded ACT push log.
#'
#' @section Push log:
#'
#'  To keep track of when ACT data pushes occur, a log is kept
#'  \href{https://raw.githubusercontent.com/mhpob/matos/master/inst/push_log.csv}{on the package's GitHub page}. This is automatically downloaded every time you download
#'  or update the package, but you can avoid re-downloading the package by changing
#'  \code{update_push_log} to \code{TRUE}.
#'
#'  If you're not an ACTee, you can get similar behavior by providing a date to the \code{since} argument.
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
    deployment = NULL,
    out_dir = getwd(),
    since = NULL
){
  if(is.null(matos_project) & any(is.null(qualified), is.null(unqualified), is.null(deployment))){
    cli::cli_abort('Must provide an ACT/MATOS project or at least one each of qualified detections, unqualified detections, and deployment.')
  }


  # Create a temporary directory to store intermediate files
  td <- file.path(tempdir(), 'matos_files')

  # remove previous files. Needed if things errored out.
  if(file.exists(td)){
    unlink(td, recursive = T)
  }

  dir.create(td)

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
    cli::cli_alert_info('Finding extraction files...')
    project_files <- list_extract_files(project_number, 'all')
    cli::cli_alert_success('   Files found.')
  }



  # Qualified detections ----
  ##  Download qualified detections if not provided
  if(is.null(qualified)){
    qualified <- act_file_download(type = 'qualified',
                                   project_files = project_files,
                                   temp_dir = td)
  }

  ## Import and write to tempdir
  qualified_filepath <- write_to_tempdir(type = 'qualified',
                                         files = qualified,
                                         temp_dir = td)




  # Unqualified detections ----
  ##  Download unqualified detections if not provided
  if(is.null(unqualified)){
    unqualified <- act_file_download(type = 'unqualified',
                                     project_files = project_files,
                                     temp_dir = td)
  }

  ## Import and write to tempdir
  unqualified_filepath <- write_to_tempdir(type = 'unqualified',
                                           files = unqualified,
                                           temp_dir = td)




  # Deployment log ----
  ##  Download deployment metadata if not provided
  if(is.null(deployment)){
    deployment <- act_file_download(type = 'deployment',
                                    matos_project = matos_project,
                                    temp_dir = td)
  }

  ## Import and write to tempdir
  deployment_filepath <- write_to_tempdir(type = 'deployment',
                                          files = deployment,
                                          temp_dir = td)


  # Push log ----
  if(update_push_log == TRUE){
    push_log <- 'https://raw.githubusercontent.com/mhpob/matos/master/inst/push_log.csv'
  }else{
    push_log <- system.file("push_log.csv",
                            package="matos")
  }


  cli::cli_alert_info('Writing report...')

  file.copy(from = system.file('qmd_template',
                        'make_receiver_push_summary.qmd',
                        package = 'matos'),
            to = td)

  if(Sys.which('quarto') != ''){
    quarto::quarto_render(
      input = file.path(td, 'make_receiver_push_summary.qmd'),
      execute_params = list(
        project_name = project_name,
        project_number = project_number,
        qualified = qualified_filepath,
        unqualified = unqualified_filepath,
        deployment = deployment_filepath,
        push_log = push_log,
        since = since
      )
    )
  }else{
    rmarkdown::render(
      input = file.path(td, 'make_receiver_push_summary.qmd'),
      params = list(
        project_name = project_name,
        project_number = project_number,
        qualified = qualified_filepath,
        unqualified = unqualified_filepath,
        deployment = deployment_filepath,
        push_log = push_log,
        since = since
      )
    )
  }

  file.copy(from = file.path(td,'make_receiver_push_summary.html'),
            to = file.path(out_dir, paste0(Sys.Date(), '_receiver_push_summary.html')))

  cli::cli_alert_success('   Done.')

  unlink(td, recursive = T)
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

