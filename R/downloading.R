#'
#' @export

get_file <- function(file = NULL, project_number = NULL, project = NULL,
                             index = NULL, url = NULL, ...){
  if(!is.null(url)){
    GET_header <- httr::GET(url)

    response <-  httr::GET(
      url,
      httr::write_disk(..., sub('.*filename=', '',
                                httr::headers(GET_header)$'content-disposition'))
    )

    cat('File saved to', file.path(response$content))

    if(grepl('zip', response$content)){
      unzip(file.path(response$content))

      cat('\nFile unzipped to', unzip(file.path(response$content), list = T)$Name)
    }

  } else{

    if(is.null(project_number)){
      projects <- matos_projects()
      project_number <- sub('.*detail/', '',
                            projects[projects$name == tolower(project),]$url)
    }
  }
}

