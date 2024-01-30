#'
#'
prep_match_table <- function(matched, pis, type = c('tag', 'receiver')){
  matched <- data.table::data.table(matched)

  if(type == 'tag'){
    mt <- merge(
      matched[, .(detections = .N), by = "detectedby"],
      unique(matched, by = c("tagname", "detectedby"))[, .(individuals = .N),
                                                       by = "detectedby"]
    )

    setnames(mt, 'detectedby', 'project_name')

  } else {
    mt <- merge(
      matched[, .(detections = .N), by = "trackercode"],
      unique(matched, by = "fieldnumber")[, .(individuals = .N),
                                          by = "trackercode"]
    )

    setnames(mt, 'detectedby', 'project_name')

  }

  mt <- merge(mt, pis)

  mt[, project_name := gsub(".*\\.", "", project_name)]

  mt <- merge(
    mt,
    otn_tables[[1]][,
                    .(resource_full_name,
                      project_name = collectioncode
                    )
    ]
  )


  mt[, ":="(network = gsub("\\..*", "", project_name),
            code = gsub(".*\\.", "", project_name),
            project_name = NULL,
            PI = fifelse(PI == "NA", "", PI),
            POC = fifelse(POC == "NA", "", POC))]

  mt <- mt[, .(
    PI, POC, resource_full_name, network, code,
    detections, individuals, PI_emails, POC_emails
  )]
  setnames(mt, c(
    "PI", "POC", "Project name", "Network", "Project code",
    "Detections", "Individuals", "PI_emails", "POC_emails"
  ))

  setorder(mt, -"Detections", -"Individuals")

  mt[]
}
