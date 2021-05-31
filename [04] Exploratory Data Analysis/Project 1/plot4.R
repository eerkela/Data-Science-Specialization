## Eric Erkela
## Coursera Data Science Specialization
## Course 4: Exploratory Data Analysis
## Project 1: Making Plots

# load data:
source('read_data.R', local = TRUE)
# after this, we have a data.frame called 'data', which contains the date range
# subset we are actually interested in, with dates and times converted to the
# appropriate Date/Time classes

# Construct plots:
png('plot4.png', width = 480, height = 480)
par(mfrow = c(2, 2))
# Plot 1
with(data, plot(Time, Global_active_power, type='l', 
                ylab='Global Active Power', xlab=''))
# Plot 2
with(data, plot(Time, Voltage, type='l', ylab='Voltage', xlab='datetime'))
# Plot 3
with(data, plot(Time, Sub_metering_1, type='l', xlab='', 
                ylab='Energy sub metering'))
with(data, lines(Time, Sub_metering_2, col='red'))
with(data, lines(Time, Sub_metering_3, col='blue'))
legend('topright', 
       legend = c('Sub_metering_1', 'Sub_metering_2', 'Sub_metering_3'),
       col = c('black', 'red', 'blue'),
       lwd = 1,
       bty = 'n')
# Plot 4
with(data, plot(Time, Global_reactive_power, type='l', xlab='datetime'))
dev.off()
