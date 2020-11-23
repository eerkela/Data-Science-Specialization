Executive Summary
=================

Using devices such as the *Jawbone Up*, *Nike FuelBand*, and *Fitbit*,
it is now possible to collect a large amount of data about personal
activity relatively inexpensively. One consequence of this abundance of
data is a newfound ability to not just analyze but predict - in relative
detail - the characteristics of the everyday activities that their users
perform. The goal of this project will be to apply this predictive
capability as it relates to fitness data. Using data collected via
wearable accelerometers, we will develop a machine learning model to
predict whether or not a given subject is performing a barbell lift
correctly, and if not, categorize the error(s) they are performing into
a variety of classes.

Dependencies
------------

Reproduced below is the list of all packages necessary for this
analysis:

    require(caret, quietly = TRUE)

    ## Warning: package 'caret' was built under R version 4.0.3

    require(parallel, quietly = TRUE)
    require(doParallel, quietly = TRUE)

    ## Warning: package 'doParallel' was built under R version 4.0.3

    ## Warning: package 'foreach' was built under R version 4.0.3

    ## Warning: package 'iterators' was built under R version 4.0.3

    set.seed(12345)   # for reproducibility

Loading and Cleaning Data
=========================

The data for this project come from the Weight Lifting Exercise (WLE)
dataset, produced by Velloso et al (2013), which has graciously been
made available to the public. The data consist of readings from 4
accelerometers mounted on the belt, forearm, arm, and dumbbell of 6
study participants, each of whom were asked to perform barbell lifts
correctly and incorrectly in 5 different ways. More information on this
dataset can be found at the following url:
<a href="https://web.archive.org/web/20161224072740/http:/groupware.les.inf.puc-rio.br/har" class="uri">https://web.archive.org/web/20161224072740/http:/groupware.les.inf.puc-rio.br/har</a>.
The original publication that the data is associated with can be found
here:
<a href="https://web.archive.org/web/20170519033209/http://groupware.les.inf.puc-rio.br/public/papers/2013.Velloso.QAR-WLE.pdf" class="uri">https://web.archive.org/web/20170519033209/http://groupware.les.inf.puc-rio.br/public/papers/2013.Velloso.QAR-WLE.pdf</a>

First, we must load the dataset itself:

    training <- read.csv("https://d396qusza40orc.cloudfront.net/predmachlearn/pml-training.csv")
    testing <- read.csv("https://d396qusza40orc.cloudfront.net/predmachlearn/pml-testing.csv")
    dim(training)

    ## [1] 19622   160

