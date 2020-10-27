#'
#' @export
matos_login <- function(){
  login_response <- httr::POST(
    'https://matos.asascience.com/account/login',
    body = list(
      UserName = rstudioapi::showPrompt(
        title = "Username", message = "Please enter username.", default = ""),
      Password = rstudioapi::askForPassword('Please enter password.')
    )
  )

  if(grepl('login', login_response)){
    rstudioapi::showDialog('Login unsuccessful :(',
                           'Your username/password combination was not recognized. Re-run matos_login before continuing.')
  } else{
    rstudioapi::showDialog('Login successful!',
                           'You are now logged into your MATOS profile.')
  }

}

#'
#' @export
matos_projects <- function(){
  project_list <- httr::GET(
    'https://matos.asascience.com/project'
  )

  projects_info <- httr::content(project_list) %>%
    rvest::html_node('.project_list') %>%
    rvest::html_nodes('a')

  projects <- data.frame(
    name = tolower(rvest::html_text(projects_info, trim = T)),
    url = paste0('https://matos.asascience.com',
                 rvest::html_attr(projects_info, 'href'))
  )

  projects
}

