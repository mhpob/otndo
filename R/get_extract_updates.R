#' Download all data extraction files that were updated after a certain date
#'
#' This is a loop around \code{\link{get_file}}.
#'
#' @param ... arguments to \code{\link{list_extract_files}}
#' @param since Only list download files uploaded after this date. Must be in
#'      YYYY-MM-DD format. Also passed to \code{\link{list_extract_files}}.
#' @param out_dir Character. What directory/folder do you want the file saved into?
#'      Default is the current working directory. Passed to \code{httr::write_disk}
#'      via \code{\link{get_file}}.
#' @param overwrite Logical. Do you want a file with the same name overwritten?
#'      Passed to \code{httr::write_disk} via \code{\link{get_file}}.
#'
#' @export
get_extract_updates <- function(..., out_dir = getwd(), overwrite = F, to_vue = F){

  files <- list_extract_files(...)

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
