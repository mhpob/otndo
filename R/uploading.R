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
#' @param file The file you wish to upload. If the file is located in your working
#'     directory, this can be just the filename and extension. You will need to
#'     provide the full file location if it is located elsewhere.
#' @param data_type Character string. The data type that you are uploading. One of:
#'     "new_tags" (default), "receivers", "vrl_detections", "csv_detections",
#'     or "events".
#'
#' @details
#'     If data_type is "new_tags" or "receivers", CSV and XLS/XLSX files are accepted;
#'     if "detections", only VRL and CSV files are accepted; if "events", only CSV is
#'     accepted.
#'
#' @export
#' @examples
#' \dontrun{
#' # Tag detections, the default
#' post_file(87, 'your_VRL_file.vrl')
#' post_file('umces boem offshore wind energy', 'c:/wherever/your_CSV_detections.csv')
#'
#' # Receiver metadata
#' post_file('umces boem offshore wind energy', 'your_receiver_metadata.xlsx', 'receivers')
#' }

post_file <- function(project, file,
                      data_type = c('new_tags', 'receivers', 'vrl_detections',
                                    'csv_detections', 'events')){

  # Check that file exists
  file <- normalizePath(file, mustWork = F)

  if(!file.exists(file)){

    stop(paste('Unable to find', file))

  }

  # Check and repair data_type argument
  data_type <- match.arg(data_type)

  # Check that file extensions match the expected file type.
  if(data_type %in% c('receivers', 'new_tags') &&
     !grepl('xls|csv', tools::file_ext(file), ignore.case = T)){

    stop('File is not saved as the correct type: should be CSV, XLS, or XLSX.')

  } else if(data_type %in% c('events', 'csv_detections') &&
            tolower(tools::file_ext(file)) != 'csv'){

    stop('File is not saved as the correct type: should be CSV.')

  } else if(file_type == 'vrl_detections' &&
            tolower(tools::file_ext(file)) != 'vrl'){

    stop('File is not the correct type: should be VRL.')

  }

  # Convert data_type to the expected input numbers
  data_num <- switch(data_type,
    new_tags = 1,
    receivers = 2,
    csv_detections = 3,
    events = 4,
    vrl_detections = 5
  )

  # Convert project name to project number, if needed
  if(is.character(project)){
    project <- get_project_number(project)
  }

  # Log in.
  login_check()


  # Upload.
  cat('Uploading...\n')

  # It seems that you need to ping the server with your credentials before it
  # will let you POST.
  invisible(
    httr::HEAD('https://matos.asascience.com/report/submit')
  )

  response <- httr::POST(
    'https://matos.asascience.com/report/uploadReport',
    body = list(
      pid = project,
      df = data_num,
      file = httr::upload_file(file)
    ),
    encode = 'multipart'
  )

  # Check if upload was successful
  response_content <- httr::content(response)

  if(length(response_content) == 0){

    cat('Upload successful!\n')

  } else if(grepl('^Error', rvest::html_text(response_content, trim = T))){

    stop(sub(' Error ', '', rvest::html_text(response_content)))

  } else{

    stop('Unidentified error. Please file an issue at
         https://github.com/mhpob/matos/issues.')

  }

}
