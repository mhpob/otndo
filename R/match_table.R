#' Prepare the detection match summary data
#'
#' @param matched matched (transmitter) or qualified (receiver) OTN detections
#' @param pis A principal investigator table created by `project_contacts`
#' @param type Tag or receiver data? Takes values of "tag" and "receiver";
#'    defaults to "tag".
#' @param otn_tables A OTN GeoServer query created by `otn_query`.
#'
prep_match_table <- function(
    matched,
    pis,
    type = c("tag", "receiver"),
    otn_tables) {
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




#' Create a reactable table of matched detections
#' @inheritParams prep_match_table
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
