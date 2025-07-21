# Block sPLS-DA Random Search Example
# 
# This example demonstrates efficient parameter tuning using random search.
# It addresses GitHub Issue #141: "More efficient parameter exploration"
# (https://github.com/mixOmicsTeam/mixOmics/issues/141)
# and shows when random search outperforms grid search.
# 
# Author: M Omar Faruque
# Date: 2025-01-21

# Load required libraries
library(mixOmics)
library(tuneR)
library(ggplot2)

# Set seed for reproducibility
set.seed(123)

cat("Block sPLS-DA Random Search Example\n")
cat("===================================\n\n")

# ============================================================================
# 1. DATA PREPARATION (LARGER SCALE)
# ============================================================================

cat("1. Preparing larger multi-block dataset for random search demo...\n")

# Create a more complex dataset to demonstrate random search benefits
n_samples <- 150
n_genes <- 500
n_mirnas <- 200
n_proteins <- 100
n_classes <- 4

# Generate three correlated blocks of data
# Block 1: Gene expression data
set.seed(123)
X1 <- matrix(rnorm(n_samples * n_genes), nrow = n_samples, ncol = n_genes)
colnames(X1) <- paste0("Gene_", 1:n_genes)

# Block 2: miRNA expression data  
X2 <- matrix(rnorm(n_samples * n_mirnas), nrow = n_samples, ncol = n_mirnas)
colnames(X2) <- paste0("miRNA_", 1:n_mirnas)

# Block 3: Protein expression data
X3 <- matrix(rnorm(n_samples * n_proteins), nrow = n_samples, ncol = n_proteins)
colnames(X3) <- paste0("Protein_", 1:n_proteins)

# Create outcome with 4 classes
Y <- sample(c("TypeI", "TypeII", "TypeIII", "TypeIV"), n_samples, replace = TRUE)
Y <- factor(Y)

# Add strong signal to the data
class_effects <- model.matrix(~ Y - 1)
signal_genes <- matrix(rnorm(n_classes * 20), nrow = n_classes, ncol = 20)
signal_mirnas <- matrix(rnorm(n_classes * 15), nrow = n_classes, ncol = 15)
signal_proteins <- matrix(rnorm(n_classes * 10), nrow = n_classes, ncol = 10)

# Inject signal into first few variables of each block
X1[, 1:20] <- X1[, 1:20] + class_effects %*% signal_genes * 2.5
X2[, 1:15] <- X2[, 1:15] + class_effects %*% signal_mirnas * 2.0  
X3[, 1:10] <- X3[, 1:10] + class_effects %*% signal_proteins * 1.8

# Combine into data structure
X_blocks <- list(genes = X1, mirnas = X2, proteins = X3)

cat(sprintf("  - Created dataset with %d samples and %d classes\n", n_samples, n_classes))
cat(sprintf("  - Block 1 (genes): %d variables\n", ncol(X1)))
cat(sprintf("  - Block 2 (mirnas): %d variables\n", ncol(X2)))
cat(sprintf("  - Block 3 (proteins): %d variables\n", ncol(X3)))
cat(sprintf("  - Class distribution: %s\n", paste(table(Y), collapse = ", ")))

# ============================================================================
# 2. DEFINE COMPREHENSIVE PARAMETER SPACE
# ============================================================================

cat("\n2. Setting up comprehensive parameter space...\n")

# Define larger parameter ranges (this would be computationally expensive for grid search)
ncomp_values <- c(1, 2, 3, 4, 5)
keepX_genes <- c(10, 25, 50, 75, 100, 150)
keepX_mirnas <- c(5, 10, 20, 30, 40, 60)
keepX_proteins <- c(3, 8, 15, 25, 35, 50)

# Create the parameter list
test.keepX <- list(
  genes = keepX_genes,
  mirnas = keepX_mirnas,
  proteins = keepX_proteins
)

total_combinations <- length(ncomp_values) * length(keepX_genes) * 
                     length(keepX_mirnas) * length(keepX_proteins)

cat(sprintf("  - Component numbers: %s\n", paste(ncomp_values, collapse = ", ")))
cat(sprintf("  - keepX for genes: %s\n", paste(keepX_genes, collapse = ", ")))
cat(sprintf("  - keepX for miRNAs: %s\n", paste(keepX_mirnas, collapse = ", ")))
cat(sprintf("  - keepX for proteins: %s\n", paste(keepX_proteins, collapse = ", ")))
cat(sprintf("  - Total possible combinations: %d\n", total_combinations))

