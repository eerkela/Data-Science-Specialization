## Eric Erkela
## Coursera Data Science Specialization
## Course 4: Exploratory Data Analysis
## Project 1: Making Plots

# load data:
source('read_data.R', local = TRUE)
# after this, we have a data.frame called 'data', which contains the date range
# subset we are actually interested in, with dates and times converted to the
# appropriate Date/Time classes

# Construct plot:
png('plot2.png', width = 480, height = 480)
with(data, plot(Time, Global_active_power, type='l', xlab='', 
                ylab='Global Active Power (kilowatts)'))
dev.off()
