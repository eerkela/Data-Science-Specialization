## Eric Erkela
## Coursera Data Science Specialization
## Course 3: Getting and Cleaning Data
## Quiz 2

#1 Using the Github API
library(httr)
oauth_endpoints("github")
myapp <- oauth_app("github",
                   key = "Iv1.cdf6a7be590b45cc",
                   secret = "7fb83a492830e9203b7e4397942636e29482067f",
                   redirect_uri = "http://localhost:1410"
)
github_token <- oauth2.0_token(oauth_endpoints("github"), myapp)
gtoken <- config(token = github_token)

request_url <- "https://api.github.com/users/jtleek/repos"
req <- with_config(gtoken, GET(request_url))
stop_for_status(req)
content <- content(req)
repo <- content[[which(sapply(content, function(x) x$name == "datasharing"))]]
repo$created_at


#2 practicing sql commands
library(sqldf)
url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fdata%2Fss06pid.csv"
dest_file <- "ACS_Data.csv"
download.file(url, dest_file)

acs <- read.csv(dest_file)conventional <- acs[acs$AGEP < 50, ]$pwgtp1
practice_sql <- sqldf("select pwgtp1 from acs where AGEP < 50",
                      host="localhost", user="root")
all.equal(conventional, practice_sql$pwgtp1)


#3 practicing sql commands (cont.)
conventional <- unique(acs$AGEP)
practice_sql <- sqldf("select distinct AGEP from acs", user="root")
all.equal(conventional, practice_sql$AGEP)

file.remove(dest_file)


#4 Raw Web Scraping
connection <- url("http://biostat.jhsph.edu/~jleek/contact.html")
html <- readLines(connection)
nchar(html[c(10, 20, 30, 100)])


#5 Reading Fixed-width file formats (.for)
url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fwksst8110.for"
dest_file <- "Test_NOAA_data.for"
download.file(url, dest_file)
dat <- read.fwf(dest_file, widths = c(15, 4, 9, 4, 9, 4, 9, 4, 9), skip = 4,
                col.names = c("week", "nino1and2.SST", "nino1and2.SSTA",
                              "nino3.SST", "nino3.SSTA", "nino34.SST", 
                              "nino34.SSTA", "nino4.SST", "nino4.SSTA"))
sum(dat[4])
file.remove(dest_file)