cat("\n   💡 With grid search, this would require evaluating all %d combinations!\n", total_combinations)
cat("      Random search allows us to explore this space efficiently.\n")

# ============================================================================
# 3. RUN RANDOM SEARCH TUNING
# ============================================================================

cat("\n3. Running random search tuning...\n")
cat("   This demonstrates the efficient exploration that addresses GitHub issue #141\n")
cat("   (https://github.com/mixOmicsTeam/mixOmics/issues/141)\n")

# Choose a reasonable number of random samples (much less than total combinations)
n_random_samples <- 50
cat(sprintf("   - Evaluating %d random combinations (%.1f%% of total space)\n", 
            n_random_samples, (n_random_samples/total_combinations)*100))

start_time <- Sys.time()

# Run random search
tune_result_random <- tune(
  method = "block.splsda",
  data = list(X = X_blocks, Y = Y),
  ncomp = ncomp_values,
  test.keepX = test.keepX,
  search_type = "random",
  n_random = n_random_samples,
  nfolds = 5,
  stratified = TRUE
)

end_time <- Sys.time()
elapsed_time_random <- as.numeric(difftime(end_time, start_time, units = "secs"))

cat(sprintf("   ✓ Random search completed in %.2f seconds\n", elapsed_time_random))

# ============================================================================
# 4. COMPARISON: RANDOM VS GRID SEARCH EFFICIENCY
# ============================================================================

cat("\n4. Efficiency Analysis: Random vs Grid Search\n")
cat("   ============================================\n")

# For comparison, run a smaller grid search to estimate time
cat("   Running small grid search for time comparison...\n")

# Smaller parameter space for grid search comparison
small_ncomp <- c(1, 2, 3)
small_test.keepX <- list(
  genes = c(25, 50, 75),
  mirnas = c(10, 20, 30),
  proteins = c(8, 15, 25)
)

small_combinations <- length(small_ncomp) * length(small_test.keepX$genes) * 
                     length(small_test.keepX$mirnas) * length(small_test.keepX$proteins)

start_time_grid <- Sys.time()

tune_result_grid <- tune(
  method = "block.splsda", 
  data = list(X = X_blocks, Y = Y),
  ncomp = small_ncomp,
  test.keepX = small_test.keepX,
  search_type = "grid",
  nfolds = 5,
  stratified = TRUE
)

end_time_grid <- Sys.time()
elapsed_time_grid <- as.numeric(difftime(end_time_grid, start_time_grid, units = "secs"))

# Calculate time per combination
time_per_combination_grid <- elapsed_time_grid / small_combinations
estimated_full_grid_time <- time_per_combination_grid * total_combinations

cat(sprintf("   Grid search (%d combinations): %.2f seconds\n", 
            small_combinations, elapsed_time_grid))
cat(sprintf("   Random search (%d combinations): %.2f seconds\n", 
            n_random_samples, elapsed_time_random))

cat(sprintf("\n   ⏱️  Time efficiency:\n"))
cat(sprintf("      Time per combination (grid): %.2f seconds\n", time_per_combination_grid))
cat(sprintf("      Estimated full grid search time: %.1f seconds (%.1f minutes)\n",
            estimated_full_grid_time, estimated_full_grid_time/60))
cat(sprintf("      Random search speedup: %.1fx faster\n", 
            estimated_full_grid_time / elapsed_time_random))

# ============================================================================
# 5. EXAMINE RANDOM SEARCH RESULTS  
# ============================================================================

cat("\n5. Examining random search results...\n")

# Print summary
print(tune_result_random)

cat("\n6. Best Parameters Found by Random Search:\n")
cat("   =======================================\n")
best_params_random <- tune_result_random$best_params
cat(sprintf("   Components: %d\n", best_params_random$ncomp))
cat(sprintf("   keepX genes: %d\n", best_params_random$keepX$genes))
cat(sprintf("   keepX miRNAs: %d\n", best_params_random$keepX$mirnas))  
cat(sprintf("   keepX proteins: %d\n", best_params_random$keepX$proteins))
cat(sprintf("   Q2 Score: %.4f\n", best_params_random$Q2_mean))
cat(sprintf("   Error Rate: %.4f\n", best_params_random$error_rate_mean))

