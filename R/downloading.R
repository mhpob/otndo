#' Download files from the MATOS website
#'
#' \code{get_file} downloads files from the MATOS website. This is best-used in
#' conjunction with \code{\link{list_files}}.
#'
#' @param file A character vector listing the name of the file, or a numeric listing
#'     the index as found from \code{list_files}.
#' @param project A character vector listing the full name of the project, or a
#'     numeric listing the project number.
#' @param data_type one of NA (default), "extraction", or "project"; used in a
#'     call to \code{list_files} under the hood. If NA, it will try to guess whether
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

      cat('\nFile unzipped to', file_loc)
    }

    if(isTRUE(to_vue)){
      file_csv <- grep('.csv', file_loc, value = T)
      matos <- read.csv(
        file_csv
      )


      matos$transmitter.name <- ''
      matos$transmitter.serial <- ''

      matos <- matos[, c('datecollected', 'receiver', 'tagname', 'transmitter.name',
                         'transmitter.serial', 'sensorvalue', 'sensorunit', 'station',
                         'latitude', 'longitude')]

      write.csv(matos, file_csv, row.names = F)
      cat('\nCSV converted to VUE format.')

    }

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



#' Download all data extraction files that were updated after a certain date
#'
#' This is a loop around \code{\link{get_file}}.
#'
#' @param ... arguments to \code{\link{list_files}}
#' @param since Only list download files uploaded after this date. Must be in
#'      YYYY-MM-DD format. Also passed to \code{\link{list_files}}.
#' @param out_dir Character. What directory/folder do you want the file saved into?
#'      Default is the current working directory. Passed to \code{httr::write_disk}
#'      via \code{\link{get_file}}.
#' @param overwrite Logical. Do you want a file with the same name overwritten?
#'      Passed to \code{httr::write_disk} via \code{\link{get_file}}.
#'
#' @export
get_updates <- function(..., out_dir = getwd(), overwrite = F, to_vue = F){

  files <- list_files(...)

  if(nrow(files) == 0){

    print('No files uploaded since the provided date.')

  } else{
    pb <- txtProgressBar(min = 0, max = length(files$url), style = 3)
    for(i in seq_along(files$url)){
      cat('\n')

      get_file(url = files$url[i],
               out_dir = out_dir, overwrite = overwrite, to_vue = to_vue)

      cat('\n')

      setTxtProgressBar(pb, i)
    }
    close(pb)
  }

}




#' Download Ocean-Tracking-Network-style metadata templates
#'
#' @param template_type Character string. One of: "tag" (default), the tagging
#'      data submittal template; "receiver", the deployment data submittal template;
#'      or "glider", the wave and Slocum glider metadata template.
#' @param dest_file Optional character string noting where you would like the file
#'      to be downloaded. Defaults to the working directory and the original file name.
#'
#' @return Ocean Tracking Network metadata template in XLSX format.
#'
#' @export
#' @examples
#' \dontrun{
#' # Tag metadata template downloaded to working directory
#' get_otn_template()
#'
#' # Glider metadata template downloaded to downloads folder
#' get_otn_template('glider', 'c:/users/myusername/downloads/glider_metadata.xlsx')
#' }
get_otn_template <- function(template_type = c('tag', 'receiver', 'glider'),
                             dest_file = NULL){

  # Check that arguments are correct
  template_type <- match.arg(template_type)

  # Check that user is logged in
  login_check()

  # Convert template type to filename (as of 2020-11-02)
  template_file <- switch(template_type,
                          tag = 'otn_metadata_deployment.xlsx',
                          receiver = 'otn_metadata_tagging.xlsx',
                          glider = 'glider-deployment-metadata-v2.xlsx')


  # Download the file
  download.file(paste('https://matos.asascience.com/static', template_file, sep = '/'),
                destfile = ifelse(is.null(dest_file), template_file, dest_file),
                mode = 'wb')
}



#' Search for tags on the MATOS website
#'
#' This function is an interface to \href{https://matos.asascience.com/search}{MATOS' tag search page},
#' with the result of a CSV downloaded into your working directory. Be aware: these
#' downloads can take a *long* time, especially if you have many tags or are
#' searching over a long period of time.
#'
#' @param tags Character vector of tags. Will be coerced into CSV when POSTing to
#'     the website.
#' @param start_date Character string listing the start date in MM/DD/YYYY format.
#'     If no dates are provided, all tag detections are returned.
#' @param end_date Character string listing the end date in MM/DD/YYYY format.
#'     If no dates are provided, all tag detections are returned.
#' @param import Should the downloaded data be imported into R as a data frame? Default is FALSE.
#'
#' @export
#' @examples
#' \dontrun{
#' tag_search(tags = paste0('A69-1601-254', seq(60, 90, 1)),
#'            start_date = '03/01/2016',
#'            end_date = '04/01/2016')
#' }

tag_search <- function(tags, start_date, end_date, import = F){

  # Time of query (used to match MATOS naming convention)
  time_of_query <- as.POSIXlt(Sys.time())

  cat('Downloading data. Please note that this can take a while!\n')

  search <- httr::POST(
    'https://matos.asascience.com/search/searchtags',
    body = list(
      startDate = start_date,
      endDate = end_date,
      tagSearch = paste(tags, collapse = ',')
    ),
    httr::write_disk(paste('MATOS_Export',
                           time_of_query$year + 1900,
                           time_of_query$mon + 1,
                           time_of_query$mday,
                           time_of_query$hour,
                           paste0(time_of_query$min, '.csv'),
                           sep = "_"))
  )

  cat('Download complete. File saved to', file.path(search$content))

  if(import == T){
    cat('\nReading file into R...')

    read.csv(file.path(search$content))

    cat('\nCompleted!')
  }
}
