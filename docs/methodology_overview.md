# Methodology Overview

The reviewed coursework is broader than a single classification notebook. It combines supervised and unsupervised analysis around a used-vehicle dataset.

## 1. Binary classification

The report defines a binary technological target and then:

- prepares a modelling table with numeric and categorical predictors;
- groups high-cardinality categories;
- creates a stratified holdout split;
- applies 5-fold cross-validation on the training data;
- compares tree, ensemble, SVM and kNN classifiers;
- evaluates the final models through confusion matrices, ROC curves and AUC.

## 2. Unsupervised support analysis

The unsupervised block is not isolated from the supervised tasks. It is used to interpret the structure behind the binary target:

- PCA summarizes the multivariate structure;
- a price-colored PCA view helps connect the latent dimensions with the regression task;
- fuzzy clustering shows where the class separation becomes ambiguous.

## 3. Regression

The regression block predicts vehicle price after a log transformation and compares:

- linear regression;
- regression tree;
- random forest;
- XGBoost;
- SVM radial;
- kNN.

Evaluation is carried out through cross-validation, independent test metrics, REC curves and interpretation tools such as variable importance and SHAP-style local explanations.
