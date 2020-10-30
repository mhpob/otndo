#'
#'
#' @export
post_file <- function(project, file,
                      file_type = c('receivers', 'new_tags', 'events',
                                    'csv_detections', 'vrl_detections')){

  # Check that file exists
  file <- normalizePath(file, mustWork = F)

  if(!file.exists(file)){

    stop(paste('Unable to find', file))

  }

  # Check and repair file_type argument
  file_type <- match.arg(file_type)

  # Check that file extensions match the expected file type.
  if(file_type %in% c('receivers', 'new_tags') &&
     !grepl('xls|csv', tools::file_ext(file), ignore.case = T)){

    stop('File is not saved as the correct type: should be CSV, XLS, or XLSX.')

  } else if(file_type %in% c('events', 'csv_detections') &&
            tolower(tools::file_ext(file)) != 'csv'){

    stop('File is not saved as the correct type: should be CSV.')

  } else if(file_type == 'vrl_detections' &&
            tolower(tools::file_ext(file)) != 'vrl'){

    stop('File is not the correct type: should be VRL.')

  }

  # Convert file_type to the expected input numbers
  file_num <- switch(file_type,
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
      df = file_num,
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
