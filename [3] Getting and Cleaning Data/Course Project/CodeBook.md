---
title: "CodeBook.md"
author: "Eric Erkela"
date: "9/29/2020"
output: html_document
---

# Parent Dataset
The data in tidy.txt is derived from the UCI Human Activity Recognition (HAR) Using Smartphones Dataset, collected by:

Jorge L. Reyes-Ortiz, Davide Anguita, Alessandro Ghio, Luca Oneto. 
Smartlab - Non Linear Complex Systems Laboratory 
DITEN - Università degli Studi di Genova. 
Via Opera Pia 11A, I-16145, Genoa, Italy. 
activityrecognition@smartlab.ws 
www.smartlab.ws

The experiments have been carried out with a group of 30 volunteers within an age bracket of 19-48 years. Each person performed six activities (WALKING, WALKING_UPSTAIRS, WALKING_DOWNSTAIRS, SITTING, STANDING, LAYING) wearing a smartphone (Samsung Galaxy S II) on the waist. Using its embedded accelerometer and gyroscope, we captured 3-axial linear acceleration and 3-axial angular velocity at a constant rate of 50Hz. The experiments have been video-recorded to label the data manually. The obtained dataset has been randomly partitioned into two sets, where 70% of the volunteers was selected for generating the training data and 30% the test data.

The sensor signals (accelerometer and gyroscope) were pre-processed by applying noise filters and then sampled in fixed-width sliding windows of 2.56 sec and 50% overlap (128 readings/window). The sensor acceleration signal, which has gravitational and body motion components, was separated using a Butterworth low-pass filter into body acceleration and gravity. The gravitational force is assumed to have only low frequency components, therefore a filter with 0.3 Hz cutoff frequency was used. From each window, a vector of features was obtained by calculating variables from the time and frequency domain.

## Initial Contents
The features selected for this database come from the accelerometer and gyroscope 3-axial raw signals tAcc-XYZ and tGyro-XYZ. These time domain signals (prefix 't' to denote time) were captured at a constant rate of 50 Hz. Then they were filtered using a median filter and a 3rd order low pass Butterworth filter with a corner frequency of 20 Hz to remove noise. Similarly, the acceleration signal was then separated into body and gravity acceleration signals (tBodyAcc-XYZ and tGravityAcc-XYZ) using another low pass Butterworth filter with a corner frequency of 0.3 Hz.

Subsequently, the body linear acceleration and angular velocity were derived in time to obtain Jerk signals (tBodyAccJerk-XYZ and tBodyGyroJerk-XYZ). Also the magnitude of these three-dimensional signals were calculated using the Euclidean norm (tBodyAccMag, tGravityAccMag, tBodyAccJerkMag, tBodyGyroMag, tBodyGyroJerkMag).

Finally a Fast Fourier Transform (FFT) was applied to some of these signals producing fBodyAcc-XYZ, fBodyAccJerk-XYZ, fBodyGyro-XYZ, fBodyAccJerkMag, fBodyGyroMag, fBodyGyroJerkMag. (Note the 'f' to indicate frequency domain signals).

These signals were used to estimate variables of the feature vector for each pattern:
'-XYZ' is used to denote 3-axial signals in the X, Y and Z directions.

| Feature           |
|:------------------|
| tBodyAcc-XYZ      |
| tGravityAcc-XYZ   |
| tBodyAccJerk-XYZ  |
| tBodyGyro-XYZ     |
| tBodyGyroJerk-XYZ |
| tBodyAccMag       |
| tGravityAccMag    |
| tBodyAccJerkMag   |
| tBodyGyroMag      |
| tBodyGyroJerkMag  |
| fBodyAcc-XYZ      |
| fBodyAccJerk-XYZ  |
| fBodyGyro-XYZ     |
| fBodyAccMag       |
| fBodyAccJerkMag   |
| fBodyGyroMag      |
| fBodyGyroJerkMag  |

The set of variables that were estimated from these signals are:

| Measure       | Meaning                                                                      |
|:--------------|:-----------------------------------------------------------------------------|
| mean()        | Mean value                                                                   |
| std()         | Standard deviation                                                           |
| mad()         | Median absolute deviation                                                    |
| max()         | Largest value in array                                                       |
| min()         | Smallest value in array                                                      |
| sma()         | Signal magnitude area                                                        |
| energy()      | Energy measure. Sum of the squares divided by the number of values.          |
| iqr()         | Interquartile range                                                          |
| entropy()     | Signal entropy                                                               |
| arCoeff()     | Autorregresion coefficients with Burg order equal to 4                       |
| correlation() | correlation coefficient between two signals                                  |
| maxInds()     | index of the frequency component with largest magnitude                      |
| meanFreq()    | Weighted average of the frequency components to obtain a mean frequency      |
| skewness()    | skewness of the frequency domain signal                                      |
| kurtosis()    | kurtosis of the frequency domain signal                                      |
| bandsEnergy() | Energy of a frequency interval within the 64 bins of the FFT of each window. |
| angle()       | Angle between to vectors.                                                    |

