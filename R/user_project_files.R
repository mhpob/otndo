#'
#'

project_files <- function(project_number = NULL, project = NULL){
  if(is.null(project_number)){
    projects <- matos_projects()
    project_number <- sub('.*detail/', '',
                          projects[projects$name == tolower(project),]$url)
  }

  files_html <- httr::GET(
    paste0('https://matos.asascience.com/project/downloadfiles/',
           project_number)
  )

  file_urls <- httr::content(files_html, 'parsed') %>%
    rvest::html_node('body') %>%
    rvest::html_nodes('a') %>%
    rvest::html_attr('href') %>%
    grep('projectfile', ., value = T)

  files <- httr::content(files_html, 'parsed') %>%
    rvest::html_nodes('.tableContent') %>%
    rvest::html_table() %>%
    .[[1]] %>%
    .[, -4] %>%
    cbind(url = paste0('https://matos.asascience.com', file_urls))

  files
}

#'
#'
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


