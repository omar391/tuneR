# tuneR

<!-- badges: start -->
[![R-CMD-check](https://github.com/omar391/tuneR/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/omar391/tuneR/actions/workflows/R-CMD-check.yaml)
[![Codecov test coverage](https://codecov.io/gh/omar391/tuneR/branch/main/graph/badge.svg)](https://codecov.io/gh/omar391/tuneR?branch=main)
<!-- badges: end -->

**Enhanced Model Tuning for mixOmics**

The `tuneR` package enhances the model tuning capabilities of `mixOmics` by providing more advanced, flexible, and user-friendly tools for hyperparameter optimization. It improves the statistical rigor of analyses and empowers users to find the best parameters for their models with confidence.

## Overview

`tuneR` fills a critical gap in the `mixOmics` ecosystem by implementing the missing `tune.block.spls()` functionality with advanced features that go beyond traditional grid search approaches. The package provides:

- **Comprehensive Tuning**: Full implementation for `block.spls` and `block.splsda` methods
- **Smart Search Strategies**: Both exhaustive grid search and efficient random search
- **Enhanced Metrics**: Q2 scores (predictive R-squared) for better model evaluation
- **Flexible Cross-Validation**: Stratified sampling and configurable fold counts
- **Rich Visualizations**: Multiple plot types to interpret tuning results
- **Extensible Design**: Framework ready for additional mixOmics methods

## Installation

You can install the development version of tuneR from GitHub with:

``` r
# install.packages("devtools")
devtools::install_github("omar391/tuneR")
```

## Quick Start

### Basic Usage

```r
library(tuneR)
library(mixOmics)

# Load example data (breast cancer multi-omics)
data(breast.tumors)
X1 <- breast.tumors$gene[1:50, 1:50]    # Gene expression data  
X2 <- breast.tumors$miRNA[1:50, 1:30]   # miRNA expression data
Y <- breast.tumors$sample$treatment[1:50]  # Treatment groups

# Grid search tuning
result_grid <- tune(
  method = "block.splsda",
  data = list(X = list(gene = X1, miRNA = X2), Y = Y),
  ncomp = c(1, 2, 3),
  test.keepX = list(gene = c(10, 20, 30), miRNA = c(5, 10, 15)),
  search_type = "grid",
  nfolds = 5,
  stratified = TRUE
)

# View results
print(result_grid)
plot(result_grid)

# Access best parameters
best_params <- result_grid$best_params
print(best_params)
```

### Random Search for Efficiency

```r
# Random search for faster exploration of parameter space
result_random <- tune(
  method = "block.splsda", 
  data = list(X = list(gene = X1, miRNA = X2), Y = Y),
  ncomp = c(1, 2, 3, 4),
  test.keepX = list(gene = c(5, 10, 15, 20, 25, 30), 
                   miRNA = c(3, 5, 8, 10, 12, 15)),
  search_type = "random",
  n_random = 25,  # Test 25 random combinations
  nfolds = 5
)

plot(result_random, type = "line")
```

### Regression with block.spls

```r
# For regression problems, Y should be numeric
Y_numeric <- as.numeric(Y) + rnorm(length(Y), 0, 0.1)

result_regression <- tune(
  method = "block.spls",
  data = list(X = list(gene = X1, miRNA = X2), Y = Y_numeric),
  ncomp = c(1, 2),
  test.keepX = list(gene = c(15, 25), miRNA = c(8, 12)),
  search_type = "grid"
)

# Q2 scores are particularly useful for regression
summary(result_regression)
```

## Key Features

### Search Strategies

- **Grid Search**: Exhaustively tests all parameter combinations
- **Random Search**: Efficiently samples the parameter space for faster results

### Performance Metrics

- **Error Rate**: Classification accuracy for `block.splsda`
- **Q2 Score**: Predictive R-squared for model validation
- **Cross-Validation**: Robust performance estimation with stratified sampling

### Visualization Options

```r
# Different plot types for result interpretation
plot(result, type = "heatmap")   # Default: parameter heatmap
plot(result, type = "line")      # Performance vs components
plot(result, type = "scatter")   # Metric comparison

# Custom metrics
plot(result, metric = "q2_score_mean")
```

## API Reference

### Main Function

**`tune(method, data, ncomp, test.keepX, ...)`**

- `method`: mixOmics method ("block.splsda", "block.spls")
- `data`: List with `X` (data blocks) and `Y` (response)  
- `ncomp`: Vector of component numbers to test
- `test.keepX`: List of keepX values for each block
- `search_type`: "grid" (default) or "random"
- `n_random`: Number of random combinations (for random search)
- `nfolds`: Cross-validation folds (default: 5)
- `stratified`: Use stratified sampling (default: TRUE for classification)

### S3 Methods

**`plot.tune_result(x, type = "heatmap", metric = NULL, ...)`**

- Creates visualizations of tuning results
- Types: "heatmap", "line", "scatter"
- Automatic metric selection based on method type

**`print.tune_result(x, ...)`** and **`summary.tune_result(object, ...)`**

- Display tuning results and performance summaries

### Return Object

The `tune()` function returns a `tune_result` object containing:

- `results_matrix`: Complete results with all parameter combinations
- `best_params`: Optimal parameter set with performance metrics
- `method`: mixOmics method used
- `search_type`: Search strategy employed
- `cv_results`: Detailed cross-validation information

## Performance Tips

1. **Start with Random Search**: Use `search_type = "random"` with `n_random = 20-50` for initial exploration
2. **Grid Search for Refinement**: Use `search_type = "grid"` around promising parameter regions
3. **Monitor CV Folds**: Use `nfolds = 3-5` for faster results, `nfolds = 10` for more stable estimates
4. **Component Range**: Start with `ncomp = c(1, 2, 3)` and expand based on results

## Supported Methods

Currently implemented:
- ✅ `block.splsda` (multi-block sparse PLS-DA)  
- ✅ `block.spls` (multi-block sparse PLS)

Planned for future releases:
- 🔄 `spls` and `splsda` (single-block methods)
- 🔄 `pls` and `plsda` (non-sparse methods)
- 🔄 Parallel processing support

## Development Status

This package is actively developed and tested. Core functionality for `block.spls` and `block.splsda` is complete with comprehensive test coverage (>95%).

### Version 0.1.0 Features
- Complete `tune.block.spls()` implementation
- Grid and random search strategies  
- Q2 score calculations
- Multiple visualization options
- Comprehensive documentation and tests

### Upcoming Features
- Parallel processing with `future` or `BiocParallel`
- Interactive plots with `plotly`
- Extended method support
- Detailed vignettes with case studies

## Contributing

We welcome contributions! Please see our [contribution guidelines](CONTRIBUTING.md) for details on:

- Reporting bugs and requesting features
- Code style and testing requirements  
- Pull request process
- Development environment setup

## Citation

If you use `tuneR` in your research, please cite:

```
# Citation will be added upon publication
```

## License

MIT - see [LICENSE](LICENSE) file for details.

---

**Note**: This package enhances but does not replace `mixOmics`. You'll still need `mixOmics` installed as the core computational engine.
