# PS4b: sparklyr exercise

library(sparklyr)
library(tidyverse)

# Connect to Spark
sc <- spark_connect(master = "local")

# Create tibble df1 from iris
df1 <- as_tibble(iris)

# Copy to Spark as df
df <- copy_to(sc, df1, overwrite = TRUE)

# Verify different object types
cat("class(df1):\n")
print(class(df1))
cat("\nclass(df):\n")
print(class(df))

# Compare column names
cat("\nColumn names in df1:\n")
print(names(df1))
cat("\nColumn names in df:\n")
print(names(df))

# first 6 rows of Sepal_Length and Species
cat("\nSelect Sepal_Length and Species (head):\n")
df %>%
  select(Sepal_Length, Species) %>%
  head() %>%
  print()

# filter first 6 rows where Sepal_Length > 5.5
cat("\nFilter Sepal_Length > 5.5 (head):\n")
df %>%
  filter(Sepal_Length > 5.5) %>%
  head() %>%
  print()

# select and filter in one pipeline
cat("\nFilter + Select together (head):\n")
df %>%
  filter(Sepal_Length > 5.5) %>%
  select(Sepal_Length, Species) %>%
  head() %>%
  print()

# group_by summarize
cat("\nGroup by Species: mean Sepal_Length and count:\n")
df2 <- df %>%
  group_by(Species) %>%
  summarize(mean = mean(Sepal_Length), count = n())

df2 %>% head() %>% print()

# arrange 
cat("\nArrange by Species (may error on OSCER):\n")
try({
  df2 %>% arrange(Species) %>% head() %>% print()
}, silent = TRUE)

# Disconnect
spark_disconnect(sc)
