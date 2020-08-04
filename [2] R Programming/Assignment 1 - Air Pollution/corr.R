## Eric Erkela
## Coursera Data Science Specialization
## Course 2: R Programming
## Programming Assignment 1: Air Pollution


corr <- function(directory, threshold=0) {
  ## 'directory' is a character vector of length 1 indicating
  ## the location of the CSV files
  ## 'threshold' is a numeric vector of length 1 indicating the
  ## number of completely observed obervations (on all
  ## variables) required to compute the correlation between 
  ## nitrate and sulfate; the default is 0
  
  correlations <- vector()
  for (i in 1:332) {
    filename <- sprintf("%03d.csv", i)
    path <- file.path(directory, filename)
    data <- read.csv(path)
    
    if (sum(complete.cases(data)) > threshold) {
      corr <- cor(data$sulfate, data$nitrate, use="complete.obs")
      correlations <- append(correlations, corr)
    }
  }
  
  correlations
}

