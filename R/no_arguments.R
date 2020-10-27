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



