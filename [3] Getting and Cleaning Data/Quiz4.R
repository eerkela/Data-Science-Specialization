## Eric Erkela
## Coursera Data Science Specialization
## Course 3: Getting and Cleaning Data
## Quiz 4

# 1
url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fdata%2Fss06hid.csv"
dest_file <- "ACS_2006_Housing_ID.csv"
download.file(url, dest_file)
ACS <- read.csv(dest_file)
strsplit(colnames(ACS), "wgtp")[123]
file.remove(dest_file)

# 2
url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fdata%2FGDP.csv"
dest_file <- "GDP190.csv"
download.file(url, dest_file)
GDP <- read.csv(dest_file, header=TRUE, skip=4, nrows=190)
GDP$X.4 <- as.numeric(str_replace_all(GDP$X.4, ",", ""))
mean(GDP$X.4)

# 3
length(grep("^United", GDP$X.3))

# 4
url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fdata%2FEDSTATS_Country.csv"
dest_file2 <- "EDU.csv"
download.file(url, dest_file2)
EDU <- read.csv(dest_file2)
length(grep("Fiscal year end: June", EDU$Special.Notes))

file.remove(dest_file)
file.remove(dest_file2)

# 5
library(quantmod)
amzn <- getSymbols("AMZN", auto.assign=FALSE)
sampleTimes <- index(amzn)
sum(format(sampleTimes, "%Y") == "2012")
sum(format(sampleTimes, "%A %Y") == "Monday 2012")
