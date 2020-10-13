## Eric Erkela
## Coursera Data Science Specialization
## Course 4: Exploratory Data Analysis
## Project 2: Case Study

library(dplyr)
library(ggplot2)

# read data
NEI <- readRDS(file.path('exdata_data_NEI_data', 'summarySCC_PM25.rds'))

# subset data
NEI <- NEI %>%
  filter(fips == '24510') %>%
  group_by(type, year) %>%
  summarize(Emissions = sum(Emissions))

# plot data
png('plot3.png')
g <- ggplot(NEI, aes(year, Emissions))
g + 
  facet_wrap(. ~ type, scales='free') + 
  geom_point() + 
  geom_smooth(formula=y~x,
              method='lm') + 
  labs(x = 'Year', 
       y = expression('Total PM'[2.5]*' Emissions (tons)'), 
       title = expression('PM'[2.5]*' Emissions by Source Type in Baltimore City, MD'))
dev.off()
