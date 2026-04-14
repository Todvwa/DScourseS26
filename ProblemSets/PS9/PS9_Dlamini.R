library(tidyverse)
library(tidymodels)
library(magrittr)
library(glmnet)

# Load housing data
housing <- read_table(
  "https://archive.ics.uci.edu/ml/machine-learning-databases/housing/housing.data",
  col_names = FALSE
)

names(housing) <- c(
  "crim","zn","indus","chas","nox","rm","age",
  "dis","rad","tax","ptratio","b","lstat","medv"
)

# Set seed
set.seed(123456)

# Divide data into training and test sets
housing_split <- initial_split(housing, prop = 0.8)
housing_train <- training(housing_split)
housing_test  <- testing(housing_split)

# Create recipe
housing_recipe <- recipe(medv ~ ., data = housing) %>%
  # convert outcome variable to logs
  step_log(all_outcomes()) %>%
  # convert 0/1 chas to a factor
  step_bin2factor(chas) %>%
  # create interaction term
  step_interact(
    terms = ~ crim:zn:indus:rm:age:rad:tax:ptratio:b:lstat:dis:nox
  ) %>%
  # create 6th degree polynomial terms
  step_poly(
    crim, zn, indus, rm, age, rad, tax, ptratio, b, lstat, dis, nox,
    degree = 6
  )

# Run the recipe
housing_prep <- housing_recipe %>%
  prep(housing_train, retain = TRUE)

housing_train_prepped <- housing_prep %>% juice
housing_test_prepped  <- housing_prep %>% bake(new_data = housing_test)

# Create x and y training and test data
housing_train_x <- housing_train_prepped %>% select(-medv)
housing_test_x  <- housing_test_prepped %>% select(-medv)
housing_train_y <- housing_train_prepped %>% select(medv)
housing_test_y  <- housing_test_prepped %>% select(medv)

# Dimension of training data and number of X variables
dim(housing_train_prepped)
ncol(housing_train_x)
ncol(housing_train_x) - 13

########
# LASSO
########

# Specify model
lasso_spec <- linear_reg(
  penalty = tune(),
  mixture = 1
) %>%
  set_engine("glmnet") %>%
  set_mode("regression")

# Define a grid over which to try different values of lambda
lambda_grid <- grid_regular(penalty(), levels = 50)

# 6-fold cross-validation
rec_folds <- vfold_cv(housing_train_prepped, v = 6)

# Workflow
lasso_wf <- workflow() %>%
  add_formula(medv ~ .) %>%
  add_model(lasso_spec)

# Tuning results
lasso_res <- lasso_wf %>%
  tune_grid(
    resamples = rec_folds,
    grid = lambda_grid
  )

# Optimal lambda
top_lasso_rmse  <- show_best(lasso_res, metric = "rmse")
best_lasso_rmse <- select_best(lasso_res, metric = "rmse")

top_lasso_rmse
best_lasso_rmse

# Train with tuned lambda
final_lasso <- finalize_workflow(lasso_wf, best_lasso_rmse)

lasso_fit <- final_lasso %>%
  fit(data = housing_train_prepped)

# Predict RMSE in sample
lasso_fit %>%
  predict(housing_train_prepped) %>%
  mutate(truth = housing_train_prepped$medv) %>%
  rmse(truth, .pred) %>%
  print

# Predict RMSE out of sample
lasso_fit %>%
  predict(housing_test_prepped) %>%
  mutate(truth = housing_test_prepped$medv) %>%
  rmse(truth, .pred) %>%
  print

###########
# RIDGE
##########

# Specify model
ridge_spec <- linear_reg(
  penalty = tune(),
  mixture = 0
) %>%
  set_engine("glmnet") %>%
  set_mode("regression")

# Workflow
ridge_wf <- workflow() %>%
  add_formula(medv ~ .) %>%
  add_model(ridge_spec)

# Tuning results
ridge_res <- ridge_wf %>%
  tune_grid(
    resamples = rec_folds,
    grid = lambda_grid
  )

# Optimal lambda
top_ridge_rmse  <- show_best(ridge_res, metric = "rmse")
best_ridge_rmse <- select_best(ridge_res, metric = "rmse")

top_ridge_rmse
best_ridge_rmse

# Train with tuned lambda
final_ridge <- finalize_workflow(ridge_wf, best_ridge_rmse)

ridge_fit <- final_ridge %>%
  fit(data = housing_train_prepped)

# Predict RMSE out of sample
ridge_fit %>%
  predict(housing_test_prepped) %>%
  mutate(truth = housing_test_prepped$medv) %>%
  rmse(truth, .pred) %>%
  print


