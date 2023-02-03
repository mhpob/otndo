#' Download files from the MATOS website
#'
#' \code{get_file} downloads files from the MATOS website. This is best-used in
#' conjunction with \code{\link{list_extract_files}} or
#' \code{\link{list_project_files}}.
#'
#' @param file A character vector listing the name of the file, or a numeric listing
#'     the index as found from \code{\link{list_extract_files}} or
#'     \code{\link{list_project_files}}.
#' @param project A character vector listing the full name of the project, or a
#'     numeric listing the project number.
#' @param data_type one of NA (default), "extraction", or "project". If NA, it
#'     will try to guess whether
#'     project files or data extraction files are desired from the file name. If
#'     the file index is provided, it cannot guess and will throw an error. When
#'     "extraction" or "project" is provided, it will list the data extraction or
#'     project files, respectively. Partial matching is allowed, and will repair
#'     to the correct argument if spaces or the words "data"/"file(s)" are included.
#' @param url The URL of the file to be downloaded.
#' @param out_dir Character. What directory/folder do you want the file saved into?
#'      Default is the current working directory.
#' @param overwrite Logical. Do you want a file with the same name overwritten?
#'      Passed to httr::write_disk.
#' @param to_vue Logical. Convert to VUE export format?
#'
#' @export
#' @examples
#' \dontrun{
#' # If you know the direct URL to your file, you don't need the file or project names:
#' get_file(url = 'https://matos.asascience.com/projectfile/download/327')
#'
#' # If you know the file name and your project ID (name or number), provide both.
#' # This will guess that you want the data extraction file since the file name
#' # ends in .zip.
#' get_file(file = 'proj87_matched_detections_2017.zip',
#'         'UMCES BOEM Offshore Wind Energy')
#'
#' # This won't work, as it can't guess whether you want project or data extraction
#' #  files from the number "1".
#' get_file(1, 87)
#'
#' # Need to provide a value to \code{data_type}.
#' get_file(1, 87, data_type = 'extraction')
#' }

get_file <- function(file = NULL, project = NULL,
                     data_type = c(NA, 'extraction', 'project'),
                     url = NULL, out_dir = getwd(), overwrite = F, to_vue = F){

  # This function will do the downloading once we have a URL.
  download_process <- function(url){
    GET_header <- httr::GET(url)

    response <-  httr::GET(
      url,
      httr::write_disk(
        path = file.path(out_dir,
                         sub('.*filename=', '',
                             httr::headers(GET_header)$'content-disposition')),
        overwrite = overwrite)
    )

    file_loc <- file.path(response$content)
    cat('File saved to', file_loc)

    if(grepl('zip', file_loc)){
      file_loc <- unzip(file_loc, exdir = out_dir, setTimes = FALSE)

      cat('\nFile unzipped to', file_loc, '\n')
    }

    if(isTRUE(to_vue)){
      file_csv <- grep('.csv', file_loc, value = T)
      matos <- read.csv(
        file_csv
      )


      matos$transmitter.name <- ''
      matos$transmitter.serial <- ''

      matos <- matos[, c('datecollected', 'receiver', 'tagname', 'transmitter.name',
                         'transmitter.serial', 'sensorraw', 'sensorunit', 'station',
                         'latitude', 'longitude')]

      names(matos) <- c('Date and Time (UTC)', 'Receiver', 'Transmitter',
                        'Transmitter Name', 'Transmitter Serial', 'Sensor Value',
                        'Sensor Unit', 'Station Name', 'Latitude', 'Longitude')

      write.csv(matos, file_csv, row.names = F)
      cat('\nCSV converted to VUE format.')

    }

    file_loc
  }


  # If calling the URL directly:
  if(!is.null(url)){

    login_check(url)

    download_process(url = url)

  } else{

    # If providing a project name or number and a file/index instead of the URL:

    # Check and repair data_type names
    if(is.numeric(file) && is.na(data_type)){
      stop(paste('Unable to figure out from the file index alone whether you want',
                 'data extraction files or project files. Providing an argument to',
                 '"data_type = ..." might fix this.'))
    }
    if(is.character(file) && is.na(data_type)){
      data_type <- ifelse(grepl('*.zip$', file), 'extraction', 'project')
    }

    data_type <- gsub(' |file[s]?|data', '', data_type)
    data_type <- match.arg(data_type)
    data_type <- ifelse(data_type == 'extraction', 'dataextractionfiles',
                        'downloadfiles')

    # Check that both file and project are provided
    if(is.null(file) | is.null(project)){
      stop('Need a file name/index and its project name/number.')
    }



    if(is.character(project)){
      project <- get_project_number(project)
    }

    # As well as getting the file list, this will call login_check() to check credentials
    file_html <- get_file_list(project, data_type)

    file_table <- html_table_to_df(file_html)

    if(is.numeric(file)){
      # Check that index exists in the table.
      if(file == 0 | file > nrow(file_table)){
        stop(paste0('There is no index matching what you have provided. ',
                    'Try a file name or index from 1 to ',
                    nrow(file_table), '.'))
      }

      file_url <- file_table[file,]$url

      download_process(url = file_url)

    } else{
      # Protect against issues dealing with case
      file <- tolower(file)

      # Check that file exists in the table.
      if(!file %in% file_table$file_name){
        stop(paste0('There is no file matching what you have provided, please ',
                    'double-check your file name.'))
      }

      file_url <- file_table[file_table$file_name == file,]$url

      download_process(url = file_url)
    }

  }
}
