# Results Summary

## Classification

In our project, `Random Forest` was the strongest classification model in both cross-validation and test evaluation.

Values explicitly stated in the coursework text include:

- Accuracy: `0.7584`
- Kappa: `0.4686`
- AUC: `0.8289`

The report also notes that bagging and boosting were competitive, while tree, kNN and SVM radial performed below the top ensemble methods.

## Unsupervised interpretation

The PCA and fuzzy-clustering block supports the classification narrative:

- the low/high technology split is meaningful;
- the separation is not perfectly sharp;
- there is an intermediate region with shared structure across both profiles.

This helps explain why classification performance is good but not perfect.

## Regression

The regression block shows the same broad pattern:

- nonlinear and ensemble models outperform simpler baselines;
- Random Forest and XGBoost stand out in cross-validation;
- the final model analysis highlights the roles of year, fiscal power and related structural variables.

In the final regression analysis, one representative performance snapshot on the original price scale was:

- MAE: `23,805` dirhams
- MAPE: `23.2%`
- RMSE: `55,010` dirhams

## Why these numbers are documented but not fully reproduced here

The raw datasets, imputed tables and saved R model objects are not public. This repository therefore documents the methodology and the reported findings without republishing the full private training environment.
