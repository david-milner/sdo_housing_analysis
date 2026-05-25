# Introduction -----------------------------------------------------------------
# Created on: 2026/05/25
# Author: David Milner
# R Version: 4.0.0
# Description: This script will ingest ZHVI data from Zillow and tidy it for use 
# in a later analysis script

# Initialization ---------------------------------------------------------------
# Source the init file with libraries and packages
source(file = "~/sdo_housing_analysis/00_init.R")


# Load ZHVI Data ---------------------------------------------------------------
raw_zhvi <- read.csv(
  file = glue("~/sdo_housing_analysis/source_data/zillow/\\
              County_zhvi_uc_sfrcondo_tier_0.33_0.67_sm_sa_month_clean.csv"))


# Tidy ZHVI Data ---------------------------------------------------------------

# Take the raw ZHVI data and pivot longer, add lubridate() dates
clean_zhvi_data <- raw_zhvi %>% pivot_longer(
  cols = starts_with("X"),
  values_to = "median_home_value_$") %>% mutate(
    date = mdy(str_extract(name, "(?<=X).*")),
    year = year(date)
  )

# Identify the unique counties in the data set
regions <- clean_zhvi_data$RegionName %>% unique()

# Create a blank list to fill with data for each county
regions_unique <- list()

# Fill the list with the yearly data for each county
for (i in regions) {
  regions_unique[[i]] <- clean_zhvi_data %>% filter(RegionName == i)
}

# Export Tidy Data -------------------------------------------------------------

# Create and export a combined ZHVI data set with clean column names
zhvi_comb_data <- clean_zhvi_data %>% clean_names()

write_csv(x = zhvi_comb_data, 
          file = glue("{dirs$rwd}/zhvi_comb_data_{today()}.csv")
)

# Create and export individual ZHVI data sets with clean column names
exp_df <- list()

for (i in 1:length(regions_unique)) {
  sheet_name <- names(regions_unique[i]) %>% to_snake_case()
  exp_df <- regions_unique[[i]] %>% clean_names()
  write_csv(x = exp_df,
            file = glue("{dirs$rwd}/zhvi_data_{sheet_name}_{today()}.csv")
            )
}
  
  


