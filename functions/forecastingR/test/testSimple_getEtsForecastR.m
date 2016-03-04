clearvars; close all; clc;

trainControl.horizon = 20;
noiseLevel = 1.5;

t = (0.1:0.1:100)';
x = sin(t) + noiseLevel*randn(size(t));

trainIdxs = 1:(length(x)-trainControl.horizon);
testIdxs = max(trainIdxs) + (1:trainControl.horizon);

t_train = t(trainIdxs);
t_test = t(testIdxs);

x_train = x(trainIdxs);
x_test = x(testIdxs);

fc = getEtsForecastR(x_train, trainControl);
plot(t_train, x_train); hold on;
plot(t_test, fc)
plot(t_test, x_test);
plot(t_test,  sin(t_test));

legend({'Training Data', 'Forecast', 'Actual', 'Noiseless Actual'});
