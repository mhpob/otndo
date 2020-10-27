#'
#' @export

get_file <- function(file = NULL, project = NULL, # let file be char (filename) or numeric(index); same with project (full name vs number)
                    url = NULL, data_type, ...){
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

    if(is.null(project_number) & is.null(project)){
      stop('Need a URL, project number, or project name.')
    }

    if(is.null(project_number)){
      project_number <- get_project_number()
    }



  }
}