As we can see, our training dataset is quite large (19622 records of 160
different variables). The names of the variables we have access to are
given by:

    names(training)

    ##   [1] "X"                        "user_name"               
    ##   [3] "raw_timestamp_part_1"     "raw_timestamp_part_2"    
    ##   [5] "cvtd_timestamp"           "new_window"              
    ##   [7] "num_window"               "roll_belt"               
    ##   [9] "pitch_belt"               "yaw_belt"                
    ##  [11] "total_accel_belt"         "kurtosis_roll_belt"      
    ##  [13] "kurtosis_picth_belt"      "kurtosis_yaw_belt"       
    ##  [15] "skewness_roll_belt"       "skewness_roll_belt.1"    
    ##  [17] "skewness_yaw_belt"        "max_roll_belt"           
    ##  [19] "max_picth_belt"           "max_yaw_belt"            
    ##  [21] "min_roll_belt"            "min_pitch_belt"          
    ##  [23] "min_yaw_belt"             "amplitude_roll_belt"     
    ##  [25] "amplitude_pitch_belt"     "amplitude_yaw_belt"      
    ##  [27] "var_total_accel_belt"     "avg_roll_belt"           
    ##  [29] "stddev_roll_belt"         "var_roll_belt"           
    ##  [31] "avg_pitch_belt"           "stddev_pitch_belt"       
    ##  [33] "var_pitch_belt"           "avg_yaw_belt"            
    ##  [35] "stddev_yaw_belt"          "var_yaw_belt"            
    ##  [37] "gyros_belt_x"             "gyros_belt_y"            
    ##  [39] "gyros_belt_z"             "accel_belt_x"            
    ##  [41] "accel_belt_y"             "accel_belt_z"            
    ##  [43] "magnet_belt_x"            "magnet_belt_y"           
    ##  [45] "magnet_belt_z"            "roll_arm"                
    ##  [47] "pitch_arm"                "yaw_arm"                 
    ##  [49] "total_accel_arm"          "var_accel_arm"           
    ##  [51] "avg_roll_arm"             "stddev_roll_arm"         
    ##  [53] "var_roll_arm"             "avg_pitch_arm"           
    ##  [55] "stddev_pitch_arm"         "var_pitch_arm"           
    ##  [57] "avg_yaw_arm"              "stddev_yaw_arm"          
    ##  [59] "var_yaw_arm"              "gyros_arm_x"             
    ##  [61] "gyros_arm_y"              "gyros_arm_z"             
    ##  [63] "accel_arm_x"              "accel_arm_y"             
    ##  [65] "accel_arm_z"              "magnet_arm_x"            
    ##  [67] "magnet_arm_y"             "magnet_arm_z"            
    ##  [69] "kurtosis_roll_arm"        "kurtosis_picth_arm"      
    ##  [71] "kurtosis_yaw_arm"         "skewness_roll_arm"       
    ##  [73] "skewness_pitch_arm"       "skewness_yaw_arm"        
    ##  [75] "max_roll_arm"             "max_picth_arm"           
    ##  [77] "max_yaw_arm"              "min_roll_arm"            
    ##  [79] "min_pitch_arm"            "min_yaw_arm"             
    ##  [81] "amplitude_roll_arm"       "amplitude_pitch_arm"     
    ##  [83] "amplitude_yaw_arm"        "roll_dumbbell"           
    ##  [85] "pitch_dumbbell"           "yaw_dumbbell"            
    ##  [87] "kurtosis_roll_dumbbell"   "kurtosis_picth_dumbbell" 
    ##  [89] "kurtosis_yaw_dumbbell"    "skewness_roll_dumbbell"  
    ##  [91] "skewness_pitch_dumbbell"  "skewness_yaw_dumbbell"   
    ##  [93] "max_roll_dumbbell"        "max_picth_dumbbell"      
    ##  [95] "max_yaw_dumbbell"         "min_roll_dumbbell"       
    ##  [97] "min_pitch_dumbbell"       "min_yaw_dumbbell"        
    ##  [99] "amplitude_roll_dumbbell"  "amplitude_pitch_dumbbell"
    ## [101] "amplitude_yaw_dumbbell"   "total_accel_dumbbell"    
    ## [103] "var_accel_dumbbell"       "avg_roll_dumbbell"       
    ## [105] "stddev_roll_dumbbell"     "var_roll_dumbbell"       
    ## [107] "avg_pitch_dumbbell"       "stddev_pitch_dumbbell"   
    ## [109] "var_pitch_dumbbell"       "avg_yaw_dumbbell"        
    ## [111] "stddev_yaw_dumbbell"      "var_yaw_dumbbell"        
    ## [113] "gyros_dumbbell_x"         "gyros_dumbbell_y"        
    ## [115] "gyros_dumbbell_z"         "accel_dumbbell_x"        
    ## [117] "accel_dumbbell_y"         "accel_dumbbell_z"        
    ## [119] "magnet_dumbbell_x"        "magnet_dumbbell_y"       
    ## [121] "magnet_dumbbell_z"        "roll_forearm"            
    ## [123] "pitch_forearm"            "yaw_forearm"             
    ## [125] "kurtosis_roll_forearm"    "kurtosis_picth_forearm"  
    ## [127] "kurtosis_yaw_forearm"     "skewness_roll_forearm"   
    ## [129] "skewness_pitch_forearm"   "skewness_yaw_forearm"    
    ## [131] "max_roll_forearm"         "max_picth_forearm"       
    ## [133] "max_yaw_forearm"          "min_roll_forearm"        
    ## [135] "min_pitch_forearm"        "min_yaw_forearm"         
    ## [137] "amplitude_roll_forearm"   "amplitude_pitch_forearm" 
    ## [139] "amplitude_yaw_forearm"    "total_accel_forearm"     
    ## [141] "var_accel_forearm"        "avg_roll_forearm"        
    ## [143] "stddev_roll_forearm"      "var_roll_forearm"        
    ## [145] "avg_pitch_forearm"        "stddev_pitch_forearm"    
    ## [147] "var_pitch_forearm"        "avg_yaw_forearm"         
    ## [149] "stddev_yaw_forearm"       "var_yaw_forearm"         
    ## [151] "gyros_forearm_x"          "gyros_forearm_y"         
    ## [153] "gyros_forearm_z"          "accel_forearm_x"         
    ## [155] "accel_forearm_y"          "accel_forearm_z"         
    ## [157] "magnet_forearm_x"         "magnet_forearm_y"        
    ## [159] "magnet_forearm_z"         "classe"

