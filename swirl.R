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

## Launch swirl
swirl()
