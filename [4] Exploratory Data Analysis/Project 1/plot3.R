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
png('plot3.png', width = 480, height = 480)
with(data, plot(Time, Sub_metering_1, type='l', xlab='', 
                ylab='Energy sub metering'))
with(data, lines(Time, Sub_metering_2, col='red'))
with(data, lines(Time, Sub_metering_3, col='blue'))
legend('topright', 
       legend = c('Sub_metering_1', 'Sub_metering_2', 'Sub_metering_3'),
       col = c('black', 'red', 'blue'),
       lwd = 1)
dev.off()
