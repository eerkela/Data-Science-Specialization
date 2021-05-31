## Eric Erkela
## Coursera Data Science Specialization
## Course 4: Exploratory Data Analysis
## Project 2: Case Study

library(dplyr)

# read data
NEI <- readRDS(file.path('exdata_data_NEI_data', 'summarySCC_PM25.rds'))

# subset data
NEI <- NEI %>%
  filter(fips == '24510') %>%
  group_by(year) %>%
  summarize(Emissions = sum(Emissions))

# plot data
png('plot2.png')
plot(NEI$year, NEI$Emissions, pch=19, cex = 1.5,
     xlab = 'Year', ylab = expression('Total PM'[2.5]*' emissions (tons)'))
title(main = expression('PM'[2.5]*' Emissions by year in Baltimore City, MD'))
abline(lm(NEI$Emissions ~ NEI$year), lwd=2, lty=2)
dev.off()