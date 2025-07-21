# Block sPLS-DA Grid Search Example
# 
# This example demonstrates comprehensive parameter tuning for block.splsda models
# using grid search. It addresses GitHub Issue #186: "Enhanced block method tuning"
# 
# Author: tuneR package
# Date: 2025-01-21

# Load required libraries
library(mixOmics)
library(tuneR)
library(ggplot2)

# Set seed for reproducibility
set.seed(42)

cat("Block sPLS-DA Grid Search Example\n")
cat("==================================\n\n")

# ============================================================================
# 1. DATA PREPARATION
# ============================================================================

cat("1. Preparing simulated multi-block dataset...\n")

# Create simulated multi-block classification data
# This simulates a typical scenario with gene expression and miRNA data
n_samples <- 120
n_genes <- 200
n_mirnas <- 80
n_classes <- 3

# Generate correlated blocks of data
# Block 1: Gene expression data
set.seed(42)
X1 <- matrix(rnorm(n_samples * n_genes), nrow = n_samples, ncol = n_genes)
colnames(X1) <- paste0("Gene_", 1:n_genes)

# Block 2: miRNA expression data  
X2 <- matrix(rnorm(n_samples * n_mirnas), nrow = n_samples, ncol = n_mirnas)
colnames(X2) <- paste0("miRNA_", 1:n_mirnas)

# Add some correlation between blocks and outcome
Y <- sample(c("ClassA", "ClassB", "ClassC"), n_samples, replace = TRUE)
Y <- factor(Y)

# Add signal to the data based on class
class_effects <- model.matrix(~ Y - 1)
signal_genes <- matrix(rnorm(n_classes * 15), nrow = n_classes, ncol = 15)
signal_mirnas <- matrix(rnorm(n_classes * 8), nrow = n_classes, ncol = 8)

# Inject signal into first few variables
X1[, 1:15] <- X1[, 1:15] + class_effects %*% signal_genes * 2
X2[, 1:8] <- X2[, 1:8] + class_effects %*% signal_mirnas * 1.5

# Combine into data structure
X_blocks <- list(genes = X1, mirnas = X2)

cat(sprintf("  - Created dataset with %d samples and %d classes\n", n_samples, n_classes))
cat(sprintf("  - Block 1 (genes): %d variables\n", ncol(X1)))
cat(sprintf("  - Block 2 (mirnas): %d variables\n", ncol(X2)))
cat(sprintf("  - Class distribution: %s\n", paste(table(Y), collapse = ", ")))

# ============================================================================
# 2. DEFINE TUNING PARAMETERS
# ============================================================================

cat("\n2. Setting up grid search parameters...\n")

# Define the parameter grid
# Note: In practice, you would use larger grids, but we keep this manageable for the example
ncomp_values <- c(1, 2, 3)
keepX_genes <- c(10, 25, 50)
keepX_mirnas <- c(5, 15, 25)

# Create the parameter list
test.keepX <- list(
  genes = keepX_genes,
  mirnas = keepX_mirnas
)

cat(sprintf("  - Component numbers: %s\n", paste(ncomp_values, collapse = ", ")))
cat(sprintf("  - keepX for genes: %s\n", paste(keepX_genes, collapse = ", ")))
cat(sprintf("  - keepX for miRNAs: %s\n", paste(keepX_mirnas, collapse = ", ")))
cat(sprintf("  - Total combinations: %d\n", 
            length(ncomp_values) * length(keepX_genes) * length(keepX_mirnas)))

# ============================================================================
# 3. RUN GRID SEARCH TUNING
# ============================================================================

cat("\n3. Running grid search tuning...\n")
cat("   This demonstrates the systematic approach that addresses GitHub issue #186\n")

start_time <- Sys.time()

# Run the tuning
tune_result <- tune(
  method = "block.splsda",
  data = list(X = X_blocks, Y = Y),
  ncomp = ncomp_values,
  test.keepX = test.keepX,
  search_type = "grid",
  nfolds = 5,
  stratified = TRUE
)

end_time <- Sys.time()
elapsed_time <- as.numeric(difftime(end_time, start_time, units = "secs"))

cat(sprintf("   ✓ Tuning completed in %.2f seconds\n", elapsed_time))

