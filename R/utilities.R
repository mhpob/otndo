#'
#'
get_project_number <- function(project){
  projects <- matos_projects()
  sub('.*detail/', '', projects[projects$name == tolower(project),]$url)
}

#'
#'
get_file_list <- function(project_number, data_type){
  httr::GET(
    paste('https://matos.asascience.com/project',
           data_type,
           project_number, sep = '/')
  )
}

#'
#'
scrape_file_urls <- function(html_file_list){
  httr::content(html_file_list, 'parsed') %>%
    rvest::html_node('body') %>%
    rvest::html_nodes('a') %>%
    rvest::html_attr('href') %>%
    grep('projectfile', ., value = T)
}

#'
#'
html_table_to_df <- function(html_file_list){
  df <- httr::content(html_file_list, 'parsed') %>%
    rvest::html_nodes('.tableContent') %>%
    rvest::html_table() %>%
    data.frame()

  df[, !names(df) %in% 'Download']
}
