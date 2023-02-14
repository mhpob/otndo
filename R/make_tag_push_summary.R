#' Create summary reports of receiver project data from the OTN data push
#'
#' @param matos_project MATOS project number or name that you wish to have summarized
#' @param matched Default is NULL; OTN matched detections will be downloaded and unzipped. If you do not wish to download your files, this argument also accepts a character vector of file paths of your matched detections.
#' @param update_push_log Do you wish to use an updated push log? Default is FALSE, but switch to TRUE if you haven't updated this package since the push occurred.
#' @param sensor_decoding Not yet implemented. Will be a place to provide information to decode and summarize sensor data,

make_tag_push_summary <- function(
    matos_project = NULL,
    matched = NULL,
    update_push_log = F,
    sensor_decoding = NULL
){
  matos_project = 87
  matched = NULL
  update_push_log = F
  if(all(is.null(matos_project), is.null(matched))){
    cli::cli_abort('Must provide an ACT/MATOS project or at least one set of OTN-matched data.')
  }

  # Push log ----
  if(update_push_log == TRUE){
    push_log <- 'https://raw.githubusercontent.com/mhpob/matos/master/inst/push_log.csv'
  }else{
    push_log <- system.file("push_log.csv",
                            package = "matos")
  }

  td <- file.path(tempdir(), 'matos_files')
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


  if(is.null(matched)){
    cli::cli_alert_info('Finding extraction files...')
    matched <- list_extract_files(project_number, 'matched')
    cli::cli_alert_success('   Files found.')

    cli::cli_alert_info('Downloading matched detections...')

    matched <- lapply(matched$url,
                      function(.){
                        get_extract_file(url = .,
                                         out_dir = td)
                      }
    )

    matched <- unlist(matched)
    matched <- grep('\\.csv$', matched, value = T)

    cli::cli_alert_success('   Downloads complete.')
  }

  ##  Bind files together
  matched <- lapply(matched, read.csv)
  matched <- do.call(rbind, matched)

  ##  Write file to temporary directory
  matched_filepath <- file.path(td, 'matched.csv')
  write.csv(matched, matched_filepath,
            row.names = F)


  ## Tag metadata ----


  ## Write report ---
  cli::cli_alert_info('Writing report...')

  file.copy(from = system.file('qmd_template',
                               'make_tag_push_summary.qmd',
                               package = 'matos'),
            to = td)

  quarto::quarto_render(
    input = file.path(td, 'make_tag_push_summary.qmd'),
    execute_params = list(
      project_name = project_name,
      project_number = project_number,
      matched = matched_filepath,
      push_log = push_log
    ))

  file.copy(from = file.path(td,'make_tag_push_summary.html'),
            to = file.path(getwd(), paste0(Sys.Date(), '_tag_push_summary.html')))

  cli::cli_alert_success('   Done.')

  unlink(td, recursive = T)
}