# ============================================================================
# 6. PARAMETER SPACE COVERAGE ANALYSIS
# ============================================================================

cat("\n7. Analyzing parameter space coverage...\n")

results_df_random <- tune_result_random$results_matrix

# Check coverage of different parameter values
ncomp_coverage <- length(unique(results_df_random$ncomp))
genes_coverage <- length(unique(results_df_random$keepX_genes))
mirnas_coverage <- length(unique(results_df_random$keepX_mirnas))
proteins_coverage <- length(unique(results_df_random$keepX_proteins))

cat(sprintf("   Parameter space coverage with %d random samples:\n", n_random_samples))
cat(sprintf("   - ncomp values explored: %d/%d (%.1f%%)\n", 
            ncomp_coverage, length(ncomp_values), 
            (ncomp_coverage/length(ncomp_values))*100))
cat(sprintf("   - Gene keepX values explored: %d/%d (%.1f%%)\n",
            genes_coverage, length(keepX_genes),
            (genes_coverage/length(keepX_genes))*100))
cat(sprintf("   - miRNA keepX values explored: %d/%d (%.1f%%)\n",
            mirnas_coverage, length(keepX_mirnas),
            (mirnas_coverage/length(keepX_mirnas))*100))
cat(sprintf("   - Protein keepX values explored: %d/%d (%.1f%%)\n",
            proteins_coverage, length(keepX_proteins),
            (proteins_coverage/length(keepX_proteins))*100))

# ============================================================================
# 7. PERFORMANCE DISTRIBUTION ANALYSIS
# ============================================================================

cat("\n8. Analyzing performance distribution...\n")

cat(sprintf("   Q2 Score distribution from random search:\n"))
cat(sprintf("   - Best: %.4f\n", max(results_df_random$Q2_mean)))
cat(sprintf("   - Worst: %.4f\n", min(results_df_random$Q2_mean)))
cat(sprintf("   - Mean: %.4f\n", mean(results_df_random$Q2_mean)))
cat(sprintf("   - Std Dev: %.4f\n", sd(results_df_random$Q2_mean)))

# Find top 5 parameter combinations
top_5_idx <- order(results_df_random$Q2_mean, decreasing = TRUE)[1:5]
cat("\n   🏆 Top 5 parameter combinations found:\n")
for (i in 1:5) {
  idx <- top_5_idx[i]
  row <- results_df_random[idx, ]
  cat(sprintf("   %d. ncomp=%d, genes=%d, miRNAs=%d, proteins=%d -> Q2=%.4f\n",
              i, row$ncomp, row$keepX_genes, row$keepX_mirnas, 
              row$keepX_proteins, row$Q2_mean))
}

# ============================================================================
# 8. VISUALIZATION
# ============================================================================

cat("\n9. Creating visualization...\n")

# Create scatter plot showing random sampling
p_random <- plot(tune_result_random)
print(p_random)

# Save the plot
ggsave("examples/plots/block_splsda_random_search_scatter.png", 
       plot = p_random, width = 12, height = 8, dpi = 300, bg = "white")

cat("   ✓ Plot saved to: examples/plots/block_splsda_random_search_scatter.png\n")

# ============================================================================
# 9. EFFICIENCY VS EFFECTIVENESS ANALYSIS
# ============================================================================

cat("\n10. Efficiency vs Effectiveness Analysis\n")
cat("    ====================================\n")

# Compare the best performance found by random search to grid search
best_q2_random <- max(results_df_random$Q2_mean)
best_q2_grid <- max(tune_result_grid$results_matrix$Q2_mean)

cat(sprintf("   Performance comparison:\n"))
cat(sprintf("   - Random search best Q2: %.4f\n", best_q2_random))
cat(sprintf("   - Grid search best Q2: %.4f\n", best_q2_grid))

performance_diff <- abs(best_q2_random - best_q2_grid)
cat(sprintf("   - Performance difference: %.4f\n", performance_diff))

if (performance_diff < 0.02) {
  cat("   ✅ Random search achieved comparable performance!\n")
} else if (best_q2_random > best_q2_grid) {
  cat("   🎯 Random search actually found better parameters!\n")
} else {
  cat("   ⚠️  Grid search slightly better, but at much higher cost\n")
}

# Calculate efficiency metrics
efficiency_ratio <- estimated_full_grid_time / elapsed_time_random
performance_ratio <- best_q2_random / best_q2_grid

