## Eric Erkela
## Coursera Data Science Specialization
## Course 3: Getting and Cleaning Data
## Quiz 1


#1 csv data:
url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fdata%2Fss06hid.csv"
dest_file <- "ACS_2006_microdata_survey_housing_ID.csv"
code_book <- "https://d396qusza40orc.cloudfront.net/getdata%2Fdata%2FPUMSDataDict06.pdf"
download.file(url, dest_file, method = "curl")
dat <- read.csv(dest_file)
sum(dat$VAL == 24, na.rm = TRUE)
file.remove(dest_file)


#3 excel data:
library(xlsx)
url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fdata%2FDATA.gov_NGAP.xlsx"
dest_file <- "Natural_Gas_Aquisition_Program.xlsx"
download.file(url, dest_file, method = "curl")
dat <- read.xlsx(dest_file, sheetIndex=1, 
                 header=TRUE, rowIndex=18:23, colIndex=7:15)
sum(dat$Zip * dat$Ext, na.rm=TRUE)
file.remove(dest_file)

#4 XML data:
library(XML)
url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fdata%2Frestaurants.xml"
dest_file <- "Baltimore_Restaurants.xml"
download.file(url, dest_file)
doc <- xmlTreeParse(dest_file, useInternal=TRUE)
rootNode <- xmlRoot(doc)
zipcodes <- xpathSApply(rootNode, "//zipcode", xmlValue)
sum(zipcodes == "21231")
file.remove(dest_file)

#5 data.table package
library(data.table)
url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fdata%2Fss06pid.csv"
dest_file <- "ACS_2006_microdata_survey_housing_ID_2.csv"
download.file(url, dest_file)
DT <- fread(dest_file)
system.time(mean(DT$pwgtp15, by=DT$SEX))
system.time({mean(DT[DT$SEX==1,]$pwgtp15); mean(DT[DT$SEX==2,]$pwgtp15)})
system.time(sapply(split(DT$pwgtp15, DT$SEX), mean))
system.time(tapply(DT$pwgtp15, DT$SEX, mean))
system.time({rowMeans(DT)[DT$SEX==1]; rowMeans(DT)[DT$SEX==2]})
system.time(DT[, mean(pwgtp15), by=SEX])
