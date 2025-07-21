# tuneR Current Tasks

## Task T003: Implement tune_block_splsda()
- **Title**: Core Block SPLS/SPLSDA Tuning Function
- **Description**: Write the main internal function for tuning block.spls and block.splsda models using grid search. Must integrate with cross-validation framework and calculate performance metrics including error rates and Q2 scores.
- **Priority**: High  
- **Dependencies**: T002 (COMPLETED)
- **Status**: In-Progress
- **Progress**: 0%
- **Notes**: Primary deliverable for MVP - most complex implementation task
- **Connected File List**: R/tune_block_splsda.R, tests/testthat/test-tune-block-splsda.R

## Task T004: Add Random Search Capability
- **Title**: Random Search Implementation
- **Description**: Extend the tuning function to support random search as an alternative to grid search. Add parameter to control number of random samples and implement efficient parameter space sampling.
- **Priority**: Medium
- **Dependencies**: T003
- **Status**: Backlog  
- **Progress**: 0%
- **Notes**: Key differentiator feature - improves computational efficiency
- **Connected File List**: R/tune_block_splsda.R, tests/testthat/test-random-search.R

## Task T005: Write Unit Tests
- **Title**: Comprehensive Unit Test Suite
- **Description**: Create tests to verify tuning process correctness, output format validation, parameter validation, and edge case handling. Mock mixOmics functions to avoid heavy computational dependencies in testing.
- **Priority**: High
- **Dependencies**: T003, T004
- **Status**: Backlog
- **Progress**: 0%
- **Notes**: Critical for reliability - aim for >80% test coverage
- **Connected File List**: tests/testthat/test-tuning.R, tests/testthat/test-validation.R

## Task T006: Implement Q2 Score Calculation
- **Title**: Q2 Score Performance Metric
- **Description**: Add calculation for Q2 score (predictive R-squared) to performance metrics. Implement proper cross-validation-based Q2 calculation and integrate with existing error rate metrics.
- **Priority**: Medium
- **Dependencies**: T003
- **Status**: Backlog
- **Progress**: 0%
- **Notes**: Important statistical metric - differentiates from basic mixOmics tuning
- **Connected File List**: R/metrics.R, tests/testthat/test-q2-score.R

## Task T007: Create plot() Method
- **Title**: Basic Visualization for Tuning Results  
- **Description**: Implement S3 plot method for tune_result objects using ggplot2. Create informative visualizations showing performance metrics across parameter combinations (heatmaps, scatter plots).
- **Priority**: Medium
- **Dependencies**: T003, T006
- **Status**: Backlog
- **Progress**: 0%
- **Notes**: User experience enhancement - makes results interpretation easier
- **Connected File List**: R/plot_tune_result.R, tests/testthat/test-plotting.R

## Task T008: Add Roxygen2 Documentation
- **Title**: Complete Function Documentation
- **Description**: Add comprehensive roxygen2 documentation to all user-facing and key internal functions. Include @param, @return, @examples sections with practical usage examples.
- **Priority**: Medium  
- **Dependencies**: T003, T007
- **Status**: Backlog
- **Progress**: 0%
- **Notes**: Essential for package usability - generates man/ files automatically
- **Connected File List**: R/tune.R, R/tune_block_splsda.R, R/plot_tune_result.R, man/

## Task T009: Write README.md
- **Title**: Package Documentation and Usage Guide
- **Description**: Create comprehensive README.md with clear installation instructions, basic usage examples, and feature overview. Include practical code examples demonstrating core functionality.
- **Priority**: Medium
- **Dependencies**: T007, T008  
- **Status**: Backlog
- **Progress**: 0%
- **Notes**: First impression for users - critical for adoption
- **Connected File List**: README.md

## Task T010: Main tune() Function
- **Title**: User-Facing Generic Tuning Function
- **Description**: Implement the main tune() function with S3 dispatch to route different mixOmics methods to appropriate internal tuning functions. Handle input validation and provide consistent user interface.
- **Priority**: High
- **Dependencies**: T003
- **Status**: Backlog
- **Progress**: 0%
- **Notes**: Primary user interface - must be intuitive and robust
- **Connected File List**: R/tune.R, tests/testthat/test-tune-interface.R

---

## Future Tasks (Post-MVP)

## Task T011: Plan Parallel Computing
- **Title**: Research Parallel Processing Integration
- **Description**: Research and outline integration approach for BiocParallel or future packages to enable parallel cross-validation execution.
- **Priority**: Low
- **Dependencies**: T009
- **Status**: Backlog
- **Progress**: 0%
- **Notes**: Performance enhancement for future releases
- **Connected File List**: docs/parallel-design.md

## Task T012: Design Interactive Plots  
- **Title**: Interactive Visualization Planning
- **Description**: Create design mockups for converting static ggplot2 plots to interactive plotly visualizations.
- **Priority**: Low
- **Dependencies**: T007
- **Status**: Backlog
- **Progress**: 0%
- **Notes**: User experience enhancement for future releases  
- **Connected File List**: docs/interactive-plots-design.md

## Task T013: Draft Vignette
- **Title**: Comprehensive Package Vignette
- **Description**: Outline detailed vignette explaining hyperparameter tuning theory and demonstrating tuneR best practices with real examples.
- **Priority**: Low
- **Dependencies**: T009
- **Status**: Backlog  
- **Progress**: 0%
- **Notes**: Educational resource for advanced users
- **Connected File List**: vignettes/tuneR-guide.Rmd
