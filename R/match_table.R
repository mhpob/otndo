#' Create a reactable table of matched detections
#'
#' @param matched matched (transmitter) or qualified (receiver) OTN detections
#' @param pis A principal investigator table created by `project_contacts`
#' @param type Tag or receiver data? Takes values of "tag" and "receiver";
#'    defaults to "tag".
#' @param otn_tables A OTN GeoServer query created by [otn_query()]
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
#' contacts <- project_contacts(qualified_dets, "receiver")
#' otn <- otn_query(unique(qualified_dets$trackercode))
#'
#' match_table(
#'   matched = qualified_dets,
#'   pis = contacts,
#'   type = "receiver",
#'   otn_tables = otn
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
#'   matched = matched_dets,
#'   pis = project_contacts(matched_dets, "tag"),
#'   type = "tag",
#'   otn_tables = otn_query(unique(matched_dets$detectedby))
#' )
#' }
#'
#' @export
match_table <- function(
    matched,
    pis,
    type = c("tag", "receiver"),
    otn_tables) {
  mt_data <- prep_match_table(matched, pis, type, otn_tables)

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
    matched,
    pis,
    type = c("tag", "receiver"),
    otn_tables) {
  . <- collectioncode <- project_name <- resource_full_name <- PI <- POC <-
    network <- code <- detections <- individuals <- PI_emails <- POC_emails <-
    station <- Station <- Detections <- Individuals <- longitude <- latitude <-
    detectedby <- NULL

  matched <- data.table::data.table(matched)

  if (type == "tag") {
    mt <- merge(
      matched[, .(detections = .N), by = "detectedby"],
      unique(matched, by = c("tagname", "detectedby"))[
        , .(individuals = .N),
        by = "detectedby"
      ]
    )

    data.table::setnames(mt, "detectedby", "project_name")
  } else {
    mt <- merge(
      matched[, .(detections = .N), by = "trackercode"],
      unique(matched, by = "fieldnumber")[, .(individuals = .N),
        by = "trackercode"
      ]
    )

    data.table::setnames(mt, "trackercode", "project_name")
  }

  mt <- merge(mt, pis)

  mt[, collectioncode := gsub(".*\\.", "", project_name)]

  mt <- merge(
    mt,
    otn_tables[[1]][
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
