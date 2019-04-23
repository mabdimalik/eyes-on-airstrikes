library(shiny)
library(shinydashboard)
library(shinyjs)
library(shinyWidgets)
library(tidyverse)
library(DT)
library(leaflet)
library(ggplot2)

load(file = "data/all_raids.RData")

region_choices <- unique(air_raids$region)
state_choices <- unique(air_raids$state)
year_choices <- unique(air_raids$year)
target_choices <- unique(air_raids$target)

pie_data <- air_raids %>% group_by(state) %>% summarise(n=n()) %>% filter(n>2) %>% 
  mutate(value = n/sum(n)) %>% arrange(desc(n))


db_colors <- c("#00C0EF", "#985B43", "#222D32", "#EF2F00", "#A30083")

display_names <- dplyr::tribble(~data_name, ~display_name,
                         "event_date", "Airstrike Date",
                         "year", "Year",
                         "strike_by", "Attacking Entity",
                         "target", "Target Organization",
                         "state", "Regional State",
                         "region", "Region",
                         "district", "District",
                         "location", "Location",
                         "source", "Source",
                         "fatalities", "Fatalities"
                         )

show_names <- function(nms) {
  nms_tbl <- data_frame(data_name = nms)
  
  nms_tbl <- dplyr::left_join(nms_tbl, display_names, by = "data_name") %>%
    mutate(display_name = ifelse(is.na(display_name), data_name, display_name))
  nms_tbl$display_name
}
