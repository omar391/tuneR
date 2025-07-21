#' Cross-Validation Framework for tuneR
#'
#' Internal functions for performing N-fold cross-validation with support for
#' stratified sampling and flexible evaluation metrics.
#'

#' Create Cross-Validation Folds
#'
#' Creates N-fold cross-validation folds with optional stratified sampling
#' for classification problems.
#'
#' @param Y Response variable (factor for classification, numeric for regression)
#' @param nfolds Number of cross-validation folds (integer > 1)
#' @param stratified Logical, whether to use stratified sampling for factors
#'
#' @return List of numeric vectors, each containing indices for a fold
#'
#' @examples
#' # Classification with stratified sampling
#' Y <- factor(rep(c("A", "B"), each = 10))
#' folds <- create_cv_folds(Y, nfolds = 5, stratified = TRUE)
#'
#' # Regression without stratification
#' Y <- rnorm(20)
#' folds <- create_cv_folds(Y, nfolds = 4, stratified = FALSE)
#'
#' @keywords internal
create_cv_folds <- function(Y, nfolds = 5, stratified = TRUE) {
  validate_cv_inputs(X = matrix(1, nrow = length(Y)), Y = Y, nfolds = nfolds)
  
  n <- length(Y)
  
  # Handle edge case: more folds than samples
  if (nfolds > n) {
    warning("More folds than samples. Setting nfolds to number of samples.")
    nfolds <- n
  }
  
  if (is.factor(Y) && stratified) {
    # Stratified sampling for classification
    folds <- vector("list", nfolds)
    
    # Get indices for each class
    class_indices <- split(seq_along(Y), Y)
    
    # Distribute each class across folds
    for (class_name in names(class_indices)) {
      indices <- class_indices[[class_name]]
      
      # Randomly shuffle indices
      indices <- sample(indices)
      
      # Assign to folds in round-robin fashion
      for (i in seq_along(indices)) {
        fold_idx <- ((i - 1) %% nfolds) + 1
        folds[[fold_idx]] <- c(folds[[fold_idx]], indices[i])
      }
    }
  } else {
    # Simple random assignment for regression or non-stratified
    indices <- sample(seq_along(Y))
    folds <- split(indices, cut(seq_along(indices), nfolds, labels = FALSE))
    names(folds) <- NULL  # Remove names to match expected format
  }
  
  # Convert to simple list and ensure numeric indices
  folds <- lapply(folds, function(x) sort(as.numeric(x[!is.na(x)])))
  
  # Remove any empty folds
  folds <- folds[lengths(folds) > 0]
  
  return(folds)
}

#' Perform Cross-Validation
#'
#' Executes N-fold cross-validation using provided fitting, prediction, and
#' evaluation functions.
#'
#' @param X Input data matrix
#' @param Y Response variable
#' @param nfolds Number of cross-validation folds
#' @param fit_function Function to fit model, takes (X_train, Y_train, ...)
#' @param predict_function Function to make predictions, takes (model, X_test)
#' @param evaluation_function Function to evaluate predictions, takes (Y_true, Y_pred)
#' @param stratified Whether to use stratified sampling (for classification)
#' @param ... Additional parameters passed to fit_function
#'
#' @return List containing fold results and aggregated metrics
#'
#' @keywords internal
perform_cross_validation <- function(X, Y, nfolds = 5,
                                   fit_function, predict_function, evaluation_function,
                                   stratified = is.factor(Y), ...) {
  
  validate_cv_inputs(X, Y, nfolds)
  
  # Create CV folds
  folds <- create_cv_folds(Y, nfolds = nfolds, stratified = stratified)
  
  # Perform CV
  fold_results <- vector("list", length(folds))
  
  for (i in seq_along(folds)) {
    test_idx <- folds[[i]]
    train_idx <- setdiff(seq_along(Y), test_idx)
    
    # Split data
    X_train <- X[train_idx, , drop = FALSE]
    X_test <- X[test_idx, , drop = FALSE]
    Y_train <- Y[train_idx]
    Y_test <- Y[test_idx]
    
    # Fit model
    model <- fit_function(X_train, Y_train, ...)
    
    # Make predictions
    Y_pred <- predict_function(model, X_test)
    
    # Evaluate predictions
    metrics <- evaluation_function(Y_test, Y_pred)
    
    fold_results[[i]] <- metrics
  }
  
  # Aggregate results
  mean_metrics <- aggregate_cv_results(fold_results)
  
  return(list(
    fold_results = fold_results,
    mean_metrics = mean_metrics,
    nfolds = length(folds),
    stratified = stratified
  ))
}

#' Aggregate Cross-Validation Results
#'
#' Computes mean and standard deviation across CV folds for each metric.
#'
#' @param fold_results List of metric lists from each CV fold
#'
#' @return List with mean and sd for each metric
#'
#' @keywords internal
aggregate_cv_results <- function(fold_results) {
  if (length(fold_results) == 0) {
    return(list())
  }
  
  # Get metric names from first fold
  metric_names <- names(fold_results[[1]])
  
  aggregated <- vector("list", length(metric_names))
  names(aggregated) <- metric_names
  
  for (metric in metric_names) {
    values <- sapply(fold_results, function(x) x[[metric]])
    
    aggregated[[metric]] <- list(
      mean = mean(values, na.rm = TRUE),
      sd = sd(values, na.rm = TRUE),
      values = values
    )
  }
  
  return(aggregated)
}

#' Validate Cross-Validation Inputs
#'
#' Validates inputs for cross-validation functions.
#'
#' @param X Input data matrix
#' @param Y Response variable
#' @param nfolds Number of folds
#'
#' @keywords internal
validate_cv_inputs <- function(X, Y, nfolds) {
  # Check nfolds
  if (!is.numeric(nfolds) || length(nfolds) != 1 || nfolds < 2) {
    stop("nfolds must be a single integer >= 2")
  }
  
  # Check dimensions match
  if (nrow(X) != length(Y)) {
    stop("Number of rows in X must match length of Y")
  }
  
  # Check for empty data
  if (length(Y) == 0) {
    stop("Y cannot be empty")
  }
  
  invisible(TRUE)
}
