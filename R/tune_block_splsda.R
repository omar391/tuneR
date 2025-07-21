#' Tune Block Sparse PLS-DA Models
#'
#' Internal function for tuning block.spls and block.splsda models from mixOmics
#' using cross-validation with grid search or random search.
#'
#' @param X List of data matrices (one per block)
#' @param Y Response variable (factor for SPLSDA, numeric for SPLS)
#' @param ncomp Vector of component numbers to test
#' @param test.keepX List of vectors specifying variables to keep for each block
#' @param search_type Character, either "grid" or "random"
#' @param n_random Integer, number of random parameter combinations (for random search)
#' @param nfolds Integer, number of cross-validation folds
#' @param stratified Logical, whether to use stratified sampling
#' @param method Character, either "block.spls" or "block.splsda"
#' @param ... Additional parameters passed to mixOmics functions
#'
#' @return S3 object of class 'tune_result' containing:
#' \describe{
#'   \item{results_matrix}{Data frame with parameters and performance metrics}
#'   \item{best_params}{List with optimal parameter combination}
#'   \item{method}{Character, method used}
#'   \item{search_type}{Character, search strategy used}
#'   \item{cv_results}{Detailed cross-validation results}
#' }
#'
#' @importFrom mixOmics block.spls block.splsda
#' @keywords internal
tune_block_splsda <- function(X, Y, ncomp, test.keepX, 
                              search_type = "grid", n_random = 50,
                              nfolds = 5, stratified = TRUE,
                              method = "block.splsda", ...) {
  
  # Input validation
  validate_tune_inputs(X, Y, ncomp, test.keepX, search_type, method)
  
  # Generate parameter combinations
  param_combinations <- generate_param_combinations(
    ncomp = ncomp, 
    test.keepX = test.keepX, 
    search_type = search_type,
    n_random = n_random
  )
  
  # Prepare results storage
  results <- vector("list", nrow(param_combinations))
  
  # Progress tracking
  message(sprintf("Testing %d parameter combinations using %s search...", 
                  nrow(param_combinations), search_type))
  
  # Evaluate each parameter combination
  for (i in seq_len(nrow(param_combinations))) {
    if (i %% 10 == 0) {
      message(sprintf("Progress: %d/%d combinations completed", i, nrow(param_combinations)))
    }
    
    # Extract parameters for this combination
    current_ncomp <- param_combinations$ncomp[i]
    current_keepX <- extract_keepX_for_combination(param_combinations, i, names(X))
    
    # Perform cross-validation for this parameter set
    cv_result <- evaluate_parameter_combination(
      X = X, Y = Y,
      ncomp = current_ncomp,
      keepX = current_keepX,
      nfolds = nfolds,
      stratified = stratified,
      method = method,
      ...
    )
    
    # Store results
    results[[i]] <- list(
      ncomp = current_ncomp,
      keepX = current_keepX,
      metrics = cv_result$mean_metrics,
      cv_details = cv_result
    )
  }
  
  # Create results data frame
  results_df <- create_results_dataframe(results, param_combinations)
  
  # Find best parameters
  best_params <- find_best_parameters(results_df, method)
  
  # Create and return tune_result object
  tune_result <- structure(list(
    results_matrix = results_df,
    best_params = best_params,
    method = method,
    search_type = search_type,
    cv_results = results,
    nfolds = nfolds,
    stratified = stratified
  ), class = "tune_result")
  
  return(tune_result)
}

