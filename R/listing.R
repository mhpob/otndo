#'
#' @export

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


#'
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
