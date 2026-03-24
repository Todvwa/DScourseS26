# Loading libraries
library(tidyverse)
library(ggplot2)
library(dplyr)
library(stringr)

# Read dataset
LD_Data <- read.csv("language_diversity_data.csv")

## Data Cleaning

# Remove first row
LD_Data <- LD_Data[-1, ]

# Rename columns
LD_Data <- LD_Data %>%
  dplyr::rename(
    est_lang = number_of_living_languages,
    imm_lang = number_of_living_languages_2,
    total_lang = number_of_living_languages_3,
    world_lang_pct = number_of_living_languages_4,
    total_speakers = number_of_speakers,
    mean_speakers = number_of_speakers_2,
    median_speakers = number_of_speakers_3
  )

# Clean data: convert character variables to numeric
LD_Data <- LD_Data %>%
  dplyr::mutate(across(
    c(est_lang, imm_lang, total_lang, world_lang_pct,
      total_speakers, mean_speakers, median_speakers),
    ~ as.numeric(str_replace_all(., "[^0-9.]", ""))
  ))

# Check structure
colnames(LD_Data)
str(LD_Data)

# Create top 10 dataset
top_lang <- LD_Data %>%
  arrange(desc(total_lang)) %>%
  slice(1:10)

# Visualization 1: Top 10 most linguistically diverse countries
plot_a <- ggplot(top_lang, aes(x = reorder(country_or_territory, total_lang), y = total_lang)) +
  geom_col(fill = "steelblue") +
  coord_flip() +
  labs(
    title = "Top 10 Most Linguistically Diverse Countries",
    x = "",
    y = "Number of Languages"
  ) +
  theme_minimal()

ggsave("PS6a_Dlamini.png", plot = plot_a, width = 8, height = 5)

# Visualization 2: Linguistic diversity and language size
plot_b <- ggplot(LD_Data, aes(x = total_lang, y = median_speakers)) +
  geom_point(alpha = 0.6, color = "black") +
  geom_smooth(method = "lm", se = FALSE, color = "blue") +
  scale_y_log10() +
  labs(
    title = "Linguistic Diversity and Language Size",
    x = "Total Number of Languages",
    y = "Median Speakers per Language (Log Scale)"
  ) +
  theme_minimal()

ggsave("PS6b_Dlamini.png", plot = plot_b, width = 8, height = 5)

# Visualization 3: Distribution of median speakers
plot_c <- ggplot(LD_Data, aes(x = median_speakers)) +
  geom_histogram(bins = 30, fill = "darkgreen", color = "white") +
  scale_x_log10() +
  labs(
    title = "Distribution of Median Speakers per Language",
    x = "Median Speakers (Log Scale)",
    y = "Frequency"
  ) +
  theme_minimal()

ggsave("PS6c_Dlamini.png", plot = plot_c, width = 8, height = 5)