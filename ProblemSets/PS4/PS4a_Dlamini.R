# Download JSON using wget
system('wget -O dates.json "https://www.vizgr.org/historical-events/search.php?format=json&begin_date=00000101&end_date=20240209&lang=en"')

# Print file to console
system('cat dates.json')

# Load libraries
library(jsonlite)
library(tidyverse)

# Convert JSON to list
mylist <- fromJSON('dates.json')

# Convert list to dataframe
mydf <- bind_rows(mylist$result[-1])

# Check object types
class(mydf)
class(mydf$date)

# Show first rows
head(mydf)
