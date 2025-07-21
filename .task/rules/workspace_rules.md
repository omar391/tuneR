# tuneR Workspace Rules and Guidelines

## Coding Standards

- R coding style follows Hadley Wickham's style guide
- Use roxygen2 for function documentation (@param, @return, @examples)
- Prefer underscore naming for internal functions (e.g., `tune_block_splsda`)
- Use descriptive parameter names that match mixOmics conventions
- Maximum line length: 80 characters

## R Package Structure

- Follow standard R package structure with R/, man/, tests/, DESCRIPTION, NAMESPACE
- Use testthat framework for unit testing
- All exported functions must have corresponding tests
- Use devtools for package development workflow

## Dependencies Management

- Minimize external dependencies
- Core dependency: mixOmics package
- Optional dependencies: ggplot2 for plotting, future/BiocParallel for parallelization
- Document all dependencies in DESCRIPTION file

## Function Design

- Central `tune()` function uses S3 dispatch for different mixOmics methods
- Internal functions follow naming pattern: `tune_[method_name]`
- All tuning functions return standardized `tune_result` S3 objects
- Support both grid search and random search strategies

## Performance Considerations

- Design for potential parallel processing integration
- Use efficient cross-validation implementations
- Consider memory usage for large parameter grids
- Profile computationally expensive operations

## Testing Requirements

- Test coverage > 80% for all exported functions
- Mock mixOmics functions in tests to avoid heavy dependencies
- Test both grid and random search strategies
- Validate Q2 score calculations with known examples

## Documentation Standards

- Every exported function needs complete roxygen2 documentation
- Include practical examples in @examples sections
- README.md must demonstrate basic usage with code examples
- Functions should validate inputs and provide clear error messages

## Error Handling

- Validate that required mixOmics methods are available
- Check data structure compatibility (X, Y format)
- Provide informative error messages for parameter validation
- Handle edge cases in cross-validation splits

## Git Workflow

- Commit messages should reference task IDs when applicable
- Branch naming: feature/task-[ID]-description
- All commits should pass R CMD check
- Update NEWS.md for significant changes
