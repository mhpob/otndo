#' Download files from the MATOS website
#'
#' \code{get_file} downloads files from the MATOS website. This is best-used in
#' conjunction with \code{\link{detection_files}} or \code{\link{project_files}}.
#'
#' @param file A character vector listing the name of the file, or a numeric listing
#' the index as found from \code{detection_files} or \code{project_files}.
#' @param project A character vector listing the full name of the project, or a
#' numeric listing the project number.
#' @param url The URL of the file to be downloaded.
#' @param data_type FILL THIS IN!!!
#' @param ... Arguments passed to httr::write_disk.
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

