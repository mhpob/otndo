#' Create a reactable table of matched detections
#'
#' @param extract matched (transmitter) or qualified (receiver) OTN detections
#' @param type Tag or receiver data? Takes values of "tag" and "receiver";
#'    defaults to "tag".
#'
#' @examples
#' \dontrun{
#' # Receiver
#' download.file(
#'   paste0(
#'     "https://members.oceantrack.org/data/repository/pbsm/",
#'     "detection-extracts/pbsm_qualified_detections_2018.zip/",
#'     "@@download/file"
#'   ),
#'   destfile = file.path(td, "pbsm_qualified_detections_2018.zip"),
#'   mode = "wb"
#' )
#' unzip(
#'   file.path(td, "pbsm_qualified_detections_2018.zip"),
#'   exdir = td
#' )
#'
#' qualified_dets <- data.table::fread(
#'   file.path(td, "pbsm_qualified_detections_2018.csv")
#' )
#'
#' match_table(
#'   extract = qualified_dets,
#'   type = "receiver"
#' )
#'
#' # Transmitters
#' download.file(
#'   paste0(
#'     "https://members.oceantrack.org/data/repository/",
#'     "pbsm/detection-extracts/pbsm_matched_detections_2018.zip/",
#'     "@@download/file"
#'   ),
#'   destfile = file.path(td, "pbsm_matched_detections_2018.zip"),
#'   mode = "wb"
#' )
#' unzip(file.path(td, "pbsm_matched_detections_2018.zip"),
#'   exdir = td
#' )
#'
#' matched_dets <- data.table::fread(
#'   file.path(td, "pbsm_matched_detections_2018.csv")
#' )
#'
#' match_table(
#'   extract = matched_dets,
#'   type = "tag"
#' )
#' }
#'
#' @export
match_table <- function(
    extract,
    type = c("tag", "receiver")) {
  mt_data <- prep_match_table(extract, type)

  reactable::reactable(
    mt_data,
    columns = list(
      PI = reactable::colDef(
        html = T,
        cell = function(value, index) {
          sprintf(
            '<a href=mailto:%s target="_blank">%s</a>',
            mt_data$PI_emails[index], value
          )
        },
        minWidth = 150
      ),
      POC = reactable::colDef(
        html = T,
        cell = function(value, index) {
          sprintf(
            '<a href=mailto:%s target="_blank">%s</a>',
            mt_data$POC_emails[index], value
          )
        },
        minWidth = 150
      ),
      PI_emails = reactable::colDef(show = F),
      POC_emails = reactable::colDef(show = F),
      `Project name` = reactable::colDef(minWidth = 200)
    )
  )
}


#' Prepare the detection match summary data
#'
#' @inheritParams match_table
prep_match_table <- function(
    extract,
    type = c("tag", "receiver")) {
  . <- collectioncode <- project_name <- resource_full_name <- PI <- POC <-
    network <- code <- detections <- individuals <- PI_emails <- POC_emails <-
    station <- Station <- Detections <- Individuals <- longitude <- latitude <-
    detectedby <- NULL

  extract <- data.table::data.table(extract)

  if (type == "tag") {
    mt <- merge(
      extract[, .(detections = .N), by = "detectedby"],
      unique(extract, by = c("tagname", "detectedby"))[
        , .(individuals = .N),
        by = "detectedby"
      ]
    )

    data.table::setnames(mt, "detectedby", "project_name")

    otn <- otn_query(unique(extract$detectedby))
  } else {
    mt <- merge(
      extract[, .(detections = .N), by = "trackercode"],
      unique(extract, by = "fieldnumber")[, .(individuals = .N),
        by = "trackercode"
      ]
    )

    data.table::setnames(mt, "trackercode", "project_name")

    otn <- otn_query(unique(extract$trackercode))
  }

  pis <- project_contacts(extract, type = type)
  mt <- merge(mt, pis)

  mt[, collectioncode := gsub(".*\\.", "", project_name)]

  mt <- merge(
    mt,
    otn[[1]][
      ,
      .(
        resource_full_name,
        collectioncode
      )
    ],
    by = "collectioncode"
  )


  mt[, ":="(network = gsub("\\..*", "", project_name),
    code = gsub(".*\\.", "", project_name),
    project_name = NULL,
    PI = data.table::fifelse(PI == "NA", "", PI),
    POC = data.table::fifelse(POC == "NA", "", POC))]
  mt[, network := data.table::fifelse(network == code, "", network)]

  mt <- mt[, .(
    PI, POC, resource_full_name, network, code,
    detections, individuals, PI_emails, POC_emails
  )]
  data.table::setnames(mt, c(
    "PI", "POC", "Project name", "Network", "Project code",
    "Detections", "Individuals", "PI_emails", "POC_emails"
  ))

  data.table::setorder(mt, -"Detections", -"Individuals")

  mt[]
}
