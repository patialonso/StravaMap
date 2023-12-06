# Strava Activity Mapping with R

This R script connects to the Strava API, retrieves activity data, filters and processes it, and creates a map visualization using the leaflet package. The resulting map shows the start points of running activities.


## Getting Started

### Prerequisites

Before running the script, make sure you have the following:

1. **Strava API Credentials:** You need to obtain your Strava API credentials, including your Client ID and Client Secret, from [Strava Developer Settings](https://www.strava.com/settings/api).

2. **Athlete ID:** Replace 'your_athlete_id' in the script with your actual Strava Athlete ID. You can find your Athlete ID on your Strava profile page or retrieve it programmatically through the Strava API.

3. **R Packages:** Ensure the required R packages are installed:

    ```R
    install.packages(c("shiny", "tarchetypes", "conflicted", "tidyverse", "lubridate", 
                       "jsonlite", "targets", "httpuv", "httr", "pins", "fs", "readr", 
                       "writexl", "tibble", "dplyr", "ggplot2", "leaflet", "htmlwidgets", 
                       "stringr", "psych", "openxlsx"))
    ```

### Usage

1. Replace the placeholder values in the script with your actual Strava API credentials and Athlete ID.
2. Run the script.

## Features

- Connects to the Strava API and retrieves activity data.
- Filters and processes activity data to focus on running activities.
- Creates an interactive leaflet map showing the start points of the activities.

## Contributing

If you have suggestions or find any issues, feel free to open an issue or submit a pull request.



