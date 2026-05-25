# Introduction -----------------------------------------------------------------
# Created on: 2026/05/24
# Author: David Milner
# R Version: 4.0.0
# Description: This script will ingest 1-year data from the American Community
# Survey, and organize and clean the data.

# Initialization ---------------------------------------------------------------
# Source the init file with libraries and packages
source(file = "~/colorado_housing_analysis/00_init.R")

# tidycensus inputs
api_path <- read_file(glue("~/R/docs/api_census_key.txt"))
census_api_key(key = api_path, install = FALSE)


# Load 5-YR ACS ---------------------------------------------------------------
# Relative inputs to retrieve 1-Year ACS data from relevant survey tables
acs_groups <- c(2010, 2015, 2020)
rel_state <- "CO"
table_12mo_income <- "S1901"

# Variables for median and average household income
rel_vars <- c("S1901_C01_012", "S1901_C01_013")

# Create a blank list to load the data into
acs_data <- list()

# Use a for loop to bring census data into the blank list
for (i in 1:length(acs_groups)) {
  acs_data[[i]] <- get_acs(
    geography = "county",
#    table = table_12mo_income,
    variables = rel_vars,
    year = acs_groups[i],
    state = rel_state,
    survey = "acs5",
    geometry = FALSE
  ) %>% mutate(acs_vintage = glue("{acs_groups[i]-4}-{acs_groups[i]}"),
               acs_vintage_end = acs_groups[i])
}

data_dict <- data.frame(
  variable = rel_vars,
  var_name = c("median_income", "mean_income")
)


acs_data_comb <- acs_data %>% bind_rows() %>% left_join(data_dict)
acs_data_comb_mean <- acs_data_comb %>% filter(var_name == "mean_income")
acs_data_comb_median <- acs_data_comb %>% filter(var_name == "median_income")


# Export Data ------------------------------------------------------------------

write_csv(x = acs_data_comb, 
          file = glue("{dirs$rwd}/acs_data_comb_{today()}.csv"))

write_csv(x = acs_data_comb_mean, 
          file = glue("{dirs$rwd}/acs_data_comb_mean_{today()}.csv"))

write_csv(x = acs_data_comb_median, 
          file = glue("{dirs$rwd}/acs_data_comb_median_{today()}.csv"))

