#' List MATOS project files
#'
#' This function lists the file names, types, upload date, and URLs of MATOS
#' project files -- basically everything you see in the *Project Files* section
#' of your project page. Because it is from your project page, you will be
#' prompted to log in.
#'
#' @section Details:
#' \code{list_project_files} is a wrapper around a web-scraping routine:
#' 1) find the project number if not provided, 2) download
#' the HTML table, 3) parse the URL for each file, and 4) combine the table and
#' URLs into a data frame. This function is most useful when investigating what
#' files you have available, and then downloading them with \code{\link{get_file}}.
#'
#' \code{list_project_files} lists tag and receiver metadata files that have been
#' uploaded by the user. These are the files listed on the *Project Files* section
#' of your project page.
#'
#' @param project Either the project number (the number in your project page URL)
#'     or the full name of the project (the big name in bold on your project page,
#'     *not* the "Project Title").
#' @param since Only list files uploaded after this date. Optional, but must be
#'      in YYYY-MM-DD format.
#'
#' @return A data frame with columns of "project", "file_type", "upload_date", and "file_name".
#'
#' @export
#' @examples
#' \dontrun{
#' # List files using project number:
#' list_project_files(87)
#'
#' # Or using the project name
#' list_project_files('umces boem offshore wind energy')
#' }

list_project_files <- function(project = NULL, since = NULL){

  # Convert project name to number
  if(is.character(project)){
    project <- get_project_number(project)
  }

  # Scrape table and list files
  # This calls login_check() under the hood
  files_html <- get_file_list(project, data_type = 'downloadfiles')

  files <- html_table_to_df(files_html)


  if(!is.null(since)){
    files <- files[files$upload_date >= since, ]
  }

  files
}
