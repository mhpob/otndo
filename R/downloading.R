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
#' @param data_type one of "detection" or "project". Will call \code{detection_files} or
#' \code{project_files}, respectively.
#' @param ... Arguments passed to httr::write_disk.
#'
#' @export

get_file <- function(file = NULL, project = NULL, url = NULL, data_type, ...){

  # This function will do the downloading once we have a URL.
  download_process <- function(url){
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
  }

# If calling the URL directly:
  if(!is.null(url)){

    download_process(url = url)

  } else{

# If providing a project name or number and a file/index instead of the URL:

    if(is.null(file) | is.null(project)){
      stop('Need a file name and its project name or number.')
    }

    if(is.character(project)){
      project <- get_project_number(project)
    }

    file_html <- get_file_list(project, 'downloadfiles')

    file_table <- html_table_to_df(file_html)

    if(is.numeric(file)){
      # Check that index exists in the table.
      if(file == 0 | file > nrow(file_table)){
        stop(paste0('There is no index matching what you have provided. ',
                   'Try a file name or number from 1 to ',
                   nrow(file_table), '.'))
      }

      file_url <- paste0('https://matos.asascience.com', file_table[file,]$url)

      download_process(url = file_url)

    } else{
      # Protect against issues dealing with case
      file <- tolower(file)

      # Check that file exists in the table.
      if(!file %in% file_table$File.Name){
        stop(paste0('There is no file matching what you have provided, please ',
                    'double-check your file name.'))
      }

      file_url <- paste0('https://matos.asascience.com',
                         file_table[file_table$File.Name == file,]$url)

      download_process(url = file_url)
    }

  }
}

