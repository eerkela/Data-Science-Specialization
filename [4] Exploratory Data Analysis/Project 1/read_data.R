## Eric Erkela
## Coursera Data Science Specialization
## Course 4: Exploratory Data Analysis
## Project 1: Making Plots

# load the full dataset:
root_dir <- 'exdata_data_household_power_consumption'
data_path <- file.path(root_dir, 'household_power_consumption.txt')
raw_data <- read.table(data_path, sep=';', header=TRUE, na.strings='?')

# subset the date range we are interested in (2007-02-01 - 2007-02-02) and 
# convert to date objects
library(dplyr)
data <- raw_data %>%
  filter(Date %in% c('1/2/2007', '2/2/2007')) %>%
  mutate(Date=strptime(paste(Date, Time), format='%d/%m/%Y %H:%M:%S')) %>%
  select(-Time) %>%
  rename(Time = Date)

# clean up workspace
remove(root_dir)
remove(data_path)
remove(raw_data)