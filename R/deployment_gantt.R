#' Create a Gantt-like chart of receiver deployments and recoveries
#'
#' @param deployment file path of the deployment metadata sheet(s)
#'
#' @export
deployment_gantt <- function(deployment){
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
