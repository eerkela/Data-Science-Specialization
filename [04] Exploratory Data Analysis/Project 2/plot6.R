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
  filter(fips == '24510' | fips == '06037') %>%
  filter(grepl('Highway Vehicles.*', SCC.Level.Two)) %>%
  group_by(fips, SCC.Level.Two, year) %>%
  summarize(Emissions = sum(Emissions))

convert_fips <- function(fips) {
  # convert fips id into county name
  if (fips == '24510') {
    'Baltimore City, MD'
  } else {
    'Los Angeles County, CA'
  }
}

# makes fips ids informative:
combined$fips <- sapply(combined$fips, convert_fips)

# plot data
png('plot6.png')
g <- ggplot(combined, aes(year, Emissions))
g + 
  facet_wrap(. ~ fips, scales='free') +
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
       title = expression('Motor Vehicle PM'[2.5]*' emissions in Baltimore City, MD vs LA County, CA')) + 
  theme(legend.position='bottom')
dev.off()
