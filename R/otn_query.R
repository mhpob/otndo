#' Query the OTN Geoserver
#'
#' @param projects Character vector of OTN project codes for which you'd
#'  like project metadata. Prepended networks can be provided, but are not necessary.
#'
#' @examples
#' otn_query(c("EST", "FACT.SCDNRDFP", "ACT.MDBSB", "MDBSB"))
#'
#' @returns list of the "otn_resources_metadata_points" and "project_metadata"
#'   for the given projects
#'
#' @export
otn_query <- function(projects) {
  collectioncode <- NULL


  table_name <- c(
    "otn_resources_metadata_points",
    "project_metadata"
  )


  otn_metadata_query <- paste0(
    "https://members.oceantrack.org/geoserver/otn/ows?",
    "service=WFS&version=1.0.0&request=GetFeature&typeName=otn:",
    table_name,
    "&outputFormat=csv&CQL_FILTER=strMatches(collectioncode,'",
    paste(
      paste0(
        ".*",
        gsub(".*\\.", "", projects)
      ),
      collapse = "|"
    ),
    "')=true"
  ) |>
    URLencode()


  otn_tables <- lapply(
    otn_metadata_query,
    data.table::fread,
    showProgress = FALSE
  )

  ## Previous code for trying to jive collection codes
  # otn_tables <- lapply(otn_tables,
  #                      function(.){
  #                        .[!grepl('\\.', collectioncode),
  #                          collectioncode := paste0('OTN.', collectioncode)]
  #                      }
  # )

  otn_tables <- lapply(
    otn_tables,
    function(.) {
      .[, collectioncode := gsub(".*\\.", "", collectioncode)]
    }
  )

  names(otn_tables) <- table_name

  otn_tables[]
}
