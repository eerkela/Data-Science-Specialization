## Eric Erkela
## Coursera Data Science Specialization
## Course 2: R Programming
## Programming Assignment 1: Air Pollution


pollutantmean <- function(directory, pollutant, id=1:332) {
  ## 'directory' is a character vector of length 1 indicating 
  ## the location of the CSV files.
  ## 'pollutant' is a character vector of length 1 indicating 
  ## the name of the pollutant for which we will calculate the 
  ## mean; either "sulfate" or "nitrate".
  ## 'id' is an integer vector indicating the monitor ID numbers 
  ## to be used.
  
  # Create a vector of all values in question.  We will append 
  # data to this vector and average at the end to cut down on total
  # operations, but this would not be a suitable solution if size in
  # memory were an issue.
  values <- vector()
  for (i in id) {
    filename <- sprintf("%03d.csv", i)
    path <- file.path(directory, filename)
    data <- read.csv(path)
    
    # append requested data to values
    if (tolower(pollutant) == "sulfate") {
      values <- append(values, data$sulfate)
    } else if (tolower(pollutant) == "nitrate") {
      values <- append(values, data$nitrate)
    }
  }
  
  mean(values, na.rm=TRUE)
}
