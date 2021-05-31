## Eric Erkela
## Coursera Data Science Specialization
## Course 3: Getting and Cleaning Data
## Course Project: Getting and Cleaning Data


library(stringr)
root_dir <- "UCI HAR Dataset"
activity_map <- read.table(file.path(root_dir, "activity_labels.txt"))
feature_map <- read.table(file.path(root_dir, "features.txt"))
features <- sapply(feature_map[,2], function(f){str_replace_all(f, "[()]", "")})

get_activities <- function(path) {
  convert <- function(label) {
    activity_map[activity_map$V1 == label, 2]
  }
  labels <- scan(path)
  sapply(labels, convert)
}

build_table <- function(path) {
  table <- read.table(path)
  colnames(table) <- features
  table
}

# Build test set
subjects <- scan(file.path(root_dir, "test", "subject_test.txt"))
activities <- get_activities(file.path(root_dir, "test", "y_test.txt"))
table <- build_table(file.path(root_dir, "test", "X_test.txt"))
test_set <- data.frame("subject" = subjects, "activity" = activities, table)

# Build training set
subjects <- scan(file.path(root_dir, "train", "subject_train.txt"))
activities <- get_activities(file.path(root_dir, "train", "y_train.txt"))
table <- build_table(file.path(root_dir, "train", "X_train.txt"))
train_set <- data.frame("subject" = subjects, "activity" = activities, table)

# Unify
data <- merge(test_set, train_set, all=TRUE)
write.table(data, "merged.txt")

# Extract means
library(dplyr)
filtered <- select(data, matches("^subject|^activity|std|mean[^(Freq)]|mean$"))

# Construct final dataset
final <- filtered %>%
  group_by(subject, activity) %>% 
  summarize_all(mean)
write.table(final, "tidy.txt", row.name=FALSE)