Where every feature besides “classe” (our outcome: the manner in which
the subjects performed the exercise) is a potential predictor. Since we
will be fitting a caret model to this data, we should first evaluate how
much of it consists of missing values.

    apply(training, 2, function(i) (mean(is.na(i))))

    ##                        X                user_name     raw_timestamp_part_1 
    ##                0.0000000                0.0000000                0.0000000 
    ##     raw_timestamp_part_2           cvtd_timestamp               new_window 
    ##                0.0000000                0.0000000                0.0000000 
    ##               num_window                roll_belt               pitch_belt 
    ##                0.0000000                0.0000000                0.0000000 
    ##                 yaw_belt         total_accel_belt       kurtosis_roll_belt 
    ##                0.0000000                0.0000000                0.0000000 
    ##      kurtosis_picth_belt        kurtosis_yaw_belt       skewness_roll_belt 
    ##                0.0000000                0.0000000                0.0000000 
    ##     skewness_roll_belt.1        skewness_yaw_belt            max_roll_belt 
    ##                0.0000000                0.0000000                0.9793089 
    ##           max_picth_belt             max_yaw_belt            min_roll_belt 
    ##                0.9793089                0.0000000                0.9793089 
    ##           min_pitch_belt             min_yaw_belt      amplitude_roll_belt 
    ##                0.9793089                0.0000000                0.9793089 
    ##     amplitude_pitch_belt       amplitude_yaw_belt     var_total_accel_belt 
    ##                0.9793089                0.0000000                0.9793089 
    ##            avg_roll_belt         stddev_roll_belt            var_roll_belt 
    ##                0.9793089                0.9793089                0.9793089 
    ##           avg_pitch_belt        stddev_pitch_belt           var_pitch_belt 
    ##                0.9793089                0.9793089                0.9793089 
    ##             avg_yaw_belt          stddev_yaw_belt             var_yaw_belt 
    ##                0.9793089                0.9793089                0.9793089 
    ##             gyros_belt_x             gyros_belt_y             gyros_belt_z 
    ##                0.0000000                0.0000000                0.0000000 
    ##             accel_belt_x             accel_belt_y             accel_belt_z 
    ##                0.0000000                0.0000000                0.0000000 
    ##            magnet_belt_x            magnet_belt_y            magnet_belt_z 
    ##                0.0000000                0.0000000                0.0000000 
    ##                 roll_arm                pitch_arm                  yaw_arm 
    ##                0.0000000                0.0000000                0.0000000 
    ##          total_accel_arm            var_accel_arm             avg_roll_arm 
    ##                0.0000000                0.9793089                0.9793089 
    ##          stddev_roll_arm             var_roll_arm            avg_pitch_arm 
    ##                0.9793089                0.9793089                0.9793089 
    ##         stddev_pitch_arm            var_pitch_arm              avg_yaw_arm 
    ##                0.9793089                0.9793089                0.9793089 
    ##           stddev_yaw_arm              var_yaw_arm              gyros_arm_x 
    ##                0.9793089                0.9793089                0.0000000 
    ##              gyros_arm_y              gyros_arm_z              accel_arm_x 
    ##                0.0000000                0.0000000                0.0000000 
    ##              accel_arm_y              accel_arm_z             magnet_arm_x 
    ##                0.0000000                0.0000000                0.0000000 
    ##             magnet_arm_y             magnet_arm_z        kurtosis_roll_arm 
    ##                0.0000000                0.0000000                0.0000000 
    ##       kurtosis_picth_arm         kurtosis_yaw_arm        skewness_roll_arm 
    ##                0.0000000                0.0000000                0.0000000 
    ##       skewness_pitch_arm         skewness_yaw_arm             max_roll_arm 
    ##                0.0000000                0.0000000                0.9793089 
    ##            max_picth_arm              max_yaw_arm             min_roll_arm 
    ##                0.9793089                0.9793089                0.9793089 
    ##            min_pitch_arm              min_yaw_arm       amplitude_roll_arm 
    ##                0.9793089                0.9793089                0.9793089 
    ##      amplitude_pitch_arm        amplitude_yaw_arm            roll_dumbbell 
    ##                0.9793089                0.9793089                0.0000000 
    ##           pitch_dumbbell             yaw_dumbbell   kurtosis_roll_dumbbell 
    ##                0.0000000                0.0000000                0.0000000 
    ##  kurtosis_picth_dumbbell    kurtosis_yaw_dumbbell   skewness_roll_dumbbell 
    ##                0.0000000                0.0000000                0.0000000 
    ##  skewness_pitch_dumbbell    skewness_yaw_dumbbell        max_roll_dumbbell 
    ##                0.0000000                0.0000000                0.9793089 
    ##       max_picth_dumbbell         max_yaw_dumbbell        min_roll_dumbbell 
    ##                0.9793089                0.0000000                0.9793089 
    ##       min_pitch_dumbbell         min_yaw_dumbbell  amplitude_roll_dumbbell 
    ##                0.9793089                0.0000000                0.9793089 
    ## amplitude_pitch_dumbbell   amplitude_yaw_dumbbell     total_accel_dumbbell 
    ##                0.9793089                0.0000000                0.0000000 
    ##       var_accel_dumbbell        avg_roll_dumbbell     stddev_roll_dumbbell 
    ##                0.9793089                0.9793089                0.9793089 
    ##        var_roll_dumbbell       avg_pitch_dumbbell    stddev_pitch_dumbbell 
    ##                0.9793089                0.9793089                0.9793089 
    ##       var_pitch_dumbbell         avg_yaw_dumbbell      stddev_yaw_dumbbell 
    ##                0.9793089                0.9793089                0.9793089 
    ##         var_yaw_dumbbell         gyros_dumbbell_x         gyros_dumbbell_y 
    ##                0.9793089                0.0000000                0.0000000 
    ##         gyros_dumbbell_z         accel_dumbbell_x         accel_dumbbell_y 
    ##                0.0000000                0.0000000                0.0000000 
    ##         accel_dumbbell_z        magnet_dumbbell_x        magnet_dumbbell_y 
    ##                0.0000000                0.0000000                0.0000000 
    ##        magnet_dumbbell_z             roll_forearm            pitch_forearm 
    ##                0.0000000                0.0000000                0.0000000 
    ##              yaw_forearm    kurtosis_roll_forearm   kurtosis_picth_forearm 
    ##                0.0000000                0.0000000                0.0000000 
    ##     kurtosis_yaw_forearm    skewness_roll_forearm   skewness_pitch_forearm 
    ##                0.0000000                0.0000000                0.0000000 
    ##     skewness_yaw_forearm         max_roll_forearm        max_picth_forearm 
    ##                0.0000000                0.9793089                0.9793089 
    ##          max_yaw_forearm         min_roll_forearm        min_pitch_forearm 
    ##                0.0000000                0.9793089                0.9793089 
    ##          min_yaw_forearm   amplitude_roll_forearm  amplitude_pitch_forearm 
    ##                0.0000000                0.9793089                0.9793089 
    ##    amplitude_yaw_forearm      total_accel_forearm        var_accel_forearm 
    ##                0.0000000                0.0000000                0.9793089 
    ##         avg_roll_forearm      stddev_roll_forearm         var_roll_forearm 
    ##                0.9793089                0.9793089                0.9793089 
    ##        avg_pitch_forearm     stddev_pitch_forearm        var_pitch_forearm 
    ##                0.9793089                0.9793089                0.9793089 
    ##          avg_yaw_forearm       stddev_yaw_forearm          var_yaw_forearm 
    ##                0.9793089                0.9793089                0.9793089 
    ##          gyros_forearm_x          gyros_forearm_y          gyros_forearm_z 
    ##                0.0000000                0.0000000                0.0000000 
    ##          accel_forearm_x          accel_forearm_y          accel_forearm_z 
    ##                0.0000000                0.0000000                0.0000000 
    ##         magnet_forearm_x         magnet_forearm_y         magnet_forearm_z 
    ##                0.0000000                0.0000000                0.0000000 
    ##                   classe 
    ##                0.0000000

