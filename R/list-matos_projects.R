#' List MATOS projects
#'
#' By default, this function scrapes the table found at \url{https://matos.asascience.com/project}.
#' This table provides not only the full name of the project, but also the MATOS
#' project number and project page URL. You do not need to log in via \code{matos_login}
#' or have any permissions to view/download this table.
#'
#' @param what What list of projects do you want returned: all projects ("all",
#'      default) or your projects ("mine")?
#' @param read_access If listing your projects, do you want to only list projects
#'      for which you have file-read permission? Defaults to TRUE, though there
#'      is significant speed up if switched to FALSE.
#'
#'
#' @export
#' @examples
#' \dontrun{
#' # List all projects, the default:
#' matos_projects()
#'
#' # List your projects (which may contain some for which you do not have read access):
#' matos_projects('mine', read_access = F)
#' }
matos_projects <- function(what = c('all', 'mine'), read_access = T){

  what <- match.arg(what)

  if(what == 'all'){

    project_list <- httr::GET(
      'https://matos.asascience.com/project'
    )

    projects_info <- httr::content(project_list) %>%
      rvest::html_node('.project_list') %>%
      rvest::html_nodes('a')

    urls <- rvest::html_attr(projects_info, 'href')

    projects <- data.frame(
      name = rvest::html_text(projects_info, trim = T),
      number = as.numeric(gsub('.*detail/', '', urls)),
      url = paste0('https://matos.asascience.com',
                   urls)
    )

  }

  if(what == 'mine'){
    projects <- get_my_projects(read_access = read_access)
  }

  projects
}
