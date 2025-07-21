#' Tune mixOmics Models
#'
#' Main user-facing function for tuning mixOmics models using advanced 
#' cross-validation with support for grid search and random search.
#'
#' @param method Character, mixOmics method to tune (e.g., "block.splsda", "block.spls")
#' @param data List containing data matrices and response variable
#' @param ncomp Vector of component numbers to test
#' @param test.keepX List of vectors specifying variables to keep for each block
#' @param search_type Character, either "grid" (default) or "random"
#' @param n_random Integer, number of random parameter combinations for random search (default: 50)
#' @param nfolds Integer, number of cross-validation folds (default: 5)
#' @param stratified Logical, whether to use stratified sampling for classification (default: TRUE)
#' @param ... Additional parameters passed to mixOmics functions
#'
#' @return S3 object of class 'tune_result' containing:
#' \describe{
#'   \item{results_matrix}{Data frame with all tested parameter combinations and their performance}
#'   \item{best_params}{List with the optimal parameter combination}
#'   \item{method}{Character, mixOmics method that was tuned}
#'   \item{search_type}{Character, search strategy used ("grid" or "random")}
#'   \item{cv_results}{Detailed cross-validation results for each parameter combination}
#' }
#'
#' @details
#' This function provides an enhanced interface for tuning mixOmics models with several advantages:
#' \itemize{
#'   \item Support for both grid search (exhaustive) and random search (efficient)
#'   \item Q2 score calculation for better model evaluation
#'   \item Flexible cross-validation with stratified sampling
#'   \item Comprehensive performance metrics and visualization support
#' }
#'
#' The \code{data} parameter should be a list containing:
#' \itemize{
#'   \item \code{X}: List of data matrices (one per block) for block methods, or single matrix for regular methods
#'   \item \code{Y}: Response variable (factor for classification, numeric for regression)
#' }
#'
#' For \code{search_type = "grid"}, all combinations of \code{ncomp} and \code{test.keepX} are tested.
#' For \code{search_type = "random"}, \code{n_random} parameter combinations are randomly sampled.
#'
#' @examples
#' \dontrun{
#' # Example with block.splsda
#' library(mixOmics)
#' data(breast.tumors)
#' 
#' X1 <- breast.tumors$gene
#' X2 <- breast.tumors$miRNA
#' Y <- breast.tumors$sample$treatment
#' 
#' # Grid search tuning
#' result_grid <- tune(
#'   method = "block.splsda",
#'   data = list(X = list(gene = X1, miRNA = X2), Y = Y),
#'   ncomp = c(1, 2),
#'   test.keepX = list(gene = c(5, 10), miRNA = c(3, 6)),
#'   search_type = "grid",
#'   nfolds = 3
#' )
#' 
#' # Random search tuning  
#' result_random <- tune(
#'   method = "block.splsda",
#'   data = list(X = list(gene = X1, miRNA = X2), Y = Y),
#'   ncomp = c(1, 2, 3),
#'   test.keepX = list(gene = c(5, 10, 15, 20), miRNA = c(3, 6, 9)),
#'   search_type = "random",
#'   n_random = 25,
#'   nfolds = 5
#' )
#' 
#' # View results
#' print(result_grid)
#' plot(result_grid)
#' 
#' # Access best parameters
#' best_params <- result_grid$best_params
#' }
#'
#' @seealso \code{\link{plot.tune_result}} for visualization of results
#' @export
tune <- function(method, data, ncomp, test.keepX, 
                 search_type = "grid", n_random = 50,
                 nfolds = 5, stratified = TRUE, ...) {
  
  # Input validation
  validate_tune_main_inputs(method, data, ncomp, test.keepX, search_type)
  
  # Dispatch to appropriate method-specific function
  UseMethod("tune", structure(list(), class = method))
}

#' @export
tune.block.splsda <- function(method, data, ncomp, test.keepX,
                              search_type = "grid", n_random = 50,
                              nfolds = 5, stratified = TRUE, ...) {
  
  # Extract data components
  X <- data$X
  Y <- data$Y
  
  # Call internal tuning function
  tune_block_splsda(
    X = X, Y = Y,
    ncomp = ncomp, test.keepX = test.keepX,
    search_type = search_type, n_random = n_random,
    nfolds = nfolds, stratified = stratified,
    method = "block.splsda",
    ...
  )
}

#' @export
tune.block.spls <- function(method, data, ncomp, test.keepX,
                            search_type = "grid", n_random = 50,
                            nfolds = 5, stratified = TRUE, ...) {
  
  # Extract data components
  X <- data$X  
  Y <- data$Y
  
  # Call internal tuning function
  tune_block_splsda(
    X = X, Y = Y,
    ncomp = ncomp, test.keepX = test.keepX,
    search_type = search_type, n_random = n_random,
    nfolds = nfolds, stratified = stratified,
    method = "block.spls",
    ...
  )
}

