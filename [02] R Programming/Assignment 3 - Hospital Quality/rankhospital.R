## Eric Erkela
## Coursera Data Science Specialization
## Course 2: R Programming
## Programming Assignment 3: Hospital Quality

# In: state (str), the abbreviation of the state to subset
#     outcome (str), "heart attack" | "heart failure" | "pneumonia"
#     num (numeric), requested hospital ranking
# Out: name (str) of hospital in the requested state with <num>-placed 30 day
#      mortality rate for the specified outcome.  If ties are encountered, 
#      alphabetically sorts results and returns the first observation.
rankhospital <- function(state, outcome, num = "best") {
  data <- read.csv("outcome-of-care-measures.csv", colClasses = "character")
  
  if (!toupper(state) %in% data$State) {
    stop("invalid state")
  }
  
  sub <- subset(data, data$State == toupper(state))
  if (tolower(outcome) == "heart attack") {
    rate <- sub$Hospital.30.Day.Death..Mortality..Rates.from.Heart.Attack
  } else if (tolower(outcome) == "heart failure") {
    rate <- sub$Hospital.30.Day.Death..Mortality..Rates.from.Heart.Failure
  } else if (tolower(outcome) == "pneumonia") {
    rate <- sub$Hospital.30.Day.Death..Mortality..Rates.from.Pneumonia
  } else {
    stop("invalid outcome")
  }
  sub <- sub[order(as.numeric(rate), sub$Hospital.Name, na.last=NA), ]
  
  if (is.character(num)) {
    if (tolower(num) == "best") {
      num <- 1
    } else if (tolower(num) == "worst") {
      num <- length(sub$Hospital.Name)
    } else {
      stop("invalid num")
    }
  } else if (num > length(sub$Hospital.Name)) {
    return(NA)
  }
  
  sub$Hospital.Name[num]
}