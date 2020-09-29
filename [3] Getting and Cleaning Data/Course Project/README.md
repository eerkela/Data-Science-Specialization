# Getting-and-Cleaning-Data-Course-Project
This repository contains a cleaned subset of the UCI HAR dataset (tidy.txt), extracted from that dataset via run_analysis.R.

## run_analysis.R
run_analysis.R is the script that was used to translate the parent, UCI dataset to the cleaned subset found in tidy.txt.  No intermediate were taken either before or after execution of this script; all manipulations that were done to arrive at the final, tidy dataset were performed within run_analysis.R.

A procedure describing the steps taken to arrive at tidy.txt is provided below and in codebook.txt.

1. Recreate the initial training and test datasets separately, using the descriptive feature names found in features.txt (and described above) as column labels.  Invalid characters (such as parentheses) were stripped from the feature labels in the process. 
2. Map the activity labels (1, 2, ...) in each dataset to their physical descriptions using the information in activity_labels.txt.
3. Merge the training and test data sets into a single data.frame.
4. Extract only the mean and standard deviation for each measurement (excluding measures of meanFreq) and append them to an intermediary data.frame.
5. Group the results by subject id and activity, and collapse each record into a single mean measure for each subject/activity pair.
6. Save the results as a space-separated .txt file (tidy.txt)

## CodeBook.md
CodeBook.md contains the following: a detailed description of the initial dataset, a procedure similar to the one provided above, and a complete list of variables (along with their units) that are present in tidy.txt.