# ============================================================================
# 4. EXAMINE RESULTS
# ============================================================================

cat("\n4. Examining tuning results...\n")

# Print summary
print(tune_result)

cat("\n5. Best Parameters Found:\n")
cat("   ========================\n")
best_params <- tune_result$best_params
cat(sprintf("   Components: %d\n", best_params$ncomp))
cat(sprintf("   keepX genes: %d\n", best_params$keepX$genes))
cat(sprintf("   keepX miRNAs: %d\n", best_params$keepX$mirnas))
cat(sprintf("   Q2 Score: %.4f\n", best_params$Q2_mean))
cat(sprintf("   Error Rate: %.4f\n", best_params$error_rate_mean))

# ============================================================================
# 6. PERFORMANCE ANALYSIS
# ============================================================================

cat("\n6. Analyzing parameter space exploration...\n")

results_df <- tune_result$results_matrix

# Show range of performance metrics discovered
cat(sprintf("   Q2 Score range: %.4f to %.4f\n", 
            min(results_df$Q2_mean), max(results_df$Q2_mean)))
cat(sprintf("   Error Rate range: %.4f to %.4f\n",
            min(results_df$error_rate_mean), max(results_df$error_rate_mean)))

# Find worst performing combination for comparison
worst_idx <- which.min(results_df$Q2_mean)
worst_params <- results_df[worst_idx, ]

cat("\n   Comparison - Best vs Worst Parameters:\n")
cat(sprintf("   Best:  ncomp=%d, genes=%d, miRNAs=%d -> Q2=%.4f, Error=%.4f\n",
            best_params$ncomp, best_params$keepX$genes, best_params$keepX$mirnas,
            best_params$Q2_mean, best_params$error_rate_mean))
cat(sprintf("   Worst: ncomp=%d, genes=%d, miRNAs=%d -> Q2=%.4f, Error=%.4f\n",
            worst_params$ncomp, worst_params$keepX_genes, worst_params$keepX_mirnas,
            worst_params$Q2_mean, worst_params$error_rate_mean))

improvement_q2 <- best_params$Q2_mean - worst_params$Q2_mean
improvement_error <- worst_params$error_rate_mean - best_params$error_rate_mean

cat(sprintf("   \n   💡 Improvement from tuning:\n"))
cat(sprintf("      Q2 Score improved by %.4f (%.1f%% relative)\n", 
            improvement_q2, (improvement_q2/abs(worst_params$Q2_mean))*100))
cat(sprintf("      Error Rate reduced by %.4f (%.1f%% relative)\n",
            improvement_error, (improvement_error/worst_params$error_rate_mean)*100))

# ============================================================================
# 7. VISUALIZATION
# ============================================================================

cat("\n7. Creating visualization...\n")

# Create the plot
p <- plot(tune_result)
print(p)

# Save the plot
ggsave("examples/plots/block_splsda_grid_search_heatmap.png", 
       plot = p, width = 12, height = 8, dpi = 300, bg = "white")

cat("   ✓ Plot saved to: examples/plots/block_splsda_grid_search_heatmap.png\n")

# ============================================================================
# 8. PRACTICAL INSIGHTS
# ============================================================================

cat("\n8. Key Insights from Grid Search:\n")
cat("   ===============================\n")

# Analyze component number effects
component_effects <- aggregate(Q2_mean ~ ncomp, data = results_df, FUN = mean)
best_ncomp <- component_effects$ncomp[which.max(component_effects$Q2_mean)]

cat(sprintf("   🔍 Optimal number of components: %d\n", best_ncomp))

# Analyze keepX effects
keepX_effects_genes <- aggregate(Q2_mean ~ keepX_genes, data = results_df, FUN = mean)
keepX_effects_mirnas <- aggregate(Q2_mean ~ keepX_mirnas, data = results_df, FUN = mean)

best_keepX_genes <- keepX_effects_genes$keepX_genes[which.max(keepX_effects_genes$Q2_mean)]
best_keepX_mirnas <- keepX_effects_mirnas$keepX_mirnas[which.max(keepX_effects_mirnas$Q2_mean)]

cat(sprintf("   🧬 Optimal gene selection: %d variables\n", best_keepX_genes))
cat(sprintf("   🎯 Optimal miRNA selection: %d variables\n", best_keepX_mirnas))

