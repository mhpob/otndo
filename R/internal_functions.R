matos_login <- function(){
  login_response <- POST(
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

matos_projects <- function(){
  project_list <- GET(
    'https://matos.asascience.com/project'
  )

  projects_info <- content(project_list) %>%
    html_node('.project_list') %>%
    html_nodes('a')

  projects <- data.frame(
    name = tolower(html_text(projects_info, trim = T)),
    url = paste0('https://matos.asascience.com',
                 html_attr(projects_info, 'href'))
  )

  projects
}
