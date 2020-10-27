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

get_project_file <- function(file = NULL, project_number = NULL, project = NULL,
                             index = NULL, url = NULL, ...){
  if(!is.null(url)){
    GET_header <- httr::GET(url)

    response <-  httr::GET(
      url,
      httr::write_disk(...,
                       sub('.*filename=', '',
                           httr::headers(GET_header)$'content-disposition'))
    )

    cat('File saved to', file.path(response$content))

  } else{

    if(is.null(project_number)){
      projects <- matos_projects()
      project_number <- sub('.*detail/', '',
                            projects[projects$name == tolower(project),]$url)
    }


  }




}


