# tuneR Current Tasks

## Task T005: Write Unit Tests
- **Title**: Comprehensive Unit Test Suite
- **Description**: Create tests to verify tuning process correctness, output format validation, parameter validation, and edge case handling. Mock mixOmics functions to avoid heavy computational dependencies in testing.
- **Priority**: High
- **Dependencies**: T003 (COMPLETED), T004 (COMPLETED)
- **Status**: In-Progress
- **Progress**: 80%
- **Notes**: Core test suite implemented with 79 passing tests. Need to add tests for plot functionality and edge cases.
- **Connected File List**: tests/testthat/test-tune-block-splsda.R, tests/testthat/test-cross-validation.R

## Task T008: Add Roxygen2 Documentation
- **Title**: Complete Function Documentation
- **Description**: Add comprehensive roxygen2 documentation to all user-facing and key internal functions. Include @param, @return, @examples sections with practical usage examples.
- **Priority**: Medium  
- **Dependencies**: T003 (COMPLETED), T007 (COMPLETED)
- **Status**: In-Progress
- **Progress**: 70%
- **Notes**: Core functions documented, need to generate man pages and add more examples
- **Connected File List**: R/tune.R, R/tune_block_splsda.R, R/plot_tune_result.R, man/

## Task T009: Write README.md
- **Title**: Package Documentation and Usage Guide
- **Description**: Create comprehensive README.md with clear installation instructions, basic usage examples, and feature overview. Include practical code examples demonstrating core functionality.
- **Priority**: Medium
- **Dependencies**: T007 (COMPLETED), T008 (IN-PROGRESS)  
- **Status**: Backlog
- **Progress**: 0%
- **Notes**: First impression for users - critical for adoption
- **Connected File List**: README.md

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
