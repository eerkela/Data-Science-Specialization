---
title: "Reproducible Research: Peer Assessment 1"
output: 
  html_document:
    keep_md: true
---

It is now possible to collect a large amount of data about personal movement using activity monitoring devices such as a Fitbit, Nike Fuelband, or Jawbone Up. These type of devices are part of the “quantified self” movement – a group of enthusiasts who take measurements about themselves regularly to improve their health, to find patterns in their behavior, or because they are tech geeks. But these data remain under-utilized both because the raw data are hard to obtain and there is a lack of statistical methods and software for processing and interpreting the data.

This assignment makes use of data from a personal activity monitoring device. This device collects data at 5 minute intervals through out the day. The data consists of two months of data from an anonymous individual collected during the months of October and November, 2012 and include the number of steps taken in 5 minute intervals each day.

## Loading and preprocessing the data
Before analysis can begin, we must first access the data itself.  The following code chunk does exactly that.


```r
# Download data:
data_path <- 'activity.csv'
if (!file.exists(data_path)) {
  dat_url <- 'https://d396qusza40orc.cloudfront.net/repdata%2Fdata%2Factivity.zip'
  dest_file <- 'data.zip'
  download.file(dat_url, dest_file)
  unzip(dest_file)
  file.remove(dest_file)
  
  # Clean up workspace:
  rm(dat_url)
  rm(dest_file)
}

# Load data:
activity <- read.csv(data_path)
head(activity)
```

```
##   steps       date interval
## 1    NA 2012-10-01        0
## 2    NA 2012-10-01        5
## 3    NA 2012-10-01       10
## 4    NA 2012-10-01       15
## 5    NA 2012-10-01       20
## 6    NA 2012-10-01       25
```

Before we move on with our analysis, we will take this opportunity to coerce the interval identifiers in the base data set into a more easily interpreted format.


```r
convert_interval <- function(interval) {
  padded <- formatC(interval, width = '4', format = 'd', flag = '0')
  format(strptime(padded, format = '%H%M'), '%H:%M')
}
activity$interval <- as.factor(sapply(activity$interval, convert_interval))
```

Now if we take a look at the data set, we should see explicitly when each interval begins, rather than the ever-nebulous 'identifier'.


```r
head(activity)
```

```
##   steps       date interval
## 1    NA 2012-10-01    00:00
## 2    NA 2012-10-01    00:05
## 3    NA 2012-10-01    00:10
## 4    NA 2012-10-01    00:15
## 5    NA 2012-10-01    00:20
## 6    NA 2012-10-01    00:25
```

## What is mean total number of steps taken per day?
In order to answer this question, we must first manipulate our data to reflect the total number of steps taken per day.


```r
library(dplyr, warn.conflicts = FALSE)
total <- activity %>%
  group_by(date) %>%
  summarize(steps = sum(steps), .groups = 'drop')
head(total)
```

```
## # A tibble: 6 x 2
##   date       steps
##   <chr>      <int>
## 1 2012-10-01    NA
## 2 2012-10-02   126
## 3 2012-10-03 11352
## 4 2012-10-04 12116
## 5 2012-10-05 13294
## 6 2012-10-06 15420
```

Once we have our data in this format, we can visualize the total number of steps taken per day with a simple histogram.


```r
hist(total$steps,
     breaks = 10,
     main = 'Total Steps taken per day', 
     xlab = 'Steps', 
     ylab = '# of days')
abline(v = mean(total$steps, na.rm = TRUE), 
       lty = 'dashed', 
       col = 'blue')
```

![](PA1_template_files/figure-html/unnamed-chunk-5-1.png)<!-- -->

Where the dashed blue line is set at the mean number of steps taken across all days for which there is data available, with a value of: 


```r
mean(total$steps, na.rm = TRUE)
```

```
## [1] 10766.19
```

How about the median?


```r
median(total$steps, na.rm = TRUE)
```

```
## [1] 10765
```

As we can see, they're nearly identical. 

## What is the average daily activity pattern?
To answer this question, we need to reference the average number of steps taken in each 5-minute interval across the range of days we have data for.


```r
pattern <- activity %>%
  group_by(interval) %>%
  summarize(steps = mean(steps, na.rm = TRUE), .groups = 'drop')
```

Once we have formatted our data, we can make a time series plot directly showing the average daily activity pattern.


```r
labs <- pattern$interval[grepl(':00', pattern$interval)]
plot(x = pattern$interval, 
     y = pattern$steps, 
     main = 'Average Steps by Time of Day',
     xlab = 'Time of Day',
     ylab = 'Steps Taken',
     xaxt = 'n')
lines(x = pattern$interval, y = pattern$steps)
axis(side = 1, at = unclass(labs), labels = labs)
```

