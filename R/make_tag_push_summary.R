#' Create summary reports of receiver project data from the OTN data push
#'
#' @param matos_project MATOS project number or name that you wish to have summarized
#' @param matched Default is NULL: OTN matched detections will be downloaded from MATOS and unzipped. If you do not wish to download your files (or you're not a member of ACT), this argument also accepts a character vector of file paths of your matched detections. These can be CSVs or zipped folders.
#' @param update_push_log Do you wish to use an updated push log? Default is FALSE, but switch to TRUE if you haven't updated this package since the push occurred.
#' @param since date in YYYY-MM-DD format. Provides a summary of detections that were matched/edited since that date.
#' @param sensor_decoding Not yet implemented. Will be a place to provide information to decode and summarize sensor data,
#' @param out_dir Defaults to working directory. In which directory would you like to save the report?
#' @param rmd Logical. Compile via RMarkdown rather than Quarto?
#'
#' @export
#' @examples
#' \dontrun{
#' # If you're an ACT-ee, you can just use your project number
#' make_tag_push_summary(87)
#'
#' # If you're not an ACT-ee, you need to provide your matched detections
#' # directly. The code below downloads some matched detections from OTN to show
#' # this.
#' td <- file.path(tempdir(), 'matos_test_files')
#' dir.create(td)
#'
#' download.file('https://members.oceantrack.org/data/repository/pbsm/detection-extracts/pbsm_matched_detections_2018.zip',
#'                destfile = file.path(td, 'pbsm_matched_detections_2018.zip'))
#' unzip(file.path(td, 'pbsm_matched_detections_2018.zip'),
#'       exdir = td)
#'
#' # Provide the detection file(s) to the \code{matched} argument, with an
#' # optional date to the \code{since} argument to summarize what was new since
#' # that date.
#' make_tag_push_summary(matched = file.path(td,
#'                        'pbsm_matched_detections_2018.csv'),
#'                        since = '2018-11-01')
#' }

make_tag_push_summary <- function(
    matos_project = NULL,
    matched = NULL,
    update_push_log = F,
    since = NULL,
    sensor_decoding = NULL,
    out_dir = getwd(),
    rmd = FALSE
){
  # matos_project = 87
  # matched = NULL
  # update_push_log = F
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
    project_code <- paste0('PROJ', project_number)
  }
  if(is.character(matos_project)){
    project_name <- matos_project
    project_number <- get_project_number(matos_project)
    project_code <- paste0('PROJ', project_number)
  }


  if(is.null(matched)){
    cli::cli_alert_info('Finding extraction files...')
    matched <- list_extract_files(project_number, 'all')
    cli::cli_alert_success('   Files found.\n')

    matched <- act_file_download(type = 'matched',
                                 project_files = matched,
                                 temp_dir = td)
  }

  ## Unzip if zipped detections were provided
  if(any(grepl('\\.zip$', matched))){
    matched <- provided_file_unzip(files = matched,
                                   temp_dir = td)

  }

  ##  Bind files together
  matched_filepath <- write_to_tempdir(type = 'matched',
                                       files = matched,
                                       temp_dir = td)


  ## Tag metadata ----


  # If not an ACT project, scrape OTN's geoserver for name information ----
  if(is.null(matos_project)){
    cli::cli_alert_info('Scraping OTN geoserver for project information...')

    project_info <- extract_proj_name(matched_filepath)

    project_name <- project_info$project_name
    project_code <- project_info$project_code

    project_number <- NULL
  }

  ## Write report ---
  cli::cli_alert_info('Writing report...')

  file.copy(from = system.file('qmd_template',
                               'make_tag_push_summary.qmd',
                               package = 'matos'),
            to = td)

  if(Sys.which('quarto') != '' & rmd == FALSE){
    quarto::quarto_render(
      input = file.path(td, 'make_tag_push_summary.qmd'),
      execute_params = list(
        project_name = project_name,
        project_number = project_number,
        matched = matched_filepath,
        push_log = push_log,
        since = since
      ))
  }else{
    rmarkdown::render(
      input = file.path(td, 'make_tag_push_summary.qmd'),
      params = list(
        project_name = project_name,
        project_number = project_number,
        matched = matched_filepath,
        push_log = push_log,
        since = since
      ))
  }

  file.copy(from = file.path(td, 'make_tag_push_summary.html'),
            to = file.path(out_dir, paste(Sys.Date(),
                                          project_code,
                                          'tag_push_summary.html',
                                          sep = '_')))

  cli::cli_alert_success('   Done.')

  unlink(td, recursive = T)
}

