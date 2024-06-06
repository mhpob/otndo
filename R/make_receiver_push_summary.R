#' Create summary reports of receiver project data from the OTN data push
#'
#' @param qualified,unqualified Default is NULL: a character vector of file paths of your qualified/unqualified detections. These can be CSVs or zipped folders.
#' @param update_push_log Do you wish to use an updated push log? Default is FALSE, but switch to TRUE if you haven't updated this package since the push occurred.
#' @param deployment File path of user-supplied master OTN receiver deployment metadata.
#' @param out_dir Defaults to working directory. In which directory would you like to save the report?
#' @param since Date in YYYY-MM-DD format. Summarizes what's new since the provided date.
#' @param rmd Logical. Compile via RMarkdown rather than Quarto?
#'
#' @section Push log:
#'
#'  To keep track of when ACT data pushes occur, a log is kept
#'  \href{https://raw.githubusercontent.com/mhpob/otndo/master/inst/push_log.csv}{on the package's GitHub page}. This is automatically downloaded every time you download
#'  or update the package, but you can avoid re-downloading the package by changing
#'  \code{update_push_log} to \code{TRUE}.
#'
#'  You can get similar behavior by providing a date to the \code{since} argument.
#'
#' @section Output:
#'
#'  This function creates an HTML report that can be viewed in your web browser.
#'
#' @export
#' @examples
#' \dontrun{
#' td <- file.path(tempdir(), "matos_test_files")
#' dir.create(td)
#'
#' download.file(
#'   paste0(
#'     "https://members.oceantrack.org/data/repository/pbsm/",
#'     "data-and-metadata/2018/pbsm-instrument-deployment-short-form-2018.xls/",
#'     "@@download/file"
#'   ),
#'   destfile = file.path(td, "pbsm-instrument-deployment-short-form-2018.xls"),
#'   mode = "wb"
#' )
#'
#'
#' download.file(
#'   paste0(
#'     "https://members.oceantrack.org/data/repository/pbsm/",
#'     "detection-extracts/pbsm_qualified_detections_2018.zip/",
#'     "@@download/file"
#'   ),
#'   destfile = file.path(td, "pbsm_qualified_detections_2018.zip"),
#'   mode = "wb"
#' )
#' unzip(
#'   file.path(td, "pbsm_qualified_detections_2018.zip"),
#'   exdir = td
#' )
#'
#' download.file(
#'   paste0(
#'     "https://members.oceantrack.org/data/repository/pbsm/",
#'     "detection-extracts/pbsm_unqualified_detections_2018.zip/",
#'     "@@download/file"
#'   ),
#'   destfile = file.path(td, "pbsm_unqualified_detections_2018.zip"),
#'   mode = "wb"
#' )
#' unzip(
#'   file.path(td, "pbsm_unqualified_detections_2018.zip"),
#'   exdir = td
#' )
#'
#' qualified_files <- file.path(td, "pbsm_qualified_detections_2018.csv")
#' unqualified_files <- file.path(td, "pbsm_unqualified_detections_2018.csv")
#' deployment_files <- file.path(td, "pbsm-instrument-deployment-short-form-2018.xls")
#'
#'
#' make_receiver_push_summary(
#'   qualified = qualified_files,
#'   unqualified = unqualified_files,
#'   deployment = deployment_files,
#'   since = "2018-11-01"
#' )
#' }
make_receiver_push_summary <- function(
    qualified = NULL,
    unqualified = NULL,
    update_push_log = FALSE,
    deployment = NULL,
    out_dir = getwd(),
    since = NULL,
    rmd = FALSE) {
  # Try to provide a helpful error if there are missing files.
  if (any(is.null(qualified), is.null(unqualified), is.null(deployment))) {
    cli::cli_abort("Must provide at least one each of {.href [qualified detections, unqualified detections](https://members.oceantrack.org/data/otn-detection-extract-documentation-matched-to-animals#autotoc-item-autotoc-2)}, and deployment metadata.")
  }



  # Push log ----
  if (update_push_log == TRUE) {
    push_log <- "https://raw.githubusercontent.com/mhpob/otndo/master/inst/push_log.csv"
  } else {
    push_log <- system.file("push_log.csv",
      package = "otndo"
    )
  }

  if (is.null(since)) {
    since <- read.csv(push_log)
    since <- since[nrow(since) - 1, ]
  }

  # Create a temporary directory to store intermediate files ----
  td <- file.path(tempdir(), "otndo_files")

  # remove previous files. Needed if things errored out.
  if (file.exists(td)) {
    unlink(td, recursive = T)
  }

  dir.create(td)



  # Qualified detections ----
  ## Unzip if zipped detections were provided
  if (any(grepl("\\.zip$", qualified))) {
    qualified <- provided_file_unzip(
      files = qualified,
      temp_dir = td
    )
  }

  ## Import and write to tempdir
  qualified_filepath <- write_to_tempdir(
    type = "qualified",
    files = qualified,
    temp_dir = td
  )




  # Unqualified detections ----
  ## Unzip if zipped detections were provided
  if (any(grepl("\\.zip$", unqualified))) {
    unqualified <- provided_file_unzip(
      files = unqualified,
      temp_dir = td
    )
  }

  ## Import and write to tempdir
  unqualified_filepath <- write_to_tempdir(
    type = "unqualified",
    files = unqualified,
    temp_dir = td
  )




  # Deployment log ----
  ## Import and write to tempdir
  deployment_filepath <- write_to_tempdir(
    type = "deployment",
    files = deployment,
    temp_dir = td
  )





  # Ask OTN's GeoServer for name information ----
  cli::cli_alert_info("Asking OTN GeoServer for project information...")

  project_info <- extract_proj_name(qualified_filepath)

  project_name <- project_info$project_name
  project_code <- project_info$project_code

  project_number <- NULL


  # Write report ----
  cli::cli_alert_info("Writing report...")

  file.copy(
    from = system.file("qmd_template",
      "make_receiver_push_summary.qmd",
      package = "otndo"
    ),
    to = td
  )

  if (Sys.which("quarto") != "" & rmd == FALSE) {
    quarto::quarto_render(
      input = file.path(td, "make_receiver_push_summary.qmd"),
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
  } else {
    rmarkdown::render(
      input = file.path(td, "make_receiver_push_summary.qmd"),
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

  file.copy(
    from = file.path(td, "make_receiver_push_summary.html"),
    to = file.path(
      out_dir,
      paste(Sys.Date(),
        project_code,
        "receiver_push_summary.html",
        sep = "_"
      )
    )
  )

  cli::cli_alert_success("   Done.")

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
