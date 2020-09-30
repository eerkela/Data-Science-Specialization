## Eric Erkela
## Data Science Specialization

## SWIRL (Statistics with Interactive R Learning) is an R package
## developed by Nick Carchedi at Johns Hopkins department of
## bio-statistics meant to facilitate interactive learning of the R
## programming language.  It operates within the R console itself, so
## I created this script to automatically update and launch the swirl
## interactive learning environment.


## Make sure swirl is up to date:
install.packages("swirl")
packageVersion("swirl")

## Load swirl
library(swirl)

## Install courses
install_course("R Programming")
install_course("Getting and Cleaning Data")
install_course("Exploratory Data Analysis")
install_course("Regression Models")
install_course("Statistical Inference")

## Launch swirl
swirl()
