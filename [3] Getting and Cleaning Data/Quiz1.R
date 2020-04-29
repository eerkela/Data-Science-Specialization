## Eric Erkela
## Coursera Data Science Specialization
## Course 3: Getting and Cleaning Data
## Quiz 1

## Question 1
coursename <- "[3] Getting and Cleaning Data/"
url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fdata%2Fss06hid.csv"
filename <- "ACS_2006_microdata_survey_ID.csv"

download.file(as.character(url), file.path(coursename, filename))
data <- read.csv(file.path(coursename, filename))
sum(data$VAL == 24)
