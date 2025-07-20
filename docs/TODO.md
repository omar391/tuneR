# Task List: `tuneR`

## MVP (Target: End of Week 4)

- [ ] **Task 1: Setup Package Structure:** Create the basic R package directory structure.
- [ ] **Task 2: Implement Cross-Validation Framework:** Write the internal logic for performing N-fold cross-validation.
- [ ] **Task 3: Implement `tune_block_splsda()`:** Write the core function for tuning a `block.splsda` model using a grid search.
- [ ] **Task 4: Add Random Search Capability:** Modify the tuning function to support random search as an option.
- [ ] **Task 5: Write Unit Tests:** Create tests to verify that the tuning process runs correctly and that the output format is as expected.

## Refinement (Target: End of Week 5)

- [ ] **Task 6: Implement Q2 Score:** Add the calculation for the Q2 score to the performance metrics.
- [ ] **Task 7: Create `plot()` Method:** Implement a `ggplot2`-based S3 plot method for the tuning result object.
- [ ] **Task 8: Add Roxygen2 Documentation:** Fully document all user-facing and internal functions.
- [ ] **Task 9: Write `README.md`:** Create a `README.md` with a clear example of how to use the package to tune a model.

## Future Scope

- [ ] **Task 10: Plan Parallel Computing:** Research and outline how to integrate `BiocParallel` or `future` to speed up the CV process.
- [ ] **Task 11: Design Interactive Plots:** Create mockups or a design plan for converting the static `ggplot2` plots into interactive `plotly` plots.
- [ ] **Task 12: Draft Vignette:** Outline a vignette that explains the importance of tuning and provides a detailed tutorial for `tuneR`.
