library(caret)
library(dplyr)
library(forcats)
library(tidyr)

prepare_regression_target <- function(data) {
  data %>%
    filter(!is.na(Price)) %>%
    filter(Price >= 1000, Price <= 1000000) %>%
    mutate(log_Price = log(Price))
}

prepare_regression_predictors <- function(data) {
  data %>%
    mutate(
      Brand_top = fct_lump_n(factor(Brand), n = 20, other_level = "Other"),
      Model_top = fct_lump_n(factor(Model), n = 50, other_level = "Other"),
      Location_top = fct_lump_n(factor(Location), n = 30, other_level = "Other"),
      Sector_top = fct_lump_n(factor(Sector), n = 50, other_level = "Other")
    ) %>%
    select(
      log_Price,
      Year,
      Condition_num,
      Mileage_mean,
      Fiscal.Power,
      Gearbox,
      Origin,
      First.Owner,
      Fuel,
      Number.of.Doors,
      Brand_top,
      Model_top,
      Location_top,
      Sector_top,
      equip_security,
      equip_driving_assist,
      equip_comfort,
      equip_tech
    ) %>%
    drop_na()
}

build_regression_matrices <- function(data, seed = 123) {
  set.seed(seed)
  id_train <- createDataPartition(data$log_Price, p = 0.7, list = FALSE)
  train_raw <- data[id_train, , drop = FALSE]
  test_raw <- data[-id_train, , drop = FALSE]

  dummies <- dummyVars(log_Price ~ ., data = train_raw, fullRank = TRUE)
  x_train <- as.data.frame(predict(dummies, newdata = train_raw))
  x_test <- as.data.frame(predict(dummies, newdata = test_raw))
  x_test <- x_test[, colnames(x_train), drop = FALSE]

  list(
    x_train = x_train,
    x_test = x_test,
    y_train = train_raw$log_Price,
    y_test = test_raw$log_Price
  )
}

# In the original coursework, the following families were compared:
# - linear regression
# - regression tree
# - random forest
# - XGBoost
# - SVM radial
# - kNN

# Exact training in the original environment depended on private data
# and stored RDS objects, so this public script focuses on the workflow structure.
