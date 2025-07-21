#' Plot Tuning Results
#'
#' Creates visualizations of tuning results to help interpret performance
#' across different parameter combinations.
#'
#' @param x A tune_result object from tune()
#' @param type Character, type of plot: "heatmap" (default), "line", or "scatter"
#' @param metric Character, which metric to plot (default: "error_rate" for classification, "q2_score" for regression)
#' @param ... Additional arguments passed to plotting functions
#'
#' @return ggplot2 object
#'
#' @details
#' Creates different types of visualizations depending on the \code{type} parameter:
#' \itemize{
#'   \item "heatmap": Shows performance across ncomp and keepX combinations
#'   \item "line": Line plot of performance vs ncomp, with keepX as different lines
#'   \item "scatter": Scatter plot of one metric vs another
#' }
#'
#' @examples
#' \dontrun{
#' # After running tune()
#' result <- tune(method = "block.splsda", data = data, ...)
#' 
#' # Default heatmap
#' plot(result)
#' 
#' # Line plot
#' plot(result, type = "line")
#' 
#' # Custom metric
#' plot(result, metric = "q2_score")
#' }
#'
#' @export
plot.tune_result <- function(x, type = "heatmap", metric = NULL, ...) {
  
  # Check if ggplot2 is available
  if (!requireNamespace("ggplot2", quietly = TRUE)) {
    stop("ggplot2 is required for plotting. Please install it with: install.packages('ggplot2')")
  }
  
  # Determine default metric based on method
  if (is.null(metric)) {
    if (grepl("splsda", x$method)) {
      metric <- "error_rate_mean"
    } else {
      metric <- "q2_score_mean" 
    }
  }
  
  # Ensure metric exists in results
  if (!metric %in% names(x$results_matrix)) {
    available_metrics <- grep("_mean$", names(x$results_matrix), value = TRUE)
    stop(sprintf("Metric '%s' not found. Available metrics: %s", 
                 metric, paste(available_metrics, collapse = ", ")))
  }
  
  results <- x$results_matrix
  
  # Create plot based on type
  if (type == "heatmap") {
    create_heatmap_plot(results, metric, x)
  } else if (type == "line") {
    create_line_plot(results, metric, x)
  } else if (type == "scatter") {
    create_scatter_plot(results, metric, x)
  } else {
    stop("type must be one of: 'heatmap', 'line', 'scatter'")
  }
}

#' Create Heatmap Plot
#' @param results Results data frame
#' @param metric Metric to plot
#' @param tune_obj Original tune_result object
#' @keywords internal
create_heatmap_plot <- function(results, metric, tune_obj) {
  
  # Get keepX columns
  keepX_cols <- grep("^keepX_", names(results), value = TRUE)
  
  if (length(keepX_cols) == 0) {
    stop("No keepX parameters found for heatmap plot")
  } else if (length(keepX_cols) == 1) {
    # Single block heatmap
    p <- ggplot2::ggplot(results, ggplot2::aes_string(
      x = "ncomp", 
      y = keepX_cols[1], 
      fill = metric
    )) +
      ggplot2::geom_tile() +
      ggplot2::scale_fill_viridis_c() +
      ggplot2::labs(
        title = sprintf("Tuning Results: %s", tune_obj$method),
        x = "Number of Components",
        y = sub("^keepX_", "", keepX_cols[1]),
        fill = clean_metric_name(metric)
      ) +
      ggplot2::theme_minimal()
    
  } else if (length(keepX_cols) == 2) {
    # Two-block heatmap with faceting
    p <- ggplot2::ggplot(results, ggplot2::aes_string(
      x = keepX_cols[1],
      y = keepX_cols[2], 
      fill = metric
    )) +
      ggplot2::geom_tile() +
      ggplot2::facet_wrap(~ ncomp, labeller = ggplot2::label_both) +
      ggplot2::scale_fill_viridis_c() +
      ggplot2::labs(
        title = sprintf("Tuning Results: %s", tune_obj$method),
        x = sub("^keepX_", "", keepX_cols[1]),
        y = sub("^keepX_", "", keepX_cols[2]),
        fill = clean_metric_name(metric)
      ) +
      ggplot2::theme_minimal()
    
  } else {
    # Multiple blocks - create summary plot
    warning("More than 2 blocks detected. Creating simplified line plot instead.")
    return(create_line_plot(results, metric, tune_obj))
  }
  
  return(p)
}

#' Create Line Plot
#' @param results Results data frame
#' @param metric Metric to plot
#' @param tune_obj Original tune_result object
#' @keywords internal
create_line_plot <- function(results, metric, tune_obj) {
  
  # Get keepX columns
  keepX_cols <- grep("^keepX_", names(results), value = TRUE)
  
  if (length(keepX_cols) >= 1) {
    # Use first keepX column for grouping
    grouping_var <- keepX_cols[1]
    
    p <- ggplot2::ggplot(results, ggplot2::aes_string(
      x = "ncomp",
      y = metric,
      color = paste0("factor(", grouping_var, ")")
    )) +
      ggplot2::geom_line() +
      ggplot2::geom_point() +
      ggplot2::labs(
        title = sprintf("Tuning Results: %s", tune_obj$method),
        x = "Number of Components",
        y = clean_metric_name(metric),
        color = sub("^keepX_", "", grouping_var)
      ) +
      ggplot2::theme_minimal()
    
  } else {
    # Simple line plot by ncomp only
    p <- ggplot2::ggplot(results, ggplot2::aes_string(
      x = "ncomp",
      y = metric
    )) +
      ggplot2::geom_line() +
      ggplot2::geom_point() +
      ggplot2::labs(
        title = sprintf("Tuning Results: %s", tune_obj$method),
        x = "Number of Components", 
        y = clean_metric_name(metric)
      ) +
      ggplot2::theme_minimal()
  }
  
  return(p)
}

#' Create Scatter Plot
#' @param results Results data frame
#' @param metric Primary metric to plot
#' @param tune_obj Original tune_result object
#' @keywords internal
create_scatter_plot <- function(results, metric, tune_obj) {
  
  # Find another metric for comparison
  metric_cols <- grep("_mean$", names(results), value = TRUE)
  other_metrics <- setdiff(metric_cols, metric)
  
  if (length(other_metrics) == 0) {
    stop("Need at least 2 metrics for scatter plot")
  }
  
  y_metric <- other_metrics[1]
  
  p <- ggplot2::ggplot(results, ggplot2::aes_string(
    x = metric,
    y = y_metric,
    size = "ncomp"
  )) +
    ggplot2::geom_point(alpha = 0.7) +
    ggplot2::labs(
      title = sprintf("Tuning Results: %s", tune_obj$method),
      x = clean_metric_name(metric),
      y = clean_metric_name(y_metric),
      size = "Components"
    ) +
    ggplot2::theme_minimal()
  
  return(p)
}

#' Clean Metric Names for Display
#' @param metric_name Character, metric name with suffix
#' @return Character, cleaned name
#' @keywords internal
clean_metric_name <- function(metric_name) {
  cleaned <- sub("_mean$", "", metric_name)
  cleaned <- gsub("_", " ", cleaned)
  cleaned <- tools::toTitleCase(cleaned)
  return(cleaned)
}
