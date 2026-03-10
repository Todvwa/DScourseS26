# PS5 

library(rvest)
library(tidyverse)
library(janitor)
library(readr)

#####################################
### Question 3: Web scraping data ###
#####################################

# Define the webpage URL
url <- "https://en.wikipedia.org/wiki/List_of_countries_by_number_of_languages"

#Read the HTML from the webpage
page <- read_html(url)

# CSS selector
language_table <- page %>%
  html_element("div table") %>%
  html_table()

# Preview table
head(language_table)

# Clean column names
language_table <- language_table %>%
  clean_names()

# Convert numeric columns from character to numeric
language_table <- language_table %>%
  mutate(
    established = parse_number(established),
    immigrant = parse_number(immigrant),
    total = parse_number(total),
    percent = parse_number(percent),
    total_speakers = parse_number(total_speakers),
    mean = parse_number(mean),
    median = parse_number(median)
  )

# Save the cleaned dataset
write.csv(language_table, "language_diversity_data.csv", row.names = FALSE)



##############################
### Question 4: API ACCESS ###
##############################

library(lubridate)
library(dplyr)
library(jsonlite)

# API endpoint for NYC Taxi trip data 
url <- "https://data.cityofnewyork.us/resource/m6nq-qud6.json?$limit=50000"

# Retrieve the JSON data from the API and convert it into an R data frame
fhv <- fromJSON(url)

# View the first few rows of dataset
head(fhv)

# Create a table : ride demand by hour
taxi_demand_hour <- fhv %>%
  
  # Convert pickup time variable into a proper datetime format
  mutate(pickup_time = ymd_hms(tpep_pickup_datetime),
         
         # Extract the hour of the day from the pickup time
         hour = hour(pickup_time)) %>%
  
  # Count number of trips in each hour 
  count(hour)

# Display the demand table
taxi_demand_hour