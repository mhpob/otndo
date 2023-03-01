#' Search for tags on the MATOS website
#'
#' This function is an interface to
#' \href{https://matos.asascience.com/search}{MATOS' tag search page},
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
#' get_tag_search(tags = paste0('A69-1601-254', seq(60, 90, 1)),
#'            start_date = '03/01/2016',
#'            end_date = '04/01/2016')
#' }

get_tag_search <- function(tags, start_date, end_date, import = F){

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