As we can see, several of our features consist almost entirely of
missing values, which will present a problem for us when it comes to
model training later on. Consulting section 5.1 (“Feature extraction and
selection”) of the original paper offers us some insight as to why this
might be the case. From it, we can see that the original researchers
compiled several summary statistics that were calculated at a
measurement boundary, resulting in high proportions of missing values
and/or \#DIV/0! errors. These statistics correspond to the variable
names prefixed by “kurtosis\_”, “skewness\_”, “max\_”, “min\_”,
“amplitude\_”, “var\_”, “avg\_”, and “stddev\_”, which match those that
we found had high rates of missing values. We will exclude these from
our report and stick to the raw accelerometer output.

In addition, there are a few extraneous variables which we will also
exclude from our final datasets. These include X (a measure of row
number), along with the subject name, timestamps, and collection
windows, which will only serve to bias our model if we keep them in.

    toRemove <- grep("^(kurtosis_|skewness_|max_|min_|amplitude_|var_|avg_|stddev_)",
                   names(training))
    training.NArm <- training[, -c(1:7, toRemove)]
    testing.NArm <- testing[, -c(1:7, toRemove)]

For reference, the features we are excluding in our training.NArm
dataset are given by:

    '%notin%' <- Negate('%in%')
    names(training)[names(training) %notin% names(training.NArm)]

    ##   [1] "X"                        "user_name"               
    ##   [3] "raw_timestamp_part_1"     "raw_timestamp_part_2"    
    ##   [5] "cvtd_timestamp"           "new_window"              
    ##   [7] "num_window"               "kurtosis_roll_belt"      
    ##   [9] "kurtosis_picth_belt"      "kurtosis_yaw_belt"       
    ##  [11] "skewness_roll_belt"       "skewness_roll_belt.1"    
    ##  [13] "skewness_yaw_belt"        "max_roll_belt"           
    ##  [15] "max_picth_belt"           "max_yaw_belt"            
    ##  [17] "min_roll_belt"            "min_pitch_belt"          
    ##  [19] "min_yaw_belt"             "amplitude_roll_belt"     
    ##  [21] "amplitude_pitch_belt"     "amplitude_yaw_belt"      
    ##  [23] "var_total_accel_belt"     "avg_roll_belt"           
    ##  [25] "stddev_roll_belt"         "var_roll_belt"           
    ##  [27] "avg_pitch_belt"           "stddev_pitch_belt"       
    ##  [29] "var_pitch_belt"           "avg_yaw_belt"            
    ##  [31] "stddev_yaw_belt"          "var_yaw_belt"            
    ##  [33] "var_accel_arm"            "avg_roll_arm"            
    ##  [35] "stddev_roll_arm"          "var_roll_arm"            
    ##  [37] "avg_pitch_arm"            "stddev_pitch_arm"        
    ##  [39] "var_pitch_arm"            "avg_yaw_arm"             
    ##  [41] "stddev_yaw_arm"           "var_yaw_arm"             
    ##  [43] "kurtosis_roll_arm"        "kurtosis_picth_arm"      
    ##  [45] "kurtosis_yaw_arm"         "skewness_roll_arm"       
    ##  [47] "skewness_pitch_arm"       "skewness_yaw_arm"        
    ##  [49] "max_roll_arm"             "max_picth_arm"           
    ##  [51] "max_yaw_arm"              "min_roll_arm"            
    ##  [53] "min_pitch_arm"            "min_yaw_arm"             
    ##  [55] "amplitude_roll_arm"       "amplitude_pitch_arm"     
    ##  [57] "amplitude_yaw_arm"        "kurtosis_roll_dumbbell"  
    ##  [59] "kurtosis_picth_dumbbell"  "kurtosis_yaw_dumbbell"   
    ##  [61] "skewness_roll_dumbbell"   "skewness_pitch_dumbbell" 
    ##  [63] "skewness_yaw_dumbbell"    "max_roll_dumbbell"       
    ##  [65] "max_picth_dumbbell"       "max_yaw_dumbbell"        
    ##  [67] "min_roll_dumbbell"        "min_pitch_dumbbell"      
    ##  [69] "min_yaw_dumbbell"         "amplitude_roll_dumbbell" 
    ##  [71] "amplitude_pitch_dumbbell" "amplitude_yaw_dumbbell"  
    ##  [73] "var_accel_dumbbell"       "avg_roll_dumbbell"       
    ##  [75] "stddev_roll_dumbbell"     "var_roll_dumbbell"       
    ##  [77] "avg_pitch_dumbbell"       "stddev_pitch_dumbbell"   
    ##  [79] "var_pitch_dumbbell"       "avg_yaw_dumbbell"        
    ##  [81] "stddev_yaw_dumbbell"      "var_yaw_dumbbell"        
    ##  [83] "kurtosis_roll_forearm"    "kurtosis_picth_forearm"  
    ##  [85] "kurtosis_yaw_forearm"     "skewness_roll_forearm"   
    ##  [87] "skewness_pitch_forearm"   "skewness_yaw_forearm"    
    ##  [89] "max_roll_forearm"         "max_picth_forearm"       
    ##  [91] "max_yaw_forearm"          "min_roll_forearm"        
    ##  [93] "min_pitch_forearm"        "min_yaw_forearm"         
    ##  [95] "amplitude_roll_forearm"   "amplitude_pitch_forearm" 
    ##  [97] "amplitude_yaw_forearm"    "var_accel_forearm"       
    ##  [99] "avg_roll_forearm"         "stddev_roll_forearm"     
    ## [101] "var_roll_forearm"         "avg_pitch_forearm"       
    ## [103] "stddev_pitch_forearm"     "var_pitch_forearm"       
    ## [105] "avg_yaw_forearm"          "stddev_yaw_forearm"      
    ## [107] "var_yaw_forearm"

