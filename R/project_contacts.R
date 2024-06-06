#' Extract and combine the contacts for matched projects
#'
#' @param matched data.frame of transmitter/receiver detections matched by OTN:
#'  matched detections for tags and qualified detections for receivers
#' @param type Type of extract data: "tag" or "receiver"
#'
#' @examples
#' \dontrun{
#' # Set up example data
#' td <- file.path(tempdir(), "otndo_example")
#' dir.create(td)
#'
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
#' matched <- read.csv(file.path(
#'   td,
#'   "pbsm_matched_detections_2018.csv"
#' ))
#'
#' # Actually run the function
#' project_contacts(matched, type = "tag")
#'
#' # Clean up
#' unlink(td, recursive = TRUE)
#' }
#'
#' @returns a data.table containing project names, principal investigators (PI),
#'   points of contact (POC), and their respective emails. Multiple emails are
#'   separated by commas.
#'
#' @export
project_contacts <- function(matched, type = c("receiver", "tag")) {
  matched <- data.table::data.table(matched)

  if (type == "tag") {
    pis <- unique(matched, by = c("detectedby", "contact_poc", "contact_pi"))
    pis[, ":="(
      PI = strsplit(contact_pi, " \\(|\\)(, )?"),
      POC = strsplit(contact_poc, " \\(|\\)(, )?")
    )]
  } else {
    pis <- unique(qualified, by = c("trackercode"))
    pis[, ":="(
      PI = strsplit(tag_contact_pi, " \\(|\\)(, )?"),
      POC = strsplit(tag_contact_poc, " \\(|\\)(, )?")
    )]
  }


  pis[, ":="(
    PI = lapply(X = PI, function(.) .[!grepl("@", .)]),
    POC = lapply(X = POC, function(.) .[!grepl("@", .)]),
    PI_emails = lapply(X = PI, function(.) .[grepl("@", .)]),
    POC_emails = lapply(X = POC, function(.) .[grepl("@", .)])
  )]


  if (type == "tag") {
    if (nrow(pis) > data.table::uniqueN(pis, by = "detectedby")) {
      # create key with merged names/emails (seemingly can't change by reference)
      pi_key <- pis[, .(
        PI = list(unique(unlist(PI))),
        POC = list(unique(unlist(POC))),
        PI_emails = list(unique(unlist(PI_emails))),
        POC_emails = list(unique(unlist(POC_emails)))
      ),
      by = "detectedby"
      ]
      pis <- merge(pis[, -c("PI", "POC", "PI_emails", "POC_emails")],
                   pi_key,
                   on = "detectedby"
      )
      pis <- unique(pis, by = "detectedby")
      # maybe need to also merge their geom?
    }
  } else {
    if (nrow(pis) > data.table::uniqueN(pis, by = "trackercode")) {
      pi_key <- pis[, .(
        PI = list(unique(unlist(PI))),
        POC = list(unique(unlist(POC))),
        PI_emails = list(unique(unlist(PI_emails))),
        POC_emails = list(unique(unlist(POC_emails)))
      ),
      by = "trackercode"
      ]
      pis <- merge(pis[, -c("PI", "POC", "PI_emails", "POC_emails")],
                   pi_key,
                   on = "trackercode"
      )
      pis <- unique(pis, by = "trackercode")
    }
  }

  pis[, ":="(PI = unlist(
    lapply(
      X = PI,
      function(.) paste(., collapse = ", ")
    )
  ),
  POC = unlist(
    lapply(
      X = POC,
      function(.) paste(., collapse = ", ")
    )
  ),
  emails = t(
    mapply(
      c,
      PI_emails, POC_emails,
      # Need simplify=F arg to mapply in case no rows have
      # multiple emails in a column: simplify=T
      # will "simplify" to a matrix rather than keep as a list
      SIMPLIFY = FALSE
    )
  ))] |>
    suppressWarnings()

  pis[, ":="(emails = unlist(
    lapply(
      lapply(
        emails,
        unique
      ),
      paste,
      collapse = "\n"
    )
  ),
  PI_emails = unlist(
    lapply(
      lapply(
        PI_emails,
        unique
      ),
      paste,
      collapse = ","
    )
  ),
  POC_emails = unlist(
    lapply(
      lapply(
        POC_emails,
        unique
      ),
      paste,
      collapse = ","
    )
  ))]

  if (type == "tag") {
    pis <- pis[, .(detectedby, PI, POC, PI_emails, POC_emails)]
    data.table::setnames(pis, "detectedby", "project_name")
  } else {
    pis <- pis[, .(trackercode, PI, POC, PI_emails, POC_emails)]
    data.table::setnames(pis, "trackercode", "project_name")
  }


  pis[]
}
