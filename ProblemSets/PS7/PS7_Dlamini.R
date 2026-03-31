library(mice)
library(modelsummary)
library(tidyverse)

# Load the data
wages <- read_csv("wages.csv")

glimpse(wages)

# Drop missing hgc or tenure
wages_clean <- wages %>%
  filter(!is.na(hgc), !is.na(tenure))


# Summary table + missingness

# Summary table
datasummary_skim(wages_clean, output = "summary_table.tex")


# Rate of missing logwage
mean(is.na(wages_clean$logwage)) * 100
  

# Imputation and Regression
logwage ~ hgc + college + tenure + I(tenure^2) + age + married


# Complete Case
model_cc <- lm(logwage ~ hgc + college + tenure + I(tenure^2) + age + married,
               data = wages_clean)

# Mean Imputation
wages_mean <- wages_clean
mean_logwage <- mean(wages_mean$logwage, na.rm = TRUE)
wages_mean$logwage[is.na(wages_mean$logwage)] <- mean_logwage
model_mean <- lm(logwage ~ hgc + college + tenure + I(tenure^2) + age + married,
                 data = wages_mean)

# Regression Imputation
# Use complete cases
complete_cases <- wages_clean %>% drop_na(logwage)

model_pred <- lm(logwage ~ hgc + college + tenure + I(tenure^2) + age + married,
                 data = complete_cases)
# Predict missing
wages_pred <- wages_clean
missing_index <- is.na(wages_pred$logwage)

wages_pred$logwage[missing_index] <-
  predict(model_pred, newdata = wages_pred[missing_index, ])

# Final regression
model_regimp <- lm(logwage ~ hgc + college + tenure + I(tenure^2) + age + married,
                   data = wages_pred)

# Multiple Imputation
imputed <- mice(wages_clean, m = 5, method = "pmm", seed = 123)

model_mice <- with(imputed,
                   lm(logwage ~ hgc + college + tenure + I(tenure^2) + age + married))

pooled <- pool(model_mice)


# Combining all models
modelsummary(
  list(
    "Complete Case" = model_cc,
    "Mean Imputation" = model_mean,
    "Regression Imputation" = model_regimp,
    "Multiple Imputation" = pooled
  ),
  output = "regression_table.tex"
)
