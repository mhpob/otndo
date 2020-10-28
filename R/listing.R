#' List MATOS project files
#'
#' These functions list the file names, types, upload date, and URLs of MATOS
#' project files -- basically everything you see in the *Data Extraction Files*
#' or *Project Files* sections of your project page. Because it is from your
#' project page, you **need to** first log in using \code{\link{matos_login}}.
#'
#' @section Details:
#' \code{detection_files} and \code{project_files} are wrappers around a
#' web-scraping routine: 1) find the project number if not provided, 2) download
#' the HTML table, 3) parse the URL for each file, and 4) combine the table and
#' URLs into a data frame. These functions are most useful when investigating what
#' files you have available, and then downloading them with \code{\link{get_file}}.
#'
#' \code{detection_files} lists files associated with the ACT_MATOS OTN node. These
#' are files listed on the *Data Extraction Files* page.
#'
#' \code{project_files} lists tag and receiver metadata files that have been
#' uploaded by the user. These are the files listed on the *Project Files* page.
#'
#' @param project Either the project number (the number in your project page URL)
#'      or the full name of the project (the big name in bold on your project page,
#'      *not* the "Project Title")
#' @return A data frame with columns of "File Name", "File Type", "Upload Date", and "url".
#'
#' @name list_files
#' @export
#' @examples
#' # Select using project number
#' detection_files(87)
#' project_files(87)
#'
#' # Select using project name
#' detection_files('umces boem offshore wind energy')

detection_files <- function(project_number = NULL, project = NULL){
  if(is.null(project_number)){
    project_number <- get_project_number(project)
  }

  files_html <- get_file_list(project_number, data_type = 'dataextractionfiles')

  file_urls <- scrape_file_urls(files_html)

  files <- html_table_to_df(files_html)

  files <- files %>%
    cbind(url = paste0('https://matos.asascience.com', file_urls))

  files

}



#' @rdname list_files
#' @export

project_files <- function(project_number = NULL, project = NULL){
  if(is.null(project_number)){
    project_number <- get_project_number(project)
  }

  files_html <- get_file_list(project_number, data_type = 'downloadfiles')

  file_urls <- scrape_file_urls(files_html)

  files <- html_table_to_df(files_html)

  files <- files %>%
    cbind(url = paste0('https://matos.asascience.com', file_urls))

  files
}

#'
#' @export
matos_projects <- function(){
  project_list <- httr::GET(
    'https://matos.asascience.com/project'
  )

  projects_info <- httr::content(project_list) %>%
    rvest::html_node('.project_list') %>%
    rvest::html_nodes('a')

  projects <- data.frame(
    name = tolower(rvest::html_text(projects_info, trim = T)),
    url = paste0('https://matos.asascience.com',
                 rvest::html_attr(projects_info, 'href'))
  )

  projects
}
