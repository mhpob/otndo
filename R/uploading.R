#'
#'
#' @export
post_file <- function(project, file,
                      file_type = c('receivers', 'new_tags', 'events',
                                    'csv_detections', 'vrl_detections')){

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
  httr::POST(
    'https://matos.asascience.com/report/uploadReport',
    body = list(
      pid = project,
      df = file_num,
      file = httr::upload_file(normalizePath(file))
    ),
    encode = 'multipart'
  )

  #Need to return error if it was already uploaded, and maybe a nice note if the upload was complete

}
