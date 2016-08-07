# Attempting DP-behaviour approximation using R 'caret' package:

# LOAD PACKAGES
library(stringr)
library(caret)
library(randomForest)
library(frbs)
library(h2o)

# IMPORT DATA

trainFeatVecs <- read.csv(
  "C:/LocalData/Documents/Documents/PhD/21_Projects/2016_04_07_uceso/mainScripts/trainFeatVecs.csv",
  header=FALSE)

trainRespVals <- read.csv(
  "C:/LocalData/Documents/Documents/PhD/21_Projects/2016_04_07_uceso/mainScripts/trainRespVals.csv",
  header=FALSE)

trainRespVals <- unlist(trainRespVals)


# Attempt to train model:
# Random forest model:
rfModel <- randomForest(y=as.factor(trainRespVals), x=trainFeatVecs, ntree=300, do.train=50)

localH2O = h2o.init(ip = "localhost", port = 54321, startH2O = TRUE, Xmx = '3g')
train <- h2o.importFile(localH2O, path = "data/train.csv")
train <- cbind(train[,1],train[,-1]/255.0)
test <- h2o.importFile(localH2O, path = "data/test.csv")
test <- test/255.0

# Predict the test data:
testFeatVecs <- read.csv(
  "C:/LocalData/Documents/Documents/PhD/21_Projects/2016_04_07_uceso/mainScripts/testFeatVecs.csv",
  header=FALSE)

testRespVals <- read.csv(
  "C:/LocalData/Documents/Documents/PhD/21_Projects/2016_04_07_uceso/mainScripts/testRespVals.csv",
  header=FALSE)

testRespVals <- unlist(testRespVals)

testRespVals_hat <- predict(rfModel, newdata=testFeatVecs)


# Scatter plot of data to see how we did:
plot(x=testRespVals, y=as.numeric(testRespVals_hat), main="RF Classification Performance", 
     xlab="DP Response", ylab="RF Response", pch=19)