#' @export
tune.default <- function(method, data, ncomp, test.keepX,
                        search_type = "grid", n_random = 50,
                        nfolds = 5, stratified = TRUE, ...) {
  
  stop(sprintf("Tuning method '%s' is not yet implemented. Currently supported methods: 'block.splsda', 'block.spls'", method))
}

#' Validate Main Tune Function Inputs
#'
#' @param method Character, mixOmics method name
#' @param data List with X and Y components
#' @param ncomp Vector of component numbers
#' @param test.keepX List of keepX values
#' @param search_type Search strategy
#' @keywords internal
validate_tune_main_inputs <- function(method, data, ncomp, test.keepX, search_type) {
  
  # Check method
  if (!is.character(method) || length(method) != 1) {
    stop("method must be a single character string")
  }
  
  # Check data structure
  if (!is.list(data)) {
    stop("data must be a list")
  }
  
  required_components <- c("X", "Y")
  missing_components <- setdiff(required_components, names(data))
  if (length(missing_components) > 0) {
    stop(sprintf("data must contain components: %s", paste(missing_components, collapse = ", ")))
  }
  
  # Check ncomp
  if (!is.numeric(ncomp) || any(ncomp <= 0) || any(!is.finite(ncomp))) {
    stop("ncomp must be a vector of positive integers")
  }
  
  # Check search_type
  if (!search_type %in% c("grid", "random")) {
    stop("search_type must be either 'grid' or 'random'")
  }
  
  invisible(TRUE)
}

#' Print Method for tune_result Objects
#'
#' @param x A tune_result object
#' @param ... Additional arguments (not used)
#' @export
print.tune_result <- function(x, ...) {
  cat("tuneR Model Tuning Results\n")
  cat("==========================\n\n")
  
  cat(sprintf("Method: %s\n", x$method))
  cat(sprintf("Search Type: %s\n", x$search_type))
  cat(sprintf("Cross-Validation Folds: %d\n", x$nfolds))
  cat(sprintf("Parameter Combinations Tested: %d\n", nrow(x$results_matrix)))
  
  cat("\nBest Parameters:\n")
  cat("----------------\n")
  
  # Print ncomp
  cat(sprintf("  ncomp: %d\n", x$best_params$ncomp))
  
  # Print keepX if available
  if ("keepX" %in% names(x$best_params)) {
    cat("  keepX:\n")
    for (block_name in names(x$best_params$keepX)) {
      cat(sprintf("    %s: %d\n", block_name, x$best_params$keepX[[block_name]]))
    }
  }
  
  cat("\nPerformance:\n")
  cat("------------\n")
  
  # Print key performance metrics
  metric_names <- names(x$best_params)
  performance_metrics <- setdiff(metric_names, c("ncomp", "keepX"))
  
  for (metric in performance_metrics) {
    cat(sprintf("  %s: %.4f\n", metric, x$best_params[[metric]]))
  }
  
  cat(sprintf("\nUse plot() to visualize results or access $results_matrix for detailed results.\n"))
  
  invisible(x)
}

#' Summary Method for tune_result Objects
#'
#' @param object A tune_result object
#' @param ... Additional arguments (not used)
#' @export
summary.tune_result <- function(object, ...) {
  cat("tuneR Model Tuning Summary\n")
  cat("==========================\n\n")
  
  print(object)
  
  cat("\nResults Overview:\n")
  cat("-----------------\n")
  
  results <- object$results_matrix
  
  # Show parameter ranges tested
  cat(sprintf("ncomp range: %d - %d\n", min(results$ncomp), max(results$ncomp)))
  
  # Show keepX ranges if available
  keepX_cols <- grep("^keepX_", names(results), value = TRUE)
  for (col in keepX_cols) {
    block_name <- sub("^keepX_", "", col)
    cat(sprintf("%s keepX range: %d - %d\n", block_name, min(results[[col]]), max(results[[col]])))
  }
  
  cat("\nPerformance Summary:\n")
  cat("-------------------\n")
  
  # Show performance metric ranges
  metric_cols <- grep("_mean$", names(results), value = TRUE)
  for (col in metric_cols) {
    metric_name <- sub("_mean$", "", col)
    cat(sprintf("%s: %.4f +/- %.4f (mean +/- sd)\n", 
                metric_name, 
                mean(results[[col]], na.rm = TRUE),
                sd(results[[col]], na.rm = TRUE)))
  }
  
  invisible(object)
}
