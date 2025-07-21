# Test Cross-Validation Framework

test_that("create_cv_folds creates balanced folds for classification", {
  # Test with simple classification data
  Y <- factor(c(rep("A", 20), rep("B", 20), rep("C", 10)))
  folds <- create_cv_folds(Y, nfolds = 5, stratified = TRUE)
  
  # Should return list of fold indices
  expect_type(folds, "list")
  expect_length(folds, 5)
  
  # Each fold should be numeric indices
  expect_true(all(sapply(folds, is.numeric)))
  
  # All indices should be used exactly once
  all_indices <- sort(unlist(folds))
  expect_equal(all_indices, seq_along(Y))
  
  # Check stratification: each fold should have similar class proportions
  for(fold in folds) {
    fold_classes <- table(Y[fold])
    expected_proportions <- table(Y) / length(Y)
    fold_proportions <- fold_classes / length(fold)
    
    # Allow some tolerance for small datasets
    expect_true(all(abs(fold_proportions - expected_proportions) < 0.3))
  }
})

test_that("create_cv_folds handles regression data", {
  # Test with continuous Y (regression)
  Y <- rnorm(50)
  folds <- create_cv_folds(Y, nfolds = 5, stratified = FALSE)
  
  expect_type(folds, "list")
  expect_length(folds, 5)
  
  # All indices should be used exactly once
  all_indices <- sort(unlist(folds))
  expect_equal(all_indices, seq_along(Y))
})

test_that("create_cv_folds handles edge cases", {
  # Test with single class
  Y <- factor(rep("A", 10))
  folds <- create_cv_folds(Y, nfolds = 3, stratified = TRUE)
  expect_length(folds, 3)
  
  # Test with more folds than samples
  Y <- factor(c("A", "B"))
  expect_warning(
    folds <- create_cv_folds(Y, nfolds = 5, stratified = TRUE),
    "More folds than samples"
  )
})

test_that("perform_cross_validation executes basic workflow", {
  # Mock data
  X <- matrix(rnorm(100), nrow = 10)
  Y <- factor(rep(c("A", "B"), each = 5))
  
  # Mock fit function that returns a simple model
  mock_fit_fn <- function(X_train, Y_train, ...) {
    list(X_train = X_train, Y_train = Y_train, params = list(...))
  }
  
  # Mock predict function
  mock_predict_fn <- function(model, X_test) {
    # Simple prediction: assign class based on first feature
    ifelse(X_test[, 1] > 0, "A", "B")
  }
  
  # Mock evaluation function
  mock_eval_fn <- function(Y_true, Y_pred) {
    list(error_rate = mean(Y_true != Y_pred))
  }
  
  result <- perform_cross_validation(
    X = X, Y = Y,
    nfolds = 3,
    fit_function = mock_fit_fn,
    predict_function = mock_predict_fn,
    evaluation_function = mock_eval_fn,
    param1 = "test_value"
  )
  
  expect_type(result, "list")
  expect_true("fold_results" %in% names(result))
  expect_true("mean_metrics" %in% names(result))
  expect_length(result$fold_results, 3)
})

test_that("aggregate_cv_results computes correct statistics", {
  # Mock fold results
  fold_results <- list(
    list(error_rate = 0.1, q2_score = 0.8),
    list(error_rate = 0.2, q2_score = 0.7),
    list(error_rate = 0.15, q2_score = 0.75)
  )
  
  aggregated <- aggregate_cv_results(fold_results)
  
  expect_type(aggregated, "list")
  expect_equal(aggregated$error_rate$mean, 0.15)
  expect_equal(aggregated$error_rate$sd, sd(c(0.1, 0.2, 0.15)))
  expect_equal(aggregated$q2_score$mean, 0.75)
})

test_that("validate_cv_inputs catches invalid inputs", {
  # Test invalid nfolds
  expect_error(validate_cv_inputs(matrix(1:10), 1:10, nfolds = 0), "nfolds must be")
  expect_error(validate_cv_inputs(matrix(1:10), 1:10, nfolds = "5"), "nfolds must be")
  
  # Test mismatched dimensions
  expect_error(validate_cv_inputs(matrix(1:10, nrow = 5), 1:3, nfolds = 3), "Number of rows")
})
