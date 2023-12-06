# StravaMap
# Strava Activity Mapping with R

This R script connects to the Strava API, retrieves activity data, filters and processes it, and creates a map visualization using the leaflet package. 
The resulting map shows the start points of running activities.



### Prerequisites

Before running the script, make sure you have the following R packages installed:

```R
install.packages(c("tarchetypes", "conflicted", "tidyverse", "lubridate", 
                   "jsonlite", "targets", "httpuv", "httr", "pins", "fs", "readr", 
                   "writexl", "tibble", "dplyr", "ggplot2", "leaflet", "htmlwidgets", 
                   "stringr", "psych", "openxlsx"))