After pruning our data in this fashion, we will once again check for the
prevalence of missing values:

    data.frame(Training = c(sum(is.na(training)), sum(is.na(training.NArm))),
               Testing = c(sum(is.na(testing)), sum(is.na(testing.NArm))),
               row.names = c("Raw", "Summary Stats Removed"))

    ##                       Training Testing
    ## Raw                    1287472    2000
    ## Summary Stats Removed        0       0

So, as we can see, removing the summary stats completely eliminates the
missing values in our dataset. Before we move on, we will perform a
simple in-place replacement of our training and testing data sets for
clarity.

    training.NArm$classe <- as.factor(training.NArm$classe)
    training <- training.NArm
    testing <- testing.NArm
    rm(training.NArm)
    rm(testing.NArm)

Cross-Validation and Model Selection
====================================

Before we develop and train our model, we will set aside a portion of
our training data for later use to estimate our out-of-sample error
rate. This can be done easily in the caret package with the
createDataPartition() function:

    inTrain <- createDataPartition(training$classe, p = 0.7, list = FALSE)
    crossTrain <- training[inTrain, ]
    crossTest <- training[-inTrain, ]

For our model selection, we will use a random forest approach, since it
tends to be robust and have high accuracy on datasets around our size.
Even though these models don’t necessarily need cross-validation due to
the manner in which they are constructed, we will implement a thrice
repeated, 5-fold cross-validation strategy so we can be extra sure to
avoid overfitting and maximize out-of-sample accuracy. This can be
easily done during model training using the trControl parameter of
caret’s train() function. Again, we will make sure to use the crossTrain
dataset we created above to avoid biasing our out-of-sample error
estimate.

    # create parallel processing cluster
    cluster <- makeCluster(detectCores() - 1)
    registerDoParallel(cluster)

    # train model
    modControl <- trainControl(method = "repeatedcv", number = 5, repeats = 3, 
                               allowParallel = TRUE)
    model <- train(classe ~ ., method = "rf", data = crossTrain,
                   trControl = modControl)

    # de-register parallel processing cluster
    stopCluster(cluster)
    registerDoSEQ()

