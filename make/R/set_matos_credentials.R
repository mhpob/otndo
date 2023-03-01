#' Install your MATOS username and password in your \code{.Renviron} File for repeated use
#'
#' @description This code was adapted from \href{\code{tidycensus::census_api_key}}{https://github.com/walkerke/tidycensus/blob/ddb33b5f72734a4ff14332bd55cbac4850688600/R/helpers.R}. Note that this saves your credentials in your .Renviron, meaning that anyone who is using your computer can theoretically access what your MATOS username and password are. So... use this carefully!
#'
#' @param overwrite Logical. Overwrite previously-stored MATOS credentials?
#'
#' @export
#' @examples
#' \dontrun{
#' set_matos_credentials()
#'
#' # Yup, that's it!
#' }

set_matos_credentials <- function(overwrite = FALSE){

  home <- Sys.getenv("HOME")
  renv_path <- file.path(home, ".Renviron")

  if(!file.exists(renv_path)){
    file.create(renv_path)
  }

  renv <- readLines(renv_path)

  if(any(grepl("MATOS", renv)) & overwrite == F){
    cli::cli_abort("Some MATOS credentials already exist. You can overwrite them with the argument overwrite=TRUE.")
  }

  username <- getPass::getPass('Username:', noblank = T)
  password <- getPass::getPass('Password:', noblank = T)

  username <- paste0("MATOS_USER='", username, "'")
  password <- paste0("MATOS_PASS='", password, "'")

  # Append API key to .Renviron file
  write(username, renv_path, sep = "\n", append = TRUE)
  write(password, renv_path, sep = "\n", append = TRUE)

  cli::cli_alert_info('Your MATOS credentials have been stored in your .Renviron and can be accessed by Sys.getenv("MATOS_USER") or Sys.getenv("MATOS_PASS"). \nTo use now, restart R or run `readRenviron("~/.Renviron")`')
}
