# tuneR

<!-- badges: start -->
<!-- badges: end -->

**Enhanced Model Tuning for mixOmics**

The `tuneR` package enhances the model tuning capabilities of `mixOmics` by providing more advanced, flexible, and user-friendly tools for hyperparameter optimization. It improves the statistical rigor of analyses and empowers users to find the best parameters for their models with confidence.

## Installation

You can install the development version of tuneR from GitHub with:

``` r
# install.packages("devtools")
devtools::install_github("username/tuneR")
```

## Features

- **Missing Functionality**: Implements `tune.block.spls()` for `block.spls` and `block.splsda` models
- **Random Search**: Efficient alternative to exhaustive grid search
- **Q2 Score**: Predictive R-squared metric for better model assessment  
- **Visualization**: Clear plots showing parameter optimization results
- **Extensible**: Framework designed for future method additions

## Quick Start

```r
library(tuneR)
library(mixOmics)

# Example with block.splsda
# Load your data into X (list of matrices) and Y (factor)
result <- tune(method = "block.splsda",
               data = list(X = X, Y = Y),
               ncomp = c(1, 2, 3),
               test.keepX = list(X1 = c(5, 10, 15), 
                                X2 = c(5, 10, 15)),
               search_type = "grid",
               validation = "Mfold",
               folds = 5)

# View results
print(result)
plot(result)

# Access best parameters
result$best_params
```

## Key Functions

- `tune()`: Main function for model tuning with method dispatch
- `plot.tune_result()`: Visualization of tuning results
- Support for both grid search and random search strategies

## Development Status

This package is under active development. Current focus is on implementing core functionality for `block.spls` and `block.splsda` methods with plans to extend to other mixOmics methods.

## Contributing

Please see our [contribution guidelines](CONTRIBUTING.md) for details on how to contribute to this project.

## License

GPL (>= 3)
