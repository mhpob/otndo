.onAttach <- function(libname, pkgname) {
  packageStartupMessage(
  cli::cli_text(
    "By continuing, you are agreeing to the ACT Network MATOS User Agreement and Data Policy, Version 1.2:\n\n",
  "{.url https://matos.asascience.com/static/MATOS.User.Agreement.V1.1.pdf}")
  )
}
