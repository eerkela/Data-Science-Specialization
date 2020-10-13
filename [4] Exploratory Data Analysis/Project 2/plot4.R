## Eric Erkela
## Coursera Data Science Specialization
## Course 4: Exploratory Data Analysis
## Project 2: Case Study

library(dplyr)
library(ggplot2)

# read data
NEI <- readRDS(file.path('exdata_data_NEI_data', 'summarySCC_PM25.rds'))
SCC <- readRDS(file.path('exdata_data_NEI_data', 'Source_Classification_Code.rds'))
combined <- merge(NEI, SCC, by='SCC')

# subset data
combined <- combined %>%
  filter(grepl('Fuel Comb.*Coal', EI.Sector)) %>%
  group_by(EI.Sector, year) %>%
  summarize(Emissions = sum(Emissions)) %>%
  transmute(year=year, 
            Emissions=Emissions, 
            EI.Sector=gsub('Fuel Comb - | - Coal', '', EI.Sector))

# plot data
png('plot4.png')
g <- ggplot(combined, aes(year, Emissions))
g + 
  facet_wrap(. ~ EI.Sector, scales='free') + 
  geom_point() + 
  geom_smooth(formula=y~x,
              method='lm') + 
  labs(x = 'Year', 
       y = expression('Total PM'[2.5]*' Emissions (tons)'), 
       title = expression('Coal Combustion-Related PM'[2.5]*' Emissions by year'))
dev.off()