![](PA1_template_files/figure-html/unnamed-chunk-9-1.png)<!-- -->

As we can see, almost all activity seems to occur between the hours of 6:00 AM and 10:00 PM.  What interval contains the most activity on average?


```r
pattern[pattern$steps == max(pattern$steps), ]$interval
```

```
## [1] 08:35
## 288 Levels: 00:00 00:05 00:10 00:15 00:20 00:25 00:30 00:35 00:40 00:45 00:50 00:55 01:00 01:05 01:10 01:15 01:20 01:25 ... 23:55
```

It seems our subject is a morning person.

## Imputing missing values
Taking a quick look at the structure of the activity data set, we immediately notice the presence of missing values in the 'steps' column.  How many of these are there in total?


```r
sum(is.na(activity$steps))
```

```
## [1] 2304
```

As a proportion?


```r
mean(is.na(activity$steps))
```

```
## [1] 0.1311475
```

so roughly 13% of our data consists of missing values.  We can attempt to impute these missing values by replacing them with the mean activity for their interval.  We will do so in a new data set called 'imputed'.


```r
interval_mean <- function(interval) {
  pattern$steps[pattern$interval == interval]
}
missing <- is.na(activity$steps)
imputed <- activity
imputed$steps[missing] <- sapply(imputed$interval[missing], interval_mean)
```

If we now take a look at our activity data set, it should not contain no missing values after this operation.  Does it?


```r
head(imputed)
```

```
##       steps       date interval
## 1 1.7169811 2012-10-01    00:00
## 2 0.3396226 2012-10-01    00:05
## 3 0.1320755 2012-10-01    00:10
## 4 0.1509434 2012-10-01    00:15
## 5 0.0754717 2012-10-01    00:20
## 6 2.0943396 2012-10-01    00:25
```

```r
sum(is.na(imputed$steps))
```

```
## [1] 0
```

As we can see, the imputed data set now contains guesses for each of the activity set's missing values according to the mean number of steps for its corresponding interval.  With this data set, we can repeat our initial, mean total number of steps per day analysis to see if anything has changed with the addition of our imputed data.


```r
total2 <- imputed %>%
  group_by(date) %>%
  summarize(steps = sum(steps), .groups = 'drop')

hist(total2$steps,
     breaks = 10,
     main = 'Total Steps taken per day (missing values imputed)', 
     xlab = 'Steps', 
     ylab = '# of days')
abline(v = mean(total2$steps, na.rm = TRUE), 
       lty = 'dashed', 
       col = 'blue')
```

![](PA1_template_files/figure-html/unnamed-chunk-15-1.png)<!-- -->

And the means of our new, imputed data set are as follows:


```r
mean(total2$steps)
```

```
## [1] 10766.19
```

```r
median(total2$steps)
```

```
## [1] 10766.19
```

As might be expected with mean imputation, these measures have not shifted much.  Similarly, the shape of our histogram has stayed roughly the same, except that the bin containing the mean steps per day now has significantly more counts than it did previously.  The rest of the histogram appears to have been unaffected by the imputation procedure, but the extra 13% of observations that were missing from our original data set has seemingly all been absorbed into the mean bin.

## Are there differences in activity patterns between weekdays and weekends?
Using our new, imputed data set and the weekdays() function, we can add a factor that discriminates between observations gathered on weekdays from those gathered on weekends.


```r
get_day.type <- function(x) {
  formatted <- as.Date(x)
  if (weekdays(formatted) == 'Saturday' | weekdays(formatted) == 'Sunday') {
    'Weekend'
  } else {
    'Weekday'
  }
}
imputed$day.type <- as.factor(sapply(imputed$date, get_day.type))
```

We can now use this new day.type factor to create a panel plot comparing the two data sources.


```r
pattern2 <- imputed %>%
  group_by(interval, day.type) %>%
  summarize(steps = mean(steps, na.rm = TRUE), 
            day.type = day.type, 
            .groups = 'drop')

library(lattice)
labs <- pattern2$interval[grepl(':00', pattern2$interval)]
xyplot(steps ~ interval | day.type, 
       data = pattern2,
       type = 'l',
       main = 'Steps Taken by Time of Week (Weekday/Weekend)',
       xlab = 'Time of Day',
       ylab = 'Steps Taken',
       layout = c(1, 2),
       scales = list(x = list(at = unclass(labs), 
                              labels = labs, 
                              rot = 60)))
```

![](PA1_template_files/figure-html/unnamed-chunk-18-1.png)<!-- -->