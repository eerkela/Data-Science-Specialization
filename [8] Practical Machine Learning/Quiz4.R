# Quiz4
# Eric Erkela
# Practical Machine Learning

# This quiz sucks.  Almost all the packages have changed since it was last 
# updated, so almost nothing gives the right answer.

# 1)
library(caret)
vowel.train <- read.csv("https://web.stanford.edu/~hastie/ElemStatLearn/datasets/vowel.train")
vowel.test <- read.csv("https://web.stanford.edu/~hastie/ElemStatLearn/datasets/vowel.test")
vowel.train$y <- as.factor(vowel.train$y)
vowel.test$y <- as.factor(vowel.test$y)
set.seed(33833)
# train models
mod1gbm <- train(y ~ ., method = "gbm", data = vowel.train)
mod1rf <- train(y ~ ., method = "rf", data = vowel.train,
                trControl = trainControl(method = "cv"), 
                number = 3)
# build stacked data frames
pred1DF <- data.frame(gbm = predict(mod1gbm, vowel.train),
                      rf = predict(mod1rf, vowel.train),
                      y = vowel.train$y)
test1DF <- data.frame(gbm = predict(mod1gbm, vowel.test),
                      rf = predict(mod1rf, vowel.test),
                      y = vowel.test$y)
# build combined model
mod1comb <- train(y ~ ., method = "rf", data = pred1DF)
# extract accuracies
confusionMatrix(test1DF$gbm, vowel.test$y)$overall[["Accuracy"]]
confusionMatrix(test1DF$rf, vowel.test$y)$overall[["Accuracy"]]
confusionMatrix(predict(mod1comb, test1DF), vowel.test$y)$overall[["Accuracy"]]

# 2)
library(caret)
library(gbm)
set.seed(3433)
library(AppliedPredictiveModeling)
data(AlzheimerDisease)
adData = data.frame(diagnosis,predictors)
inTrain = createDataPartition(adData$diagnosis, p = 3/4)[[1]]
training = adData[ inTrain,]
testing = adData[-inTrain,]
set.seed(62433)
# build models
mod2rf <- train(diagnosis ~ ., method = "rf", data = training)
mod2gbm <- train(diagnosis ~ ., method = "gbm", data = training)
mod2lda <- train(diagnosis ~ ., method = "lda", data = training)
# stack models
pred2DF <- data.frame(rf = predict(mod2rf, training),
                      gbm = predict(mod2gbm, training),
                      lda = predict(mod2lda, training),
                      diagnosis = training$diagnosis)
mod2comb <- train(diagnosis ~ ., method = "rf", data = pred2DF)
test2DF <- data.frame(rf = predict(mod2rf, testing),
                      gbm = predict(mod2gbm, testing),
                      lda = predict(mod2lda, testing),
                      diagnosis = testing$diagnosis)
# retrieve accuracies
confusionMatrix(test2DF$rf, testing$diagnosis)$overall[["Accuracy"]]
confusionMatrix(test2DF$gbm, testing$diagnosis)$overall[["Accuracy"]]
confusionMatrix(test2DF$lda, testing$diagnosis)$overall[["Accuracy"]]
confusionMatrix(predict(mod2comb, test2DF), testing$diagnosis)$overall[["Accuracy"]]

# 3)
set.seed(3523)
library(AppliedPredictiveModeling)
data(concrete)
inTrain = createDataPartition(concrete$CompressiveStrength, p = 3/4)[[1]]
training = concrete[ inTrain,]
testing = concrete[-inTrain,]
set.seed(233)
mod3 <- train(CompressiveStrength ~ ., method = "lasso", data = training)
plot(mod3$finalModel)
# answer - cement

# 4)
library(lubridate) # For year() function below
dat = read.csv("~/gaData.csv")
training = dat[year(dat$date) < 2012,]
testing = dat[(year(dat$date)) > 2011,]
tstrain = ts(training$visitsTumblr)
mod4 <- bats(tstrain)
mod4forecast <- forecast(mod4)
sum(mod4forecast$fitted > mod4forecast$lower[1:10, 2])


# 5)
set.seed(3523)
library(AppliedPredictiveModeling)
data(concrete)
inTrain = createDataPartition(concrete$CompressiveStrength, p = 3/4)[[1]]
training = concrete[ inTrain,]
testing = concrete[-inTrain,]
set.seed(325)
library(e1071)
mod5 <- svm(CompressiveStrength ~ ., data = training)
pred5 <- predict(mod5, testing)
sqrt(1 / length(pred5) * sum((testing$CompressiveStrength - pred5)^2))