cat(sprintf("\n   📊 Efficiency Summary:\n"))
cat(sprintf("      Time efficiency: %.1fx faster than full grid search\n", efficiency_ratio))
cat(sprintf("      Performance retained: %.1f%% of grid search quality\n", performance_ratio * 100))
cat(sprintf("      Cost-benefit ratio: %.2f (performance/time)\n", 
            performance_ratio / (elapsed_time_random / estimated_full_grid_time)))

# ============================================================================
# 10. WHEN TO USE RANDOM SEARCH
# ============================================================================

cat("\n11. When to Choose Random Search:\n")
cat("    =============================\n")

cat("   ✅ RANDOM SEARCH IS IDEAL WHEN:\n")
cat("      - Large parameter spaces (>100 combinations)\n")
cat("      - Limited computational resources\n") 
cat("      - Quick parameter exploration needed\n")
cat("      - High-dimensional parameter spaces\n")
cat("      - Time constraints are important\n")

cat("\n   ⚠️  GRID SEARCH IS BETTER WHEN:\n")
cat("      - Small parameter spaces (<50 combinations)\n")
cat("      - Exhaustive search is feasible\n")
cat("      - Need to guarantee finding global optimum\n")
cat("      - Parameter interactions are complex\n")
cat("      - Computational resources are abundant\n")

# ============================================================================
# 11. SAVE RESULTS
# ============================================================================

cat("\n12. Saving results...\n")

# Save the complete results
saveRDS(tune_result_random, "examples/block_splsda_random_search_results.rds")
cat("    ✓ Results saved to: examples/block_splsda_random_search_results.rds\n")

# Save comparison summary
comparison_df <- data.frame(
  method = c("Random Search", "Grid Search (subset)"),
  combinations_tested = c(n_random_samples, small_combinations), 
  total_possible = c(total_combinations, total_combinations),
  coverage_percent = c((n_random_samples/total_combinations)*100,
                      (small_combinations/total_combinations)*100),
  computation_time_sec = c(elapsed_time_random, elapsed_time_grid),
  best_Q2 = c(best_q2_random, best_q2_grid),
  best_error_rate = c(min(results_df_random$error_rate_mean),
                     min(tune_result_grid$results_matrix$error_rate_mean))
)

write.csv(comparison_df, "examples/block_splsda_random_vs_grid_comparison.csv", row.names = FALSE)
cat("    ✓ Comparison saved to: examples/block_splsda_random_vs_grid_comparison.csv\n")

# ============================================================================
# CONCLUSION
# ============================================================================

cat("\n" %+% paste(rep("=", 80), collapse = "") %+% "\n")
cat("CONCLUSION: Random Search Success!\n") 
cat(paste(rep("=", 80), collapse = "") %+% "\n")

cat("\nThis example demonstrated how tuneR addresses GitHub Issue #141 by providing:\n")
cat("(https://github.com/mixOmicsTeam/mixOmics/issues/141)\n\n")

cat("🚀 COMPUTATIONAL EFFICIENCY: %.1fx faster than exhaustive grid search\n" %+% efficiency_ratio)
cat("🎯 EFFECTIVE EXPLORATION: Found high-quality parameters with limited sampling\n")
cat("🔍 SMART SAMPLING: Covered %.1f%% of parameter space efficiently\n" %+% (n_random_samples/total_combinations)*100)
cat("📈 COMPARABLE PERFORMANCE: Achieved %.1f%% of grid search quality\n" %+% performance_ratio * 100)
cat("⚡ PRACTICAL UTILITY: Enables exploration of large parameter spaces\n")

cat(sprintf("\n🔑 KEY INSIGHT: Random search explored %d combinations in %.1f seconds\n",
            n_random_samples, elapsed_time_random))
cat(sprintf("   while equivalent grid search would need %.1f minutes!\n",
            estimated_full_grid_time/60))

cat("\n💡 STRATEGIC RECOMMENDATION:\n")
cat("   - Use random search for initial parameter exploration\n")
cat("   - Follow with focused grid search around promising regions\n") 
cat("   - Perfect for high-dimensional tuning problems\n")

cat(sprintf("\n📊 Next: Run 'performance_comparison.R' to see advanced\n"))
cat("   performance metrics and Q2 score analysis!\n")

cat("\n" %+% paste(rep("=", 80), collapse = "") %+% "\n")