# ============================================================================
# 9. COMPARISON WITH DEFAULT PARAMETERS
# ============================================================================

cat("\n9. Comparing with default parameters...\n")

# Run a quick comparison with "default" parameters (middle values)
default_ncomp <- 2
default_keepX <- list(genes = 25, mirnas = 15)

cat(sprintf("   Default parameters: ncomp=%d, genes=%d, miRNAs=%d\n",
            default_ncomp, default_keepX$genes, default_keepX$mirnas))

# Find the performance of default parameters in our results
default_row <- results_df[results_df$ncomp == default_ncomp & 
                         results_df$keepX_genes == default_keepX$genes &
                         results_df$keepX_mirnas == default_keepX$mirnas, ]

if (nrow(default_row) > 0) {
  default_q2 <- default_row$Q2_mean
  default_error <- default_row$error_rate_mean
  
  cat(sprintf("   Default performance: Q2=%.4f, Error=%.4f\n", default_q2, default_error))
  cat(sprintf("   Tuned performance:   Q2=%.4f, Error=%.4f\n", 
              best_params$Q2_mean, best_params$error_rate_mean))
  
  q2_improvement <- best_params$Q2_mean - default_q2
  error_improvement <- default_error - best_params$error_rate_mean
  
  cat(sprintf("\n   📈 Improvement from tuning vs defaults:\n"))
  cat(sprintf("      Q2 Score: +%.4f (%.1f%% better)\n", 
              q2_improvement, (q2_improvement/abs(default_q2))*100))
  cat(sprintf("      Error Rate: -%.4f (%.1f%% better)\n",
              error_improvement, (error_improvement/default_error)*100))
}

# ============================================================================
# 10. SAVE RESULTS
# ============================================================================

cat("\n10. Saving results...\n")

# Save the complete results for later analysis
saveRDS(tune_result, "examples/block_splsda_grid_search_results.rds")
cat("    ✓ Results saved to: examples/block_splsda_grid_search_results.rds\n")

# Save a summary data frame
summary_df <- data.frame(
  method = "Grid Search",
  total_combinations = nrow(results_df),
  best_ncomp = best_params$ncomp,
  best_keepX_genes = best_params$keepX$genes,
  best_keepX_mirnas = best_params$keepX$mirnas,
  best_Q2 = best_params$Q2_mean,
  best_error_rate = best_params$error_rate_mean,
  computation_time_sec = elapsed_time
)

write.csv(summary_df, "examples/block_splsda_grid_search_summary.csv", row.names = FALSE)
cat("    ✓ Summary saved to: examples/block_splsda_grid_search_summary.csv\n")

# ============================================================================
# CONCLUSION
# ============================================================================

cat("\n" %+% paste(rep("=", 80), collapse = "") %+% "\n")
cat("CONCLUSION: Grid Search Success!\n")
cat(paste(rep("=", 80), collapse = "") %+% "\n")

cat("\nThis example demonstrated how tuneR addresses GitHub Issue #186 by providing:\n\n")

cat("✅ COMPREHENSIVE TUNING: Systematic exploration of all parameter combinations\n")
cat("✅ ADVANCED METRICS: Q2 scores alongside traditional error rates\n") 
cat("✅ CLEAR VISUALIZATION: Intuitive heatmaps showing parameter landscapes\n")
cat("✅ STATISTICAL RIGOR: Proper cross-validation with stratified sampling\n")
cat("✅ REPRODUCIBLE WORKFLOW: Structured approach with clear documentation\n")

cat(sprintf("\n🎯 KEY FINDING: Tuning improved Q2 score by %.1f%% compared to worst parameters\n",
            (improvement_q2/abs(worst_params$Q2_mean))*100))

cat("\n💡 TAKEAWAY: 'An untuned model is just a guess' - systematic parameter\n")
cat("   exploration is essential for robust, reproducible scientific findings.\n")

cat(sprintf("\n📊 Next: Run 'block_splsda_random_search.R' to see how random search\n"))
cat("   can achieve similar results with greater efficiency!\n")

cat("\n" %+% paste(rep("=", 80), collapse = "") %+% "\n")
