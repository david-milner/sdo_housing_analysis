# Introduction -----------------------------------------------------------------
# Created on: 2026/05/24
# Author: David Milner
# R Version: 4.0.0
# Description: This script will be used to clean Ammerican Community Survey data
# and to spatialize data from Colorado's State Demographer's Office (SDO)


# Packages ---------------------------------------------------------------------
library(dplyr)
library(ggplot2)
library(readr)
library(readxl)
library(shiny)
library(glue)
library(tidyr)
library(lubridate)
library(bslib)
library(ggExtra)
library(sf)
library(stringr)
library(leaflet)
library(janitor)
library(jsonlite)
library(purrr)
library(tidycensus)

select <- dplyr::select

# Directories ------------------------------------------------------------------
dirs <- list()
dirs$base <- file.path("~/R/colorado_housing")
dirs$rwd <- file.path("~/R/colorado_housing/rwd")
dirs$outputs <- file.path("~/R/colorado_housing/outputs")

# Global Options ---------------------------------------------------------------

# Set the global options for the analysis file
global_options = list()
global_options$state = "Colorado"


# Functions --------------------------------------------------------------------

# find_longitude AND find_latitude
# Call R's {state.} data and defines the latitude and longitude of the chosen 
# state. This will become the center of the leaflet() map. The input "location"  
# will be the global_options$state defined above. 

find_longitude <- function(location) {
  centers <- data.frame(
    state = state.name, # state.name provides the full names of the states
    longitude = state.center$x,
    latitude = state.center$y
  ) %>% filter(state == location)
  
  return(centers$longitude)
}

find_latitude <- function(location) {
  centers <- data.frame(
    state = state.name, # state.name provides the full names of the states
    longitude = state.center$x,
    latitude = state.center$y
  ) %>% filter(state == location)
  
  return(centers$latitude)
}


# mround
# Similar to the excel function, this accepts a number and a rounding base.

mround <- function(x,base){
  base*round(x/base)
}

