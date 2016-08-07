## Start a local cluster with 1GB RAM (default)
library(h2o)
localH2O <- h2o.init(ip = "localhost", port = 54321, startH2O = TRUE)

## Start a local cluster with 2GB RAM
localH2O = h2o.init(ip = "localhost", port = 54321, startH2O = TRUE, 
                    Xmx = '2g')

## Convert Breast Cancer into H2O
data("BreastCancer")
dat <- BreastCancer[, -1]  # remove the ID column
dat_h2o <- as.h2o(localH2O, dat)

## Import MNIST CSV as H2O
dat_h2o <- h2o.importFile(localH2O, path = ".../mnist_train.csv")

model <- 
  h2o.deeplearning(x = 2:785,  # column numbers for predictors
                   y = 1,   # column number for label
                   data = train_h2o, # data in H2O format
                   activation = "TanhWithDropout", # or 'Tanh'
                   input_dropout_ratio = 0.2, # % of inputs dropout
                   hidden_dropout_ratios = c(0.5,0.5,0.5), # % for nodes dropout
                   balance_classes = TRUE, 
                   hidden = c(50,50,50), # three layers of 50 nodes
                   epochs = 100) # max. no. of epochs

## Using the DNN model for predictions
h2o_yhat_test <- h2o.predict(model, test_h2o)

## Converting H2O format into data frame
df_yhat_test <- as.data.frame(h2o_yhat_test)

