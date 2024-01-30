#'
project_match_summary <- function(matched, type = c('receiver', 'tag')){
  if(type == 'tag'){
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

  if(type == 'tag'){
    pis <- pis[, .(detectedby, PI, POC, PI_emails, POC_emails)]
    setnames(pis, 'detectedby', 'project_name')
  } else {
    pis <- pis[, .(trackercode, PI, POC, PI_emails, POC_emails)]
    setnames(pis, 'trackercode', 'project_name')
  }


  pis[]
}
