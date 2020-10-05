## Eric Erkela
## Coursera Data Science Specialization
## Course 3: Getting and Cleaning Data
## Quiz 3

# 1
url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fdata%2Fss06hid.csv"
dest_file <- "ACS_2006_Housing_ID.csv"
download.file(url, dest_file)

acs <- read.csv(dest_file)
agricultureLogical <- acs$ACR == 3 & acs$AGS == 6
which(agricultureLogical)
file.remove(dest_file)

# 2
library(jpeg)
url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fjeff.jpg"
dest_file <- "Jeff.jpg"
download.file(url, dest_file, mode="wb")

image <- readJPEG(dest_file, native=TRUE)
quantile(image, probs=c(0.3, 0.8))
file.remove(dest_file)

# 3
url1 <- "https://d396qusza40orc.cloudfront.net/getdata%2Fdata%2FGDP.csv"
url2 <- "https://d396qusza40orc.cloudfront.net/getdata%2Fdata%2FEDSTATS_Country.csv"
dest_file1 <- "World_Bank_GDP.csv"
dest_file2 <- "World_Bank_edu.csv"
download.file(url1, dest_file1)
download.file(url2, dest_file2)

GDP <- read.csv(dest_file1, header=TRUE, skip=4, nrows=190)
edu <- read.csv(dest_file2)
GDP$X.4 <- as.numeric(str_replace_all(GDP$X.4, ",", ""))
sum(edu$CountryCode %in% GDP$X)
GDP[order(GDP$X.4, decreasing=FALSE), 4][13]

# 4
countries <- edu[edu$Income.Group == "High income: OECD", ]$CountryCode
mean(GDP[GDP$X %in% countries, 2])
countries <- edu[edu$Income.Group == "High income: nonOECD", ]$CountryCode
mean(GDP[GDP$X %in% countries, 2])

# 5
lower_middle_income <- edu[edu$Income.Group == "Lower middle income", ]$CountryCode
quants <- quantile(GDP$X.4, probs=seq(0.2, 1, 0.2))
highest_gdp <- GDP[GDP$X.4 > quants[4], ]$X
sum(lower_middle_income %in% highest_gdp)

file.remove(dest_file1)
file.remove(dest_file2)