After running the above step, we’ve arrived at our final model. All
that’s left is to apply it to our cross-validation testing dataset and
estimate our out-of-sample error:

    confusionMatrix(predict(model, crossTest), crossTest$classe)

    ## Confusion Matrix and Statistics
    ## 
    ##           Reference
    ## Prediction    A    B    C    D    E
    ##          A 1673    5    0    0    0
    ##          B    1 1134    5    0    0
    ##          C    0    0 1021   17    0
    ##          D    0    0    0  945    0
    ##          E    0    0    0    2 1082
    ## 
    ## Overall Statistics
    ##                                           
    ##                Accuracy : 0.9949          
    ##                  95% CI : (0.9927, 0.9966)
    ##     No Information Rate : 0.2845          
    ##     P-Value [Acc > NIR] : < 2.2e-16       
    ##                                           
    ##                   Kappa : 0.9936          
    ##                                           
    ##  Mcnemar's Test P-Value : NA              
    ## 
    ## Statistics by Class:
    ## 
    ##                      Class: A Class: B Class: C Class: D Class: E
    ## Sensitivity            0.9994   0.9956   0.9951   0.9803   1.0000
    ## Specificity            0.9988   0.9987   0.9965   1.0000   0.9996
    ## Pos Pred Value         0.9970   0.9947   0.9836   1.0000   0.9982
    ## Neg Pred Value         0.9998   0.9989   0.9990   0.9962   1.0000
    ## Prevalence             0.2845   0.1935   0.1743   0.1638   0.1839
    ## Detection Rate         0.2843   0.1927   0.1735   0.1606   0.1839
    ## Detection Prevalence   0.2851   0.1937   0.1764   0.1606   0.1842
    ## Balanced Accuracy      0.9991   0.9972   0.9958   0.9901   0.9998

As we can see from the output, our model achieves a roughly **99.5%
out-of-sample accuracy**, only failing to accurately categorize 30 of
our 5885 test cases.

Quiz Predictions
================

The final component of this assignment is to predict, using the model we
have just developed, the activity classification of 20 new cases, which
are stored in the previously downloaded testing dataset. These will be
compared to the correct answers during grading.

    predictions <- predict(model, testing)
    predictions

    ##  [1] B A B A A E D B A A B C B A E E A B B B
    ## Levels: A B C D E
