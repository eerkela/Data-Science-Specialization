## Eric Erkela
## Coursera Data Science Specialization
## Course 4: Exploratory Data Analysis
## Project 2: Case Study

library(dplyr)

# read data
NEI <- readRDS(file.path('exdata_data_NEI_data', 'summarySCC_PM25.rds'))

# subset data
NEI <- NEI %>%
  group_by(year) %>%
  summarize(Emissions = sum(Emissions))

# plot data
png('plot1.png')
plot(NEI$year, NEI$Emissions, pch=19, cex = 1.5,
     xlab = 'Year', 
     ylab = expression('Total PM'[2.5]*' emissions from all sources (tons)'))
title(main = expression('PM'[2.5]*' Emissions by Year'))
abline(lm(NEI$Emissions ~ NEI$year), lwd=2, lty=2)
dev.off()
