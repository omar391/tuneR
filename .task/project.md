# tuneR Project Documentation

## Project Overview

The `tuneR` package enhances the model tuning capabilities of `mixOmics` by providing more advanced, flexible, and user-friendly tools for hyperparameter optimization. The package aims to improve the statistical rigor of analyses and empower users to find the best parameters for their models with confidence.

**Primary Goal**: Implement missing `tune.block.spls()` functionality with advanced features like random search and Q2 score calculation.

## Requirements Evolution

### MVP Requirements (Week 4 Target)

- **FR1**: `tune.block.spls()` implementation for `block.spls` and `block.splsda` models
- **FR2**: Random search support as alternative to grid search
- **FR3**: Q2 score (predictive R-squared) calculation in performance metrics
- **FR4**: Basic visualization of tuning results

### Non-Functional Requirements

- **NFR1**: Reasonable performance with future parallel processing capability
- **NFR2**: Clear documentation including README and function docs
- **NFR3**: Comprehensive unit testing for algorithms and calculations

### Future Scope (Post-MVP)

- **FS1**: Parallel computing integration (`future` or `BiocParallel`)
- **FS2**: Interactive plots using `plotly`
- **FS3**: Extensible framework for new models and algorithms
- **FS4**: Comprehensive vignette with theory and best practices

## Architecture

### Core Design Pattern

Central `tune()` function with S3 dispatch to specific internal methods based on mixOmics model type.

### Key Components

1. **`tune(method, data, ...)`** - Generic user-facing function
2. **`tune_block_splsda(X, Y, ncomp, test.keepX, search_type, ...)`** - Internal workhorse
3. **`plot.tune_result()`** - S3 plot method for results visualization

### Data Flow

```
User Input → tune() → S3 Dispatch → tune_block_splsda() → Cross-Validation → Performance Metrics → tune_result Object → plot()
```

## Technology Stack

### Core Dependencies

- **R** (>= 4.0.0) - Base language
- **mixOmics** - Core statistical methods being enhanced

### Development Dependencies

- **devtools** - Package development workflow
- **roxygen2** - Function documentation
- **testthat** - Unit testing framework

### Optional Dependencies

- **ggplot2** - Static plotting (MVP)
- **plotly** - Interactive plotting (future)
- **future/BiocParallel** - Parallel processing (future)

## Design Patterns

### S3 Object System

- `tune_result` S3 class for standardized output
- S3 dispatch for method-specific tuning implementations
- S3 plot methods for visualization

### Cross-Validation Framework

- N-fold cross-validation with flexible fold specification
- Performance metric aggregation across folds
- Support for both grid and random parameter search

## Development Environment

### Package Structure

```
tuneR/
├── R/
│   ├── tune.R                 # Main user-facing function
│   ├── tune_block_splsda.R   # Internal tuning implementation
│   └── plot_tune_result.R    # Visualization methods
├── man/                       # Auto-generated documentation
├── tests/
│   └── testthat/
│       └── test-tuning.R     # Unit tests
├── DESCRIPTION               # Package metadata
├── NAMESPACE                # Exports/imports
└── README.md                # User documentation
```

### Development Workflow

1. Use devtools for package management
2. TDD approach: write tests before implementation
3. roxygen2 for documentation generation
4. R CMD check for package validation

## API Documentation

### Primary Interface

```r
# Basic usage
result <- tune(method = "block.splsda",
               data = list(X = X, Y = Y),
               ncomp = c(1, 2, 3),
               test.keepX = list(X1 = c(5, 10, 15), X2 = c(5, 10, 15)),
               search_type = "grid")

# Visualization
plot(result)
```

### tune_result Object Structure

```r
list(
  results_matrix = data.frame,  # Parameters and performance metrics
  best_params = list,           # Optimal parameter set
  method = character,           # Method used
  search_type = character       # Search strategy employed
)
```

## Implementation Notes

### Cross-Validation Strategy

- Use stratified sampling for classification problems
- Maintain consistent fold structure across parameter combinations
- Calculate both error rates and Q2 scores per fold

### Parameter Search Logic

- **Grid Search**: Exhaustive evaluation of all parameter combinations
- **Random Search**: Efficient sampling from parameter space
- Configurable number of random samples for computational control

### Performance Metrics

- **Error Rate**: Classification accuracy for splsda models
- **Q2 Score**: Predictive R-squared for regression assessment
- **Aggregation**: Mean and standard deviation across CV folds

### Error Handling

- Input validation for data compatibility with mixOmics
- Parameter range validation (positive integers, valid dimensions)
- Informative error messages with suggested corrections

### Testing Strategy

- Mock mixOmics functions to avoid heavy computational dependencies
- Test parameter validation edge cases
- Verify Q2 calculation accuracy with known examples
- Performance regression tests for computational efficiency
