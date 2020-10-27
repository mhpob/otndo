project_files <- function(project_number = NULL, project = NULL){
  if(is.null(project_number)){
    projects <- matos_projects()
    project_number <- sub('.*detail/', '', projects[projects$name == tolower(project),]$url)
  }

  files_html <- GET(
    paste0('https://matos.asascience.com/project/downloadfiles/',
           project_number)
  )

  file_urls <- content(files_html, 'parsed') %>%
    html_node('body') %>%
    html_nodes('a') %>%
    html_attr('href') %>%
    grep('projectfile', ., value = T)

  files <- content(files_html, 'parsed') %>%
    html_nodes('.tableContent') %>%
    html_table() %>%
    .[[1]] %>%
    .[, -4] %>%
    cbind(url = paste0('https://matos.asascience.com', file_urls))

  files
}

get_project_file <- function(file = NULL, project_number = NULL, project = NULL,
                             index = NULL, url = NULL, ...){
  if(!is.null(url)){
    GET_header <- GET(url)

    response <-  GET(
      url,
      write_disk(..., sub('.*filename=', '', headers(GET_header)$'content-disposition'))
    )

    cat('File saved to', file.path(response$content))

  } else{

    if(is.null(project_number)){
      projects <- matos_projects()
      project_number <- sub('.*detail/', '', projects[projects$name == tolower(project),]$url)
    }


  }




}