#' Generate Parameter Combinations for Tuning
#'
#' Creates all possible combinations of ncomp and keepX values for grid search,
#' or random sample for random search.
#'
#' @param ncomp Vector of component numbers
#' @param test.keepX List of keepX values for each block
#' @param search_type Character, "grid" or "random"
#' @param n_random Integer, number of random combinations
#'
#' @return Data frame with parameter combinations
#' @keywords internal
generate_param_combinations <- function(ncomp, test.keepX, search_type, n_random) {
  
  if (search_type == "grid") {
    # Grid search: all combinations
    # Add keepX combinations
    keepX_combinations <- expand.grid(test.keepX, stringsAsFactors = FALSE)
    names(keepX_combinations) <- paste0("keepX_", names(test.keepX))
    
    # Create full parameter grid
    param_combinations <- expand.grid(
      ncomp = ncomp,
      stringsAsFactors = FALSE
    )
    
    # Replicate for each keepX combination
    full_grid <- do.call(rbind, lapply(seq_len(nrow(keepX_combinations)), function(i) {
      cbind(param_combinations, keepX_combinations[rep(i, nrow(param_combinations)), ])
    }))
    
    return(full_grid)
    
  } else if (search_type == "random") {
    # Random search: sample parameter space
    n_combinations <- min(n_random, prod(length(ncomp), sapply(test.keepX, length)))
    
    param_combinations <- data.frame(
      ncomp = sample(ncomp, n_combinations, replace = TRUE),
      stringsAsFactors = FALSE
    )
    
    # Sample keepX values for each block
    for (block_name in names(test.keepX)) {
      param_combinations[[paste0("keepX_", block_name)]] <- 
        sample(test.keepX[[block_name]], n_combinations, replace = TRUE)
    }
    
    return(param_combinations)
  }
}

#' Extract keepX Parameters for Current Combination
#'
#' @param param_combinations Data frame of parameter combinations
#' @param i Row index
#' @param block_names Names of data blocks
#'
#' @return List of keepX values for each block
#' @keywords internal
extract_keepX_for_combination <- function(param_combinations, i, block_names) {
  keepX <- vector("list", length(block_names))
  names(keepX) <- block_names
  
  for (block_name in block_names) {
    col_name <- paste0("keepX_", block_name)
    if (col_name %in% names(param_combinations)) {
      keepX[[block_name]] <- param_combinations[[col_name]][i]
    }
  }
  
  return(keepX)
}

#' Evaluate Single Parameter Combination via Cross-Validation
#'
#' @param X List of data matrices
#' @param Y Response variable
#' @param ncomp Number of components
#' @param keepX List of keepX values per block
#' @param nfolds Number of CV folds
#' @param stratified Whether to use stratified CV
#' @param method mixOmics method name
#' @param ... Additional parameters
#'
#' @return Cross-validation results
#' @keywords internal
evaluate_parameter_combination <- function(X, Y, ncomp, keepX, nfolds, stratified, method, ...) {
  
  # Define fitting function for this parameter set
  fit_function <- function(X_train_list, Y_train, ...) {
    if (method == "block.splsda") {
      mixOmics::block.splsda(X = X_train_list, Y = Y_train, 
                            ncomp = ncomp, keepX = keepX, ...)
    } else if (method == "block.spls") {
      mixOmics::block.spls(X = X_train_list, Y = Y_train,
                          ncomp = ncomp, keepX = keepX, ...)
    }
  }
  
  # Define prediction function
  predict_function <- function(model, X_test_list) {
    pred_result <- predict(model, newdata = X_test_list)
    
    if (method == "block.splsda") {
      # Return class predictions for classification
      pred_result$class$max.dist[, ncomp]
    } else {
      # Return Y predictions for regression  
      pred_result$predict[, ncomp]
    }
  }
  
  # Define evaluation function
  evaluation_function <- function(Y_true, Y_pred) {
    metrics <- list()
    
    if (method == "block.splsda") {
      # Classification metrics
      metrics$error_rate <- mean(Y_true != Y_pred, na.rm = TRUE)
      metrics$accuracy <- 1 - metrics$error_rate
    } else {
      # Regression metrics
      metrics$mse <- mean((Y_true - Y_pred)^2, na.rm = TRUE)
      metrics$rmse <- sqrt(metrics$mse)
    }
    
    # Q2 score calculation
    metrics$q2_score <- calculate_q2_score(Y_true, Y_pred)
    
    return(metrics)
  }
  
  # Perform cross-validation with block data
  perform_block_cross_validation(
    X = X, Y = Y,
    nfolds = nfolds,
    fit_function = fit_function,
    predict_function = predict_function,
    evaluation_function = evaluation_function,
    stratified = stratified,
    ...
  )
}

