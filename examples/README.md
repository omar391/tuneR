# tuneR Examples

This directory contains practical examples demonstrating how the `tuneR` package solves real issues from the mixOmics GitHub repository. Each example showcases specific capabilities and addresses pain points that users have encountered.

## Quick Start

To run these examples, ensure you have the required packages installed:

```r
# Install required packages
if (!require("mixOmics")) install.packages("mixOmics")
if (!require("tuneR")) devtools::install_github("omar391/tuneR")
```

## Examples Overview

### 1. Block sPLS-DA Grid Search (`block_splsda_grid_search.R`)

**Addresses GitHub Issue #186: "Enhanced block method tuning"**

This example demonstrates comprehensive parameter tuning for block.splsda models using grid search. It shows how to:
- Set up multi-block data for classification
- Define parameter grids for systematic exploration
- Interpret Q2 scores and classification error rates
- Visualize tuning results with heatmaps

**Key Features:**
- Systematic exploration of all parameter combinations
- Comprehensive performance metrics (Q2, error rates)
- Professional visualization of results
- Best parameter identification

### 2. Block sPLS-DA Random Search (`block_splsda_random_search.R`)

**Addresses GitHub Issue #141: "More efficient parameter exploration"**

Random search is often more efficient than grid search, especially with high-dimensional parameter spaces. This example shows:
- How random search can find good parameters faster
- Comparison with equivalent grid search approaches
- Computational efficiency benefits
- When to choose random over grid search

**Key Features:**
- Efficient exploration of large parameter spaces
- Configurable number of random samples
- Performance comparison metrics
- Time and computational resource savings

### 3. Performance Comparison Analysis (`performance_comparison.R`)

**Addresses GitHub Issue #143: "Better performance metrics and visualization"**

This example demonstrates the advanced performance evaluation capabilities that go beyond simple classification accuracy:
- Q2 score calculation and interpretation
- Multi-metric evaluation framework
- Comparative analysis between different approaches
- Statistical significance testing of parameter differences

**Key Features:**
- Q2 scores for predictive performance assessment
- Multiple performance metrics in one analysis
- Statistical comparison framework
- Advanced visualization techniques

### 4. Block sPLS Regression Example (`block_spls_regression.R`)

**Demonstrates regression capabilities** 

Shows how tuneR handles continuous outcomes with block.spls models:
- Regression-specific performance metrics
- Continuous outcome handling
- Q2 score interpretation for regression
- Cross-validation for predictive modeling

### 5. Real-World Data Analysis (`breast_cancer_analysis.R`)

**Complete analysis workflow**

A comprehensive analysis using the breast cancer dataset that demonstrates:
- Data preprocessing and preparation
- Systematic parameter exploration
- Results interpretation and biological insights
- Publication-ready visualizations

## Running the Examples

Each example is self-contained and can be run independently:

```r
# Example 1: Grid Search
source("examples/block_splsda_grid_search.R")

# Example 2: Random Search  
source("examples/block_splsda_random_search.R")

# Example 3: Performance Comparison
source("examples/performance_comparison.R")
```

## Output Files

Examples generate several types of output:
- **Plots**: Saved as PNG files in `examples/plots/`
- **Results**: Saved as RDS files for later analysis
- **Summaries**: Text summaries of key findings

## Key Learning Outcomes

After working through these examples, users will understand:

1. **When to use grid vs random search** and their trade-offs
2. **How to interpret Q2 scores** alongside classification metrics  
3. **The importance of proper cross-validation** in parameter tuning
4. **How visualization aids** in parameter selection decisions
5. **Best practices for reproducible** hyperparameter optimization

## GitHub Issues Addressed

| Issue | Problem | tuneR Solution | Example |
|-------|---------|----------------|---------|
| #186 | Limited block method tuning | Comprehensive block.splsda/spls tuning | Examples 1, 2, 4 |
| #141 | Only grid search available | Random search implementation | Example 2 |
| #143 | Basic performance metrics | Q2 scores and advanced metrics | Example 3, 5 |

## Contributing

Found an issue or have a suggestion for improving these examples? Please open an issue on the [GitHub repository](https://github.com/omar391/tuneR/issues).

---

*These examples demonstrate that hyperparameter tuning is not optional—it's essential for robust, reproducible scientific findings. Good tools make this critical step accessible to everyone.*
