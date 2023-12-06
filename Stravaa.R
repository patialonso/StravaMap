# Install and load required packages
#install.packages(c( "tarchetypes", "conflicted", "tidyverse", "lubridate", 
                   "jsonlite", "targets", "httpuv", "httr", "pins", "fs", "readr", 
                   "writexl", "tibble", "dplyr", "ggplot2", "leaflet", "htmlwidgets", 
                   "stringr", "psych", "openxlsx"))

# Load required libraries
library(tarchetypes)
library(conflicted)
library(tidyverse)
library(lubridate)
library(jsonlite)
library(targets)
library(httpuv)
library(httr)
library(pins)
library(fs)
library(readr)
library(writexl)
library(tibble)
library(dplyr)
library(ggplot2)
library(leaflet)
library(htmlwidgets)
library(stringr)
library(psych)
library(openxlsx)

# Define Strava App
define_strava_app <- function() {
  oauth_app(
    appname = "r_api",
    key = "your_client_id",  # Replace with your Client ID
    secret = "your_client_secret"  # Replace with your Client Secret
  )
}

# Define Strava Endpoint
define_strava_endpoint <- function() {
  oauth_endpoint(request = NULL,
                 authorize = "https://www.strava.com/oauth/authorize",
                 access = "https://www.strava.com/oauth/token")
}

# Define Strava Signature
define_strava_sig <- function(endpoint, app) {
  oauth2.0_token(
    endpoint,
    app,
    scope = "activity:read_all,activity:read,profile:read_all",
    type = NULL,
    use_oob = FALSE,
    as_header = FALSE,
    use_basic_auth = FALSE,
    cache = FALSE
  )
}

# Read All Activities
read_all_activities <- function(sig) {
  activities_url <- parse_url("https://www.strava.com/api/v3/athlete/activities")
  
  act_vec <- vector(mode = "list")
  df_act <- tibble::tibble(init = "init")
  i <- 1L
  
  while (nrow(df_act) != 0) {
    r <- activities_url %>%
      modify_url(query = list(
        access_token = sig$credentials$access_token[[1]],
        page = i
      )) %>%
      GET()
    
    df_act <- content(r, as = "text") %>%
      fromJSON(flatten = TRUE) %>%
      as_tibble()
    
    if (nrow(df_act) != 0)
      act_vec[[i]] <- df_act
    
    i <- i + 1L
  }
  
  df_activities <- act_vec %>%
    bind_rows() %>%
    mutate(start_date = ymd_hms(start_date))
}

# Read Activity Stream
read_activity_stream <- function(id, sig) {
  act_url <-
    parse_url(stringr::str_glue("https://www.strava.com/api/v3/activities/{id}/streams"))
  access_token <- sig$credentials$access_token[[1]]
  
  r <- modify_url(act_url,
                  query = list(
                    access_token = access_token,
                    keys = str_glue(
                      "distance,time,latlng,altitude,velocity_smooth,cadence,watts,",
                      "temp,moving,grade_smooth"
                    )
                  )) %>%
    GET()
  
  stop_for_status(r)
  
  fromJSON(content(r, as = "text"), flatten = TRUE) %>%
    as_tibble() %>%
    mutate(id = id)
}

# Pre-process Activity
pre_process_act <- function(df_act_raw, athlete_id) {
  df_act <- df_act_raw %>%
    mutate(across(contains("id"), as.character),
           `athlete.id` = athlete_id)
}

# Replace 'YOUR_ATHLETE_ID' with the actual athlete ID
athlete_id <- 'your_athlete_id'

# Fetch all activities for the specified athlete
sig <- define_strava_sig(define_strava_endpoint(), define_strava_app())
df_activities <- read_all_activities(sig)
view(df_activities)

# Save the activity data to an Excel file
write.xlsx(df_activities, file = "actividadesStrava.xlsx")

# Filter rows based on sport_type and start_date
df_activities <- df_activities %>%
  dplyr::filter(sport_type == "Run" & start_date >= ymd_hms("2022-09-06T15:01:53"))

# Save the filtered activity data to an Excel file
write.xlsx(df_activities, file = "actividadesStrava_filtered.xlsx")

# Read the filtered activity data from the Excel file
actividadesStrava <- read_excel("actividadesStrava_filtered.xlsx")

# Remove rows with missing data in end_latlng
actividadesStrava <- actividadesStrava[complete.cases(actividadesStrava$end_latlng), ]

# Split start_latlng and end_latlng into latitude and longitude
start_latlng_split <- str_split(actividadesStrava$start_latlng, ", ", simplify = TRUE)
end_latlng_split <- str_split(actividadesStrava$end_latlng, ", ", simplify = TRUE)

# Assign the latitude and longitude values to new columns
actividadesStrava$start_lat <- as.numeric(start_latlng_split[, 1])
actividadesStrava$start_lng <- as.numeric(start_latlng_split[, 2])
actividadesStrava$end_lat <- as.numeric(end_latlng_split[, 1])
actividadesStrava$end_lng <- as.numeric(end_latlng_split[, 2])

# Map Visualization with Points
leaflet_map <- leaflet(actividadesStrava) %>%
  addTiles() %>%
  setView(lng = mean(actividadesStrava$start_lng), lat = mean(actividadesStrava$start_lat), zoom = 12) %>%
  addCircleMarkers(
    lng = ~start_lng,
    lat = ~start_lat,
    color = "red",
    radius = 5,
    popup = ~str_glue(
      "<b>{name}</b><br>Date: {format(start_date, '%Y-%m-%d %H:%M:%S')}<br>Distance: {distance} km<br>Elevation gain: {total_elevation_gain} m"
    )
  )

# Save the leaflet map with points as an HTML file
saveWidget(leaflet_map, file = "map_with_points.html", selfcontained = TRUE)
