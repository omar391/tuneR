# Makefile for tuneR R Package
# Enhanced Model Tuning for mixOmics
# Author: M Omar Faruque

.PHONY: help install check build test examples clean docs all

# Default target
all: install check

help: ## Show this help message
	@echo "tuneR Package - Available Make Targets:"
	@echo "======================================"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2}'

install: ## Install package dependencies and build/install tuneR
	@echo "Installing tuneR package..."
	@Rscript -e "if (!require('devtools', quietly=TRUE)) install.packages('devtools', repos='https://cran.r-project.org')"
	@Rscript -e "if (!require('mixOmics', quietly=TRUE)) install.packages('mixOmics', repos='https://cran.r-project.org')"
	@Rscript -e "if (!require('ggplot2', quietly=TRUE)) install.packages('ggplot2', repos='https://cran.r-project.org')"
	@Rscript -e "devtools::install()"
	@echo "✓ Package installed successfully"

deps: ## Install only package dependencies
	@echo "Installing dependencies..."
	@Rscript -e "if (!require('devtools', quietly=TRUE)) install.packages('devtools', repos='https://cran.r-project.org')"
	@Rscript -e "if (!require('mixOmics', quietly=TRUE)) install.packages('mixOmics', repos='https://cran.r-project.org')"
	@Rscript -e "if (!require('ggplot2', quietly=TRUE)) install.packages('ggplot2', repos='https://cran.r-project.org')"
	@Rscript -e "if (!require('testthat', quietly=TRUE)) install.packages('testthat', repos='https://cran.r-project.org')"
	@echo "✓ Dependencies installed"

check: ## Run R CMD CHECK on the package
	@echo "Running R CMD CHECK..."
	@Rscript -e "devtools::check()"

test: ## Run package tests
	@echo "Running tests..."
	@Rscript -e "devtools::test()"

build: ## Build package tarball
	@echo "Building package..."
	@Rscript -e "devtools::build()"

docs: ## Generate package documentation
	@echo "Generating documentation..."
	@Rscript -e "devtools::document()"

# Example targets
examples: ## Run all example scripts
	@echo "Running all examples..."
	@make example1 example2 example3 example4

example1: deps ## Run Grid Search example (Issue #186)
	@echo "Running Example 1: Block sPLS-DA Grid Search (Issue #186)..."
	@mkdir -p examples/plots
	@cd examples && Rscript block_splsda_grid_search.R
	@echo "✓ Grid search example completed"

example2: deps ## Run Random Search example (Issue #141)  
	@echo "Running Example 2: Block sPLS-DA Random Search (Issue #141)..."
	@mkdir -p examples/plots
	@cd examples && Rscript block_splsda_random_search.R
	@echo "✓ Random search example completed"

example3: deps ## Run Performance Comparison example (Issue #143)
	@echo "Running Example 3: Performance Comparison (Issue #143)..."
	@mkdir -p examples/plots
	@cd examples && Rscript performance_comparison.R
	@echo "✓ Performance comparison example completed"

example4: deps ## Run Breast Cancer Analysis example
	@echo "Running Example 4: Breast Cancer Analysis..."
	@mkdir -p examples/plots
	@cd examples && Rscript breast_cancer_analysis.R
	@echo "✓ Breast cancer analysis example completed"

# Quick demo target
demo: deps ## Run a quick demo (Grid Search only)
	@echo "Running tuneR Demo (Grid Search Example)..."
	@mkdir -p examples/plots
	@cd examples && Rscript block_splsda_grid_search.R
	@echo "✓ Demo completed! Check examples/plots/ for output"

# Development targets
lint: ## Check code style and potential issues
	@echo "Running lintr checks..."
	@Rscript -e "if (!require('lintr', quietly=TRUE)) install.packages('lintr', repos='https://cran.r-project.org')"
	@Rscript -e "lintr::lint_package()"

coverage: ## Generate test coverage report
	@echo "Generating coverage report..."
	@Rscript -e "if (!require('covr', quietly=TRUE)) install.packages('covr', repos='https://cran.r-project.org')"
	@Rscript -e "covr::package_coverage()"

# Cleanup targets  
clean: ## Clean generated files
	@echo "Cleaning up..."
	@rm -rf examples/plots/*.png
	@rm -rf examples/plots/*.pdf
	@rm -rf *.tar.gz
	@rm -rf .Rcheck/
	@echo "✓ Cleanup completed"

clean-all: clean ## Deep clean including installed packages
	@echo "Deep cleaning..."
	@Rscript -e "try(remove.packages('tuneR'), silent=TRUE)"

# Validation targets
validate: install test check ## Full validation pipeline
	@echo "✓ Full validation completed successfully"

# GitHub integration
release-check: validate examples ## Pre-release validation
	@echo "Performing pre-release checks..."
	@echo "✓ Package ready for release"

# Quick start for new users
quickstart: deps demo ## Quick start for new users
	@echo ""
	@echo "🎉 Welcome to tuneR!"
	@echo "==================="
	@echo "Quick start completed! Here's what you can do next:"
	@echo ""
	@echo "• Run 'make examples' to see all examples"
	@echo "• Run 'make install' to install the package" 
	@echo "• Check examples/plots/ for generated visualizations"
	@echo "• Read examples/README.md for detailed explanations"
	@echo ""

# Show system info
info: ## Show system and R environment info
	@echo "System Information:"
	@echo "=================="
	@echo "OS: $$(uname -s)"
	@echo "R Version:"
	@Rscript -e "cat(R.version.string, '\n')"
	@echo "Package Status:"
	@Rscript -e "if (require('tuneR', quietly=TRUE)) cat('✓ tuneR installed\n') else cat('✗ tuneR not installed\n')"
	@Rscript -e "if (require('mixOmics', quietly=TRUE)) cat('✓ mixOmics available\n') else cat('✗ mixOmics not available\n')"
