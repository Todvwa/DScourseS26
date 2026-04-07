
#################################
### ECON 5253 - Problem Set 8 ###
#################################

## Packages

library(nloptr)
library(modelsummary)


set.seed(100)

N <- 100000
K <- 10
sigma <- 0.5

cat("Simulation parameters set.\n")
cat("N =", N, "K =", K, "sigma =", sigma, "\n")


## Generate X matrix

X <- matrix(rnorm(N * K), nrow = N, ncol = K)
X[, 1] <- 1   # first column is intercept

cat("Generated X matrix.\n")
cat("dim(X):", dim(X), "\n")


## True beta vector

beta_true <- c(1.5, -1, -0.25, 0.75, 3.5, -2, 0.5, 1, 1.25, 2)

cat("Defined beta_true.\n")
cat("length(beta_true):", length(beta_true), "\n")


## Generate epsilon and Y

eps <- rnorm(N, mean = 0, sd = sigma)
Y <- X %*% beta_true + eps

cat("Generated eps and Y.\n")
cat("length(Y):", length(Y), "\n")


### Debugging checks
stopifnot(nrow(X) == N)
stopifnot(ncol(X) == K)
stopifnot(length(beta_true) == K)
stopifnot(length(Y) == N)

cat("Basic dimension checks passed.\n")

######################
# 5: Closed-form OLS
######################
cat("\nStarting closed-form OLS...\n")

beta_ols <- solve(t(X) %*% X) %*% t(X) %*% Y
beta_ols <- as.vector(beta_ols)

cat("Closed-form OLS complete.\n")

###########################
# 6: Gradient Descent OLS
###########################
cat("\nStarting gradient descent...\n")

ols_obj <- function(beta, X, Y) {
  sum((Y - X %*% beta)^2)
}

ols_grad <- function(beta, X, Y) {
  # gradient of sum of squared residuals
  as.vector(-2 * t(X) %*% (Y - X %*% beta))
}

beta_gd <- rep(0, K)
learning_rate <- 0.0000003
max_iter <- 2000

obj_history <- numeric(max_iter)

for (iter in 1:max_iter) {
  grad <- ols_grad(beta_gd, X, Y)
  beta_gd <- beta_gd - learning_rate * grad
  obj_history[iter] <- ols_obj(beta_gd, X, Y)
  
  # debugging 
  if (iter %% 250 == 0) {
    cat("Got here: iteration", iter, 
        "| objective =", obj_history[iter], "\n")
  }
}

cat("Gradient descent complete.\n")

#################################
# 7. a): OLS via nloptr - L-BFGS
#################################
cat("\nStarting nloptr L-BFGS for OLS...\n")

ols_eval_f <- function(beta, Y, X) {
  sum((Y - X %*% beta)^2)
}

ols_eval_grad_f <- function(beta, Y, X) {
  as.vector(-2 * t(X) %*% (Y - X %*% beta))
}

res_lbfgs <- nloptr(
  x0 = rep(0, K),
  eval_f = ols_eval_f,
  eval_grad_f = ols_eval_grad_f,
  Y = Y,
  X = X,
  opts = list(
    algorithm = "NLOPT_LD_LBFGS",
    xtol_rel = 1e-8,
    maxeval = 1000
  )
)

beta_lbfgs <- res_lbfgs$solution

cat("L-BFGS complete.\n")

######################################
# 7. b): OLS via nloptr - Nelder-Mead
######################################
cat("\nStarting nloptr Nelder-Mead for OLS...\n")

res_nm <- nloptr(
  x0 = rep(0, K),
  eval_f = ols_eval_f,
  Y = Y,
  X = X,
  opts = list(
    algorithm = "NLOPT_LN_NELDERMEAD",
    xtol_rel = 1e-8,
    maxeval = 2000
  )
)

beta_nm <- res_nm$solution

cat("Nelder-Mead complete.\n")

##############################
# 8: MLE via nloptr - L-BFGS
##############################
cat("\nStarting MLE with L-BFGS...\n")

# Objective
mle_eval_f <- function(theta, Y, X) {
  beta <- theta[1:(length(theta) - 1)]
  sig  <- theta[length(theta)]
  
  
  if (sig <= 0) return(1e20)
  
  resid <- as.vector(Y - X %*% beta)
  
  
  n <- length(Y)
  nll <- (n / 2) * log(2 * pi) + n * log(sig) + sum(resid^2) / (2 * sig^2)
  
  return(nll)
}

# Gradient
mle_grad <- function(theta, Y, X) {
  grad <- as.vector(rep(0, length(theta)))
  beta <- theta[1:(length(theta) - 1)]
  sig  <- theta[length(theta)]
  
  grad[1:(length(theta) - 1)] <- -t(X) %*% (Y - X %*% beta) / (sig^2)
  grad[length(theta)] <- nrow(X) / sig - crossprod(Y - X %*% beta) / (sig^3)
  
  return(as.vector(grad))
}

theta0 <- c(rep(0, K), 1)

# Optimization
res_mle <- nloptr(
  x0 = theta0,
  eval_f = mle_eval_f,
  eval_grad_f = mle_grad,
  Y = Y,
  X = X,
  opts = list(
    algorithm = "NLOPT_LD_LBFGS",
    xtol_rel = 1e-8,
    maxeval = 2000
  )
)

theta_hat <- res_mle$solution
beta_mle <- theta_hat[1:K]
sigma_mle <- theta_hat[K + 1]

cat("MLE complete.\n")
cat("Estimated sigma from MLE:", sigma_mle, "\n")

######################
# 9: OLS: using lm ()
######################
cat("\nStarting lm() estimation...\n")

model_lm <- lm(Y ~ X - 1)

cat("lm() complete.\n")


# Compare estimates to truth

results_compare <- data.frame(
  beta_true = beta_true,
  beta_ols = beta_ols,
  beta_gd = beta_gd,
  beta_lbfgs = beta_lbfgs,
  beta_nm = beta_nm,
  beta_mle = beta_mle,
  beta_lm = coef(model_lm)
)

results_compare$ols_error <- results_compare$beta_ols - results_compare$beta_true
results_compare$gd_error <- results_compare$beta_gd - results_compare$beta_true
results_compare$lbfgs_error <- results_compare$beta_lbfgs - results_compare$beta_true
results_compare$nm_error <- results_compare$beta_nm - results_compare$beta_true
results_compare$mle_error <- results_compare$beta_mle - results_compare$beta_true
results_compare$lm_error <- results_compare$beta_lm - results_compare$beta_true

cat("\nComparison of true beta and estimated beta:\n")
print(round(results_compare, 6))


# Export regression table

library(modelsummary)

tab <- modelsummary(
  list("OLS" = model_lm),
  output = "latex_tabular",
  title = NULL,
  stars = TRUE,
  fmt = 3
)
writeLines(as.character(tab), "PS8_table.tex")

cat("Export complete: PS8_table.tex\n")


