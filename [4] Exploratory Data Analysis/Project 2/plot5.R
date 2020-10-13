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
  filter(fips == '24510') %>%
  filter(grepl('Highway Vehicles.*', SCC.Level.Two)) %>%
  group_by(SCC.Level.Two, year) %>%
  summarize(Emissions = sum(Emissions))

# plot data
png('plot5.png')
g <- ggplot(combined, aes(year, Emissions))
g + 
  geom_point(aes(color=SCC.Level.Two), size=3) + 
  geom_smooth(formula=y~x,
              method='lm',
              data=subset(combined, SCC.Level.Two == 'Highway Vehicles - Diesel'),
              aes(color=SCC.Level.Two),
              se=FALSE) +
  geom_smooth(formula=y~x,
              method='lm',
              data=subset(combined, SCC.Level.Two == 'Highway Vehicles - Gasoline'),
              aes(color=SCC.Level.Two),
              se=FALSE) +
  geom_smooth(formula=y~x,
              method='lm',
              linetype='dashed',
              color='black',
              se=FALSE) + 
  labs(x = 'Year', 
       y = expression('Total PM'[2.5]*' Emissions (tons)'), 
       title = expression('Motor Vehicle PM'[2.5]*' emissions in Baltimore City, MD'))
dev.off()