Additional vectors obtained by averaging the signals in a signal window sample. These are used on the angle() variable:

| Variable          |
|:------------------|
| gravityMean       | 
| tBodyAccMean      |
| tBodyAccJerkMean  |
| tBodyGyroMean     |
| tBodyGyroJerkMean |

================================================================================

# Cleaning and Preliminary Analysis
The steps taken to convert from the initial dataset described above to tidy.txt were as follows:

1. Recreate the initial training and test datasets separately, using the descriptive feature names found in features.txt (and described above) as column labels. Invalid characters (such as parentheses) were stripped from the feature labels in the process.
2. Map the activity labels (1, 2, ...) in each dataset to their physical descriptions using the information in activity_labels.txt.
3. Merge the training and test data sets into a single data.frame.
4. Extract only the mean and standard deviation for each measurement (excluding measures of meanFreq) and append them to an intermediary data.frame.
5. Group the results by subject id and activity, and collapse each record into a single mean measure for each subject/activity pair.
6. Save the results as a space-separated .txt file (tidy.txt)

## Variables
A table of all variables (and their units) present in tidy.txt is provided below

Note: A backslash "/" character indicates an OR operation for sake of compactness.  As such, a measure such as tBodyAcc.mean.X/Y/Z refers to three separate variables: tBodyAcc.mean.X, tBodyAcc.mean.Y, and tBodyAcc.mean.Z

| Variable					                   | Unit                       |
|:-------------------------------------|:---------------------------|
| "subject"			                       | numeric (identifier, 1-30) |          
| "activity"                           | string factor ("WALKING", "WALKING_UPSTAIRS", "WALKING_DOWNSTAIRS", "SITTING", "STANDING", "LAYING") |
| "tBodyAcc.mean.X/Y/Z"				         | g                          |
| "tBodyAcc.std.X/Y/Z"				         | g                          |
| "tGravityAcc.mean.X/Y/Z"             | g                          |
| "tGravityAcc.std.X/Y/Z"              | g                          |
| "tBodyAccJerk.mean.X/Y/Z"            | g/s                        |
| "tBodyAccJerk.std.X/Y/Z"             | g/s                        |
| "tBodyGyro.mean.X/Y/Z"               | rad/s                      |
| "tBodyGyro.std.X/Y/Z"                | rad/s                      |
| "tBodyGyroJerk.mean.X/Y/Z"           | rad/s^2                    |
| "tBodyGyroJerk.std.X/Y/Z"            | rad/s^2                    |
| "tBodyAccMag.mean"                   | g                          |
| "tBodyAccMag.std"                    | g                          |
| "tGravityAccMag.mean"                | g                          |
| "tGravityAccMag.std"                 | g                          |
| "tBodyAccJerkMag.mean"               | g/s                        |
| "tBodyAccJerkMag.std"                | g/s                        |
| "tBodyGyroMag.mean"                  | rad/s                      |
| "tBodyGyroMag.std"                   | rad/s                      |
| "tBodyGyroJerkMag.mean"              | rad/s^2                    |
| "tBodyGyroJerkMag.std"               | rad/s^2                    |
| "fBodyAcc.mean.X/Y/Z"                | 1/g                        |
| "fBodyAcc.std.X/Y/Z"				         | 1/g                        |
| "fBodyAccJerk.mean.X/Y/Z"			       | 1/(g*s)                    |
| "fBodyAccJerk.std.X/Y/Z"			       | 1/(g*s)                    |
| "fBodyGyro.mean.X/Y/Z"				       | s/rad                      |
| "fBodyGyro.std.X/Y/Z"				         | s/rad                      |
| "fBodyAccMag.mean"                   | 1/g                        |
| "fBodyAccMag.std"                    | 1/g                        |
| "fBodyBodyAccJerkMag.mean"           | 1/(g*s)                    |
| "fBodyBodyAccJerkMag.std"            | 1/(g*s)                    |
| "fBodyBodyGyroMag.mean"              | s/rad                      |
| "fBodyBodyGyroMag.std"               | s/rad                      |
| "fBodyBodyGyroJerkMag.mean"          | 1/rad                      |
| "fBodyBodyGyroJerkMag.std"           | 1/rad                      |
| "angletBodyAccMean.gravity"          | rad                        |
| "angletBodyAccJerkMean.gravityMean"  | rad                        |
| "angletBodyGyroMean.gravityMean"     | rad                        |
| "angletBodyGyroJerkMean.gravityMean" | rad                        |
| "angleX/Y/Z.gravityMean"			       | rad                        |
