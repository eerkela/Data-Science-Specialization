## Eric Erkela
## Coursera Data Science Specialization
## Course 2: R Programming
## Programming Assignment 3: Hospital Quality

# In: outcome (str), "heart attack" | "heart failure" | "pneumonia"
#     num (numeric), requested hospital ranking
# Out: data.frame with 2 columns (hospital, state) containing the hospital in 
#      each state that has the ranking specified by num for the given outcome.
rankall <- function(outcome, num = "best") {
  data <- read.csv("outcome-of-care-measures.csv", colClasses = "character")
  
  results <- data.frame(hospital = vector(), state = vector())
  
  state <- vector()
  hospital <- vector()
  for (s in sort(unique(data$State))) {
    sub <- subset(data, data$State == s)
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
        choice <- sub$Hospital.Name[1]
      } else if (tolower(num) == "worst") {
        choice <- sub$Hospital.Name[length(sub$Hospital.Name)]
      } else {
        stop("invalid num")
      }
    } else if (num > length(sub$Hospital.Name)) {
      choice <- NA
    } else {
      choice <- sub$Hospital.Name[num]
    }
    hospital <- c(hospital, choice)
    state <- c(state, s)
  }
  
  data.frame(hospital, state)
}