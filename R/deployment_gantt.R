#' Create a Gantt-like chart of receiver deployments and recoveries
#'
#' @param deployment Cleaned deployment metadata sheet(s). Assumes it was
#'    cleaned with the internal `otndo:::clean_otn_deployment` function, read in,
#'    and converted to a data.table.
#'
#' @examples
#' \dontrun{
#' # Download a deployment metadata file
#' td <- file.path(tempdir(), "matos_test_files")
#' dir.create(td)
#'
#' download.file(
#'   paste0(
#'     "https://members.oceantrack.org/data/repository/pbsm/",
#'     "data-and-metadata/2018/pbsm-instrument-deployment-short-form-2018.xls/",
#'     "@@download/file"
#'   ),
#'   destfile = file.path(td, "pbsm-instrument-deployment-short-form-2018.xls"),
#'   mode = "wb"
#' )
#'
#' # Use internal function to clean
#' deployment_filepath <- otndo:::write_to_tempdir(
#'   type = "deployment",
#'   files = file.path(td, "pbsm-instrument-deployment-short-form-2018.xls"),
#'   temp_dir = td
#' )
#'
#' # Make the Gantt chart
#' deployment_gantt(
#'   data.table::fread(deployment_filepath)
#' )
#' }
#'
#' @export
deployment_gantt <- function(deployment) {
  ggplot2::ggplot(data = deployment) +
    ggplot2::geom_linerange(
      ggplot2::aes(
        y = stationname,
        xmin = deploy_date_time,
        xmax = recover_date_time
      ),
      linewidth = 5
    ) +
    ggplot2::geom_linerange(
      ggplot2::aes(
        ymin = as.numeric(factor(stationname)) - 0.4,
        ymax = as.numeric(factor(stationname)) + 0.4,
        x = recover_date_time
      ),
      color = "red", linewidth = 2
    ) +
    ggplot2::scale_x_datetime(date_breaks = "month", date_labels = "%b %y") +
    ggplot2::labs(x = NULL, y = NULL, title = "Temporal receiver coverage") +
    ggplot2::theme_minimal() +
    ggplot2::theme(axis.text.x = ggplot2::element_text(angle = 45, hjust = 1))
}
