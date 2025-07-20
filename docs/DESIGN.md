# Design Document: `tuneR`

## 1. Architecture Overview

The `tuneR` package will be built around a central, flexible `tune()` function. This function will act as a wrapper that dispatches to specific internal methods based on the `mixOmics` model being tuned. The initial focus will be on implementing the logic for `block.spls(da)`.

## 2. Core Functions (MVP)

### `tune(method, data, ...)`

- **Purpose:** A generic, user-facing function for model tuning.
- **Parameters:**
  - `method`: A string specifying the `mixOmics` method, e.g., `"block.splsda"`.
  - `data`: A list containing the `X` and `Y` data.
  - `...`: Additional parameters passed to the specific tuning method (e.g., `ncomp`, `test.keepX`, `search_type`).
- **Logic:** This function will use S3 dispatch or a `switch` statement to call the appropriate internal tuning function (e.g., `tune_block_splsda`).

### `tune_block_splsda(X, Y, ncomp, test.keepX, search_type = "grid", ...)`

- **Purpose:** The internal workhorse for tuning a `block.splsda` model.
- **Parameters:**
  - `X`, `Y`, `ncomp`, `test.keepX`: Standard `mixOmics` parameters. `test.keepX` will be the grid of parameters to search.
  - `search_type`: A string, either `"grid"` or `"random"`.
- **Returns:** A `list` object of class `tune_result` containing:
  - `results_matrix`: A data frame with parameters and corresponding performance metrics (e.g., error rate, Q2).
  - `best_params`: The set of parameters that yielded the best performance.
- **Logic:**
  1. Set up a cross-validation framework.
  2. If `search_type == "grid"`, iterate through every combination of `test.keepX`.
  3. If `search_type == "random"`, randomly sample a subset of the parameter grid.
  4. For each parameter set, run the `block.splsda` model within the cross-validation folds.
  5. Calculate and store the performance metrics (error rate, Q2).
  6. Aggregate results and identify the optimal parameters.

### `plot(tune_result)`

- **Purpose:** An S3 plot method for the `tune_result` object.
- **Parameters:**
  - `tune_result`: The output from the `tune()` function.
- **Returns:** A `ggplot2` object.
- **Logic:** Creates a plot (e.g., a heatmap or scatter plot) showing the performance metric across the grid of tuned parameters.

## 3. Data Structures

- **Input:** `list` of data matrices, `vectors` of tuning parameters.
- **Internal:** `data.frame` to store the results of each CV run.
- **Output:** A custom S3 object `tune_result` (which is a `list`) to be used by the plot method.

## 4. Error Handling

- Input validation for all parameters.
- Check that the specified `method` is supported.
- User-friendly messages if required packages (e.g., `mixOmics`) are not installed.

## 5. Package Structure

```
tuneR/
├── R/
│   ├── tune.R
│   ├── tune_block_splsda.R
│   └── plot_tune_result.R
├── man/
├── tests/
│   └── testthat/
│       └── test-tuning.R
├── DESCRIPTION
├── NAMESPACE
└── README.md
```
