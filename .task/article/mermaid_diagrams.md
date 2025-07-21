# Mermaid Diagrams for Medium Article

This file contains all the mermaid diagrams used in the Medium article for easy rendering and updating.

## 1. Problem Identification Workflow

```mermaid
graph TD
    A[Researcher with Multi-omics Data] --> B{Current Tuning Options}
    B --> C[Limited Grid Search Only]
    B --> D[Basic Error Metrics Only] 
    B --> E[Computationally Expensive]
    C --> F[❌ Inadequate Exploration]
    D --> F[❌ Incomplete Evaluation]
    E --> F[❌ Time Prohibitive]
    F --> G[Suboptimal Models]
    G --> H[Questionable Scientific Conclusions]
```

## 2. tuneR Solution Architecture

```mermaid
graph LR
    A[Multi-block Data] --> B[tuneR Engine]
    B --> C[Cross-Validation Framework]
    B --> D[Parameter Generation] 
    B --> E[Performance Evaluation]
    C --> F[Stratified Sampling]
    D --> G[Grid Search]
    D --> H[Random Search]
    E --> I[Q2 Scores]
    E --> J[Error Rates]
    E --> K[Statistical Tests]
    F --> L[Robust Estimates]
    G --> L
    H --> L
    I --> L
    J --> L
    K --> L
    L --> M[Optimal Parameters]
```

## 3. Search Strategy Comparison

```mermaid
graph TD
    A[Parameter Space] --> B{Search Strategy}
    B --> C[Grid Search]
    B --> D[Random Search]
    
    C --> E[Exhaustive<br/>✅ Guaranteed optimal<br/>❌ Computationally expensive<br/>❌ Poor high-dimensional scaling]
    
    D --> F[Probabilistic<br/>✅ Highly efficient<br/>✅ Scales well<br/>✅ Often finds excellent solutions<br/>⚠️ No optimality guarantee]
    
    E --> G[Best for:<br/>• Small spaces <50 combinations<br/>• Unlimited computation<br/>• Need certainty of global optimum]
    
    F --> H[Best for:<br/>• Large spaces >100 combinations<br/>• Limited computation<br/>• Quick parameter exploration]
    
    style A fill:#e1f5fe
    style D fill:#c8e6c9
    style F fill:#c8e6c9
```

## 4. Performance Metrics Explanation

```mermaid
graph LR
    A[Model Performance] --> B[Classification Accuracy]
    A --> C[Q2 Score]
    
    B --> D["Answers: 'How often correct?'<br/>Range: 0-100%<br/>Focus: Decision making"]
    
    C --> E["Answers: 'How much variance explained?'<br/>Range: -∞ to 1.0<br/>Focus: Biological understanding"]
    
    B --> F[Clinical Utility]
    C --> G[Scientific Insight]
    
    F --> H[Diagnostic Applications]
    G --> I[Biological Discovery]
    
    style C fill:#c8e6c9
    style E fill:#c8e6c9
    style G fill:#c8e6c9
    style I fill:#c8e6c9
```

## 5. Visualization to Insight Pipeline

```mermaid
graph TD
    A[Raw Parameter Results] --> B[Visualization]
    B --> C[Pattern Recognition]
    C --> D[Biological Insight]
    D --> E[Scientific Understanding]
    
    B --> F[Heatmaps reveal<br/>parameter interactions]
    B --> G[Scatter plots show<br/>performance distribution]
    B --> H[Line plots track<br/>optimization progress]
    
    F --> I[Complex relationships<br/>between parameters]
    G --> J[Performance variability<br/>and robustness]
    H --> K[Search efficiency<br/>and convergence]
    
    I --> L[Guide experimental design]
    J --> M[Assess model reliability]
    K --> N[Optimize computational resources]
    
    style D fill:#c8e6c9
    style E fill:#c8e6c9
```

## 6. Scientific Workflow Impact

```mermaid
graph TD
    A[Research Question] --> B[Data Collection]
    B --> C[Statistical Analysis]
    C --> D{Current Approach}
    C --> E{tuneR Approach}
    
    D --> F[Default Parameters<br/>❌ Suboptimal performance<br/>❌ Hidden assumptions<br/>❌ Poor reproducibility]
    
    E --> G[Systematic Tuning<br/>✅ Optimal performance<br/>✅ Explicit methodology<br/>✅ Full reproducibility]
    
    F --> H[Weak Scientific Conclusions]
    G --> I[Robust Scientific Insights]
    
    I --> J[Better Biology Understanding]
    I --> K[Successful Clinical Translation] 
    I --> L[Reproducible Research]
    
    style E fill:#c8e6c9
    style G fill:#c8e6c9
    style I fill:#c8e6c9
```

## Rendering Instructions

To render these diagrams:

1. **GitHub**: Copy the mermaid code blocks and paste into a GitHub markdown file or issue
2. **Mermaid Live Editor**: Go to https://mermaid.live and paste the code
3. **VS Code**: Use the Mermaid Preview extension
4. **Command Line**: Use mermaid-cli: `mmdc -i diagram.mmd -o diagram.png`

## Style Guide

- **Colors**:
  - Success/Positive: `#c8e6c9` (light green)
  - Info/Neutral: `#e1f5fe` (light blue)  
  - Problem/Negative: Default (no fill)
- **Typography**: Use clear, concise labels
- **Layout**: Prefer left-to-right flow for processes, top-down for hierarchies
- **Size**: Ensure readability at article width (~800px)
