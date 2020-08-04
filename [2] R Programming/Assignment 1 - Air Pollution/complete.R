## Eric Erkela
## Coursera Data Science Specialization
## Course 2: R Programming
## Programming Assignment 1: Air Pollution


complete <- function(directory, id=1:332) {
  ## 'directory' is a character vector of length 1 indicating
  ## the location of the CSV files.
  ## 'id' is an integer vector indicating the monitor ID numbers 
  ## to be used.
  
  nobs <- vector()
  for (i in id) {
    filename <- sprintf("%03d.csv", i)
    path <- file.path(directory, filename)
    data <- read.csv(path)
    
    nobs <- append(nobs, sum(complete.cases(data)))
  }
  
  data.frame(id, nobs)
}