#' Cross-Validation for Block Data
#'
#' Modified cross-validation that handles list of data blocks.
#'
#' @param X List of data matrices
#' @param Y Response variable  
#' @param nfolds Number of folds
#' @param fit_function Function to fit model
#' @param predict_function Function to predict
#' @param evaluation_function Function to evaluate
#' @param stratified Whether to use stratified sampling
#' @param ... Additional parameters
#'
#' @return CV results
#' @keywords internal
perform_block_cross_validation <- function(X, Y, nfolds, fit_function, 
                                          predict_function, evaluation_function, 
                                          stratified = TRUE, ...) {
  
  # Create CV folds based on sample size
  n_samples <- nrow(X[[1]])
  folds <- create_cv_folds(Y, nfolds = nfolds, stratified = stratified)
  
  # Perform CV
  fold_results <- vector("list", length(folds))
  
  for (i in seq_along(folds)) {
    test_idx <- folds[[i]]
    train_idx <- setdiff(seq_len(n_samples), test_idx)
    
    # Split each block
    X_train <- lapply(X, function(block) block[train_idx, , drop = FALSE])
    X_test <- lapply(X, function(block) block[test_idx, , drop = FALSE])
    Y_train <- Y[train_idx]
    Y_test <- Y[test_idx]
    
    # Fit model
    tryCatch({
      model <- fit_function(X_train, Y_train, ...)
      
      # Make predictions
      Y_pred <- predict_function(model, X_test)
      
      # Evaluate predictions
      metrics <- evaluation_function(Y_test, Y_pred)
      
      fold_results[[i]] <- metrics
      
    }, error = function(e) {
      warning(sprintf("Error in fold %d: %s", i, e$message))
      fold_results[[i]] <<- list(error_rate = 1, q2_score = -Inf)
    })
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

#' Calculate Q2 Score (Predictive R-squared)
#'
#' Computes Q2 score as measure of predictive performance.
#'
#' @param Y_true True response values
#' @param Y_pred Predicted response values
#'
#' @return Q2 score (numeric)
#' @keywords internal
calculate_q2_score <- function(Y_true, Y_pred) {
  
  # Handle factor conversion for classification
  if (is.factor(Y_true)) {
    # Convert to binary classification scenario for Q2 calculation
    # Use agreement between predicted and true classes
    agreement <- as.numeric(Y_true == Y_pred)
    Y_true_numeric <- agreement
    Y_pred_numeric <- agreement  # Perfect agreement with itself
    q2 <- 1 - var(Y_true_numeric - Y_pred_numeric, na.rm = TRUE) / var(Y_true_numeric, na.rm = TRUE)
  } else {
    # Standard Q2 for continuous variables
    ss_res <- sum((Y_true - Y_pred)^2, na.rm = TRUE)
    ss_tot <- sum((Y_true - mean(Y_true, na.rm = TRUE))^2, na.rm = TRUE)
    q2 <- 1 - (ss_res / ss_tot)
  }
  
  # Handle edge cases
  if (is.infinite(q2) || is.nan(q2)) {
    return(-Inf)
  }
  
  return(q2)
}

#' Create Results Data Frame
#'
#' Converts list of results into a structured data frame.
#'
#' @param results List of result objects
#' @param param_combinations Parameter combinations data frame
#'
#' @return Data frame with results
#' @keywords internal
create_results_dataframe <- function(results, param_combinations) {
  
  # Extract key metrics from results
  df_rows <- lapply(seq_along(results), function(i) {
    result <- results[[i]]
    
    # Base parameters
    row_data <- list(
      ncomp = result$ncomp
    )
    
    # Add keepX parameters
    for (block_name in names(result$keepX)) {
      row_data[[paste0("keepX_", block_name)]] <- result$keepX[[block_name]]
    }
    
    # Add metrics
    for (metric_name in names(result$metrics)) {
      row_data[[paste0(metric_name, "_mean")]] <- result$metrics[[metric_name]]$mean
      row_data[[paste0(metric_name, "_sd")]] <- result$metrics[[metric_name]]$sd
    }
    
    return(data.frame(row_data, stringsAsFactors = FALSE))
  })
  
  # Combine into data frame
  results_df <- do.call(rbind, df_rows)
  
  return(results_df)
}

#' Find Best Parameters
#'
#' Identifies optimal parameter combination based on performance metrics.
#'
#' @param results_df Results data frame
#' @param method mixOmics method used
#'
#' @return List with best parameters
#' @keywords internal
find_best_parameters <- function(results_df, method) {
  
  if (method == "block.splsda") {
    # For classification: minimize error rate, maximize Q2
    # Primary criterion: error_rate
    best_idx <- which.min(results_df$error_rate_mean)
  } else {
    # For regression: maximize Q2 score  
    best_idx <- which.max(results_df$q2_score_mean)
  }
  
  best_row <- results_df[best_idx, ]
  
  # Extract parameters
  best_params <- list(
    ncomp = best_row$ncomp
  )
  
  # Extract keepX parameters
  keepX_cols <- grep("^keepX_", names(best_row), value = TRUE)
  if (length(keepX_cols) > 0) {
    keepX <- list()
    for (col in keepX_cols) {
      block_name <- sub("^keepX_", "", col)
      keepX[[block_name]] <- best_row[[col]]
    }
    best_params$keepX <- keepX
  }
  
  # Add performance metrics
  metric_cols <- grep("_mean$", names(best_row), value = TRUE)
  for (col in metric_cols) {
    metric_name <- sub("_mean$", "", col)
    best_params[[paste0(metric_name, "_mean")]] <- best_row[[col]]
  }
  
  return(best_params)
}

#' Validate Tuning Inputs
#'
#' Comprehensive input validation for tuning functions.
#'
#' @param X List of data matrices
#' @param Y Response variable
#' @param ncomp Vector of component numbers
#' @param test.keepX List of keepX values
#' @param search_type Search strategy
#' @param method mixOmics method
#'
#' @keywords internal
validate_tune_inputs <- function(X, Y, ncomp, test.keepX, search_type, method) {
  
  # Check X is a list
  if (!is.list(X)) {
    stop("X must be a list of data matrices")
  }
  
  # Check all X elements are matrices/data.frames
  if (!all(sapply(X, function(x) is.matrix(x) || is.data.frame(x)))) {
    stop("All elements of X must be matrices or data frames")
  }
  
  # Check consistent sample sizes
  n_samples <- unique(sapply(X, nrow))
  if (length(n_samples) > 1) {
    stop("All data matrices in X must have the same number of rows (samples)")
  }
  
  # Check Y length matches
  if (length(Y) != n_samples) {
    stop("Length of Y must match number of rows in data matrices")
  }
  
  # Check ncomp
  if (!is.numeric(ncomp) || any(ncomp <= 0) || any(!is.finite(ncomp))) {
    stop("ncomp must be a vector of positive integers")
  }
  
  # Check method
  if (!method %in% c("block.spls", "block.splsda")) {
    stop("method must be either 'block.spls' or 'block.splsda'")
  }
  
  # Check Y type matches method
  if (method == "block.splsda" && !is.factor(Y)) {
    stop("Y must be a factor for block.splsda method")
  }
  
  # Check search_type
  if (!search_type %in% c("grid", "random")) {
    stop("search_type must be either 'grid' or 'random'")
  }
  
  # Check test.keepX structure
  if (!is.list(test.keepX)) {
    stop("test.keepX must be a list")
  }
  
  if (length(test.keepX) != length(X)) {
    stop("test.keepX must have the same length as X")
  }
  
  # Check keepX values are positive integers
  for (i in seq_along(test.keepX)) {
    keepX_values <- test.keepX[[i]]
    if (!is.numeric(keepX_values) || any(keepX_values <= 0) || any(!is.finite(keepX_values))) {
      stop(sprintf("test.keepX[[%d]] must contain positive integers", i))
    }
    
    # Check keepX values don't exceed variable count
    max_vars <- ncol(X[[i]])
    if (any(keepX_values > max_vars)) {
      stop(sprintf("test.keepX[[%d]] contains values larger than number of variables (%d)", 
                   i, max_vars))
    }
  }
  
  invisible(TRUE)
}
