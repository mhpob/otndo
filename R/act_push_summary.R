act_push_summary <- function(matos_project,
                             qualified = NULL,
                             unqualified = NULL,
                             update_push_log = F#,
                             # deployment = NULL
                             ){

  # Create a temporary directory to store intermediate files
  td <- tempdir()

  # Project ----
  ##  Find project name
  if(is.numeric(matos_project)){
    matos_project <- get_project_name(matos_project)
  }

  ##  Check that project name exists as written
  if(length(get_project_number(matos_project)) == 0){
    stop('No project matching that name.')
  }

  if(any(is.null(qualified), is.null(unqualified))){
    cat('\nListing extraction files...')
    project_files <- list_files(matos_project, 'extraction', 'all')
    cat(' Done.\n')
  }

  # Qualified detections ----
  ##  Download qualified detections if not provided
  if(is.null(qualified)){
    cat('\nDownloading qualified detections...')

    qualified <- project_files[project_files$detection_type == 'qualified']
    qualified <- lapply(qualified$url,
                        function(.){
                          get_file(url = .)
                        }
    )

    qualified <- unlist(qualified)
    qualified <- grep('\\.csv$', qualified, value = T)

    cat(' Done.\n')
  }

  ##  Bind files together
  qualified <- lapply(qualified, read.csv)
  qualified <- do.call(rbind, qualified)

  ##  Write file to temporary directory
  qualified_filepath <- file.path(td, 'qualified.csv')
  write.csv(qualified, qualified_filepath,
            row.names = F)



  # Unqualified detections ----
  ##  Download unqualified detections if not provided
  if(is.null(unqualified)){
    cat('\nDownloading unqualified detections...')

    unqualified <- project_files[project_files$detection_type == 'unqualified',]
    unqualified <- lapply(unqualified$url,
                        function(.){
                          get_file(url = .)
                        }
    )

    unqualified <- unlist(unqualified)
    unqualified <- grep('\\.csv$', unqualified, value = T)

    cat(' Done.\n')
  }

  ##  Bind files together
  unqualified <- lapply(unqualified, read.csv)
  unqualified <- do.call(rbind, unqualified)

  ##  Write file to temporary directory
  unqualified_filepath <- file.path(td, 'unqualified.csv')
  write.csv(unqualified, unqualified_filepath,
            row.names = F)



  # Push log ----
  if(update_push_log == TRUE){
    push_log <- 'https://raw.githubusercontent.com/mhpob/matos/push-summary/inst/push_log.csv'
  }else{
    push_log <- system.file("push_log.csv",
                            package="matos")
  }


  cat('\nWriting report...')

  quarto::quarto_render(
    input = 'inst/qmd_template/act-push-summary.qmd',
    # input = 'inst/qmd_template/test.qmd',
    execute_params = list(
      matos_project = matos_project,
      qualified = qualified_filepath,
      unqualified = unqualified_filepath,
      push_log = push_log
    ))

  cat('Done.\n')

  unlink(td)
}


# matos_project <- 192
# qualified <- c('proj192_qualified_detections_2021.csv',
#                'proj192_qualified_detections_2022.csv')
# unqualified <- c('proj192_unqualified_detections_2021.csv',
#                'proj192_unqualified_detections_2022.csv')
# act_push_summary(matos_project,
#                  qualified,
#                  unqualified)
