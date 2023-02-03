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
