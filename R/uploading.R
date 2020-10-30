#' Upload files to MATOS
#'
#' This function lets you post files to your projects. You will need to log in
#' before uploading.
#'
#' \code{post_file} takes a project name or number, the file you want to upload,
#' and the type of file you want to upload (defaulting to VRL transmitter detections).
#'
#' @param project The name (character) or number (numeric) of the project to which
#'     you wish post your file.
#' @param file The file(s) you wish to upload. If the file is located in your working
#'     directory, this can be just the filename and extension. You will need to
#'     provide the full file location if it is located elsewhere.
#' @param data_type Character string. The data type that you are uploading. One of:
#'     "new_tags" (default), "receivers", "detections", or "events".
#'
#' @details
#'     If data_type is "new_tags" or "receivers", only CSV and XLS/XLSX files are accepted;
#'     if "detections", only VRL and CSV files are accepted; if "events", only CSV is
#'     accepted.
#'
#'     Multiple files can be uploaded at once, but they must all be the same data type
#'     and posted to the same project.
#'
#' @export
#' @examples
#' \dontrun{
#' # Newly tagged fish, the default
#' post_file(87, 'your_tagged_fish.xls')
#' post_file(87, 'your_tagged_fish.xls', 'new_tags')
#'
#' # Transmitter detections
#' post_file('umces boem offshore wind energy', 'c:/wherever/your_CSV_detections.csv',
#'      'detections')
#' post_file('umces boem offshore wind energy', 'c:/wherever/your_VRL_detections.vrl',
#'      'detections')
#'
#' # Receiver metadata
#' post_file('umces boem offshore wind energy', 'your_receiver_metadata.xlsx', 'receivers')
#' }

post_file <- function(project, file,
                      data_type = c('new_tags', 'receivers', 'detections', 'events')){
  # CHECKS
  ## Check that only one project and/or data_type are provided
  if(length(project) > 1 | length(data_type) > 1){
    stop('Only able to upload one type of data to one project at a time.')
  }

  ## Check that file exists
  file <- normalizePath(file, mustWork = F)

  if(any(sapply(file, file.exists) == F)){

    stop(paste0('Unable to find:\n\n',
               paste(file[sapply(file, file.exists) == F],
                     collapse = '\n')))

  }

  ## Check and repair data_type argument
  data_type <- match.arg(data_type)

  ### Distinguish between VRL and CSV detections if necessary
  file_extension <- tolower(tools::file_ext(file))

  if(data_type == 'detections'){

    data_type <- paste(file_extension, data_type, sep = '_')

  }

  ## Check that file extensions match the expected file type.
  if(data_type %in% c('receivers', 'new_tags') &&
     any(grepl('xls|csv', file_extension) == F)){

    stop(paste0('File is not saved as the correct type: should be CSV, XLS, or XLSX. Namely:\n\n',
               paste(file[!grepl('xls|csv', file_extension)],
                     collapse = '\n')))

  } else if(grepl('detections', data_type) &&
            any(grepl('vrl|csv', file_extension) == F)){

    stop(paste0('File is not the correct type: should be VRL or CSV. Namely:\n\n',
               paste(file[!grepl('vrl|csv', file_extension)],
                     collapse = '\n')))

  } else if(data_type == 'events' &&
            any(file_extension != 'csv')){

    stop(paste0('File is not saved as the correct type: should be CSV. Namely:\n\n',
                paste(file[file_extension != 'csv'],
                      collapse = '\n')))

  }

  # Convert project name to project number, if needed
  if(is.character(project)){
    project <- get_project_number(project)
  }

  # Log in.
  login_check()

  # Construct body of POST
  ## Function to construct body
  construct_body <- function(file, project, data_num){
    # List files to be uploaded
    post_files <- lapply(file, httr::upload_file)
    names(post_files) <- rep('file', times = length(post_files))

    # Combine with project and data_num to create full body
    c(list(pid = project,
           df = data_num),
      post_files)
  }

  ## Convert data_type to the expected input numbers
  data_num <- sapply(data_type, function(x){
    switch(x,
           new_tags = 1,
           receivers = 2,
           csv_detections = 3,
           events = 4,
           vrl_detections = 5
    )
  },
  USE.NAMES = F)

  ## Construct body
  if(length(unique(data_num)) == 1){

    post_body <- construct_body(file, project, unique(data_num))
    post_body <- list(post_body)

  } else{

    # Split by file extension if trying to upload a mix of VRL and CSV detection files
    post_body <- split(data.frame(file, data_num), file_extension)
    names(post_body) <- NULL

    post_body <- lapply(post_body,
                        function(x){
                          construct_body(x$file, project, unique(x$data_num))
                        }
    )

  }





  # Upload.
  cat('Uploading...\n')

  # It seems that you need to ping the server with your credentials before it
  # will let you POST.
  invisible(
    httr::HEAD('https://matos.asascience.com/report/submit')
  )

  response <- lapply(post_body, function(x){
    httr::POST(
    'https://matos.asascience.com/report/uploadReport',
    body = x,
    encode = 'multipart'
    )
  })

  # Check if upload was successful
  response_content <- lapply(response, httr::content)

  if(all(lapply(response_content, length) == 0)){

    cat('Upload successful!\n')

  } else if(
    any(
      grepl('^Error',
            sapply(response_content,
                   function(.) tryCatch(
                     rvest::html_text(., trim = T),
                     error = function(e) ''
                   )
            )
      )
    )
  ){

    warning(
      sapply(response_content, function(.) tryCatch(
        rvest::html_text(., trim = T),
        error = function(e) ''
      )
      )
    )

  } else{

    stop('Unidentified error. Please file an issue at
         https://github.com/mhpob/matos/issues.')

  }

}
