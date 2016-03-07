clearvars; close all; clc;

trainControl.horizon = 48;
noiseLevel = 0.5;
dt = 0.1;

t = (dt:dt:(20*trainControl.horizon))';
x = sin(2*pi*t/(trainControl.horizon*dt)) + noiseLevel*randn(size(t));

trainIdxs = 1:(length(x)-trainControl.horizon);
testIdxs = max(trainIdxs) + (1:trainControl.horizon);

t_train = t(trainIdxs);
t_test = t(testIdxs);

x_train = x(trainIdxs);
x_test = x(testIdxs);

fc = getEtsForecastR(x_train, trainControl);
fcNP = x_train((end-trainControl.horizon+1):end);

fc_mse = mse(x_test, fc);
fcNP_mse = mse(x_test, fcNP);

plot(t_train, x_train); hold on;
plot(t_test, fc)
plot(t_test, x_test);
plot(t_test,  sin(2*pi*t_test/(trainControl.horizon*dt)));
plot(t_test,  fcNP);

legend({'Training Data', 'Forecast', 'Actual', 'Noiseless Actual', ...
    'NP'});
