# Parameter Landscape Visualization Assets

This directory contains the visual assets for the Medium article "Don't Just Run the Model, Tune It".

## Images Needed for Article

### 1. parameter_landscape_example.png
**Description**: Heatmap showing Q2 scores across parameter combinations for the breast cancer analysis
**Source**: Generated from `examples/breast_cancer_analysis.R` 
**Specifications**: 
- Width: 1200px
- Height: 800px  
- DPI: 300
- Background: White
- Title: "Breast Cancer Treatment Prediction: Parameter Landscape"

### 2. workflow_diagram.png
**Description**: Mermaid diagram showing the tuneR workflow process
**Generated from**: Mermaid code blocks in the article
**Key elements**: Data input → Parameter generation → Cross-validation → Performance evaluation → Optimal parameters

### 3. performance_comparison.png  
**Description**: Bar chart comparing grid search vs random search efficiency
**Source**: Generated from performance comparison examples
**Shows**: Time efficiency, performance quality, computational cost

## Mermaid Diagrams in Article

The article includes several mermaid diagrams that illustrate:

1. **Problem identification workflow**: Current limitations → Pain points → Suboptimal outcomes
2. **tuneR solution architecture**: Input processing → Search strategies → Evaluation metrics → Results
3. **Search strategy comparison**: Grid vs Random search trade-offs
4. **Performance metrics explanation**: Error rate vs Q2 score interpretation
5. **Scientific workflow impact**: From research question to robust conclusions

## Image Generation Instructions

To generate the actual images for publication:

1. Run the breast cancer analysis example: `source("examples/breast_cancer_analysis.R")`
2. The main heatmap will be saved to `examples/plots/breast_cancer_grid_search_heatmap.png`
3. Copy this to `article/assets/parameter_landscape_example.png`
4. For mermaid diagrams, use any mermaid renderer (GitHub, mermaid.live, etc.)
5. Save as PNG files with white background and appropriate resolution

## Usage in Article

These images support the article's key messages:
- Visual demonstration of parameter optimization benefits
- Clear illustration of computational workflows  
- Comparative analysis showing tuneR's advantages
- Professional presentation suitable for Medium publication

The visualizations transform abstract statistical concepts into intuitive, interpretable insights that support the article's educational goals.
