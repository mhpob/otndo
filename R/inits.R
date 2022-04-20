.onAttach <- function(libname, pkgname) {
  packageStartupMessage(paste(
  "By continuing, you are agreeing to the ACT Network MATOS User Agreement and Data Policy, Version 1.2:",
  "https://matos.asascience.com/static/MATOS.User.Agreement.V1.1.pdf", sep = '\n\n'))
}
