# Requirements Analysis: `tuneR`

## 1. Project Vision

To enhance the model tuning capabilities of `mixOmics` by providing more advanced, flexible, and user-friendly tools for hyperparameter optimization. This will improve the statistical rigor of analyses and empower users to find the best parameters for their models with confidence.

## 2. User Profile

- **Primary:** Researchers and statisticians using `mixOmics` for predictive modeling who need to rigorously tune model parameters.
- **Secondary:** `mixOmics` users who are familiar with the concept of tuning but find the current options limited or computationally intensive.

## 3. Functional Requirements (MVP)

- **FR1: `tune.block.spls()` Implementation:** The package MUST provide a function `tune.block.spls()` for tuning the parameters of `block.spls` and `block.splsda` models, as this is a key missing feature.
- **FR2: Random Search:** The core tuning function MUST support random search as an alternative to grid search, allowing for more efficient exploration of the parameter space.
- **FR3: Q2 Score Calculation:** The tuning results MUST include the Q2 score (predictive R-squared) as a performance metric, providing more insight than classification error rates alone.
- **FR4: Basic Visualization:** The package MUST include a basic plot function to visualize tuning results, showing how performance metrics change with different parameter combinations.

## 4. Non-Functional Requirements

- **NFR1: Performance:** The tuning functions should be reasonably performant. For computationally expensive tasks, the design should allow for future integration of parallel processing.
- **NFR2: Documentation:** The package must have a clear `README.md` and well-documented functions.
- **NFR3: Testing:** Unit tests must be implemented to verify the correctness of the tuning algorithms and performance metric calculations.

## 5. Future Scope (Post-MVP)

- **FS1: Parallel Computing:** Integrate `future` or `BiocParallel` to allow users to run tuning cross-validation in parallel, significantly speeding up the process.
- **FS2: Interactive Plots:** Use `plotly` to create interactive visualizations of the tuning results.
- **FS3: Extensible Framework:** Design the `tune()` function to be extensible, allowing for the easy addition of new models and tuning algorithms in the future.
- **FS4: Comprehensive Vignette:** Write a vignette that explains the theory behind hyperparameter tuning and demonstrates best practices using the `tuneR` package.
