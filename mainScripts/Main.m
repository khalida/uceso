%% Main Script for IDDFO (Integrated Data-Driven Forecasting &
% Optimization).

%% (Tidy up &) Load Configuration options
clearvars; close all; clc;
tic;
cfg = Config(pwd);


%% Load Functions into Environment (script)
LoadFunctions;


%% Load Data
disp('======= LOADING DATA =======');
[ demandDataTrain, demandDataTest ] = loadData( cfg );


%% Train Forecasts (& forecast-free controller)
disp('======= FORECAST TRAINING =======');
[ trainedModels, trainTime ] = trainAllForecasts(cfg, demandDataTrain);


%% Test All Methods:
disp('======= FORECAST TESTING =======');
[ results ] = testAllForecasts(cfg, trainedModels, demandDataTest);


%% Plotting:
disp('======= PLOTTING =======');
plotAllResults(cfg, results);


%% Save Results
disp('======= SAVING =======');
save(cfg.sav.finalFileName, '-v7.3');

overAllTime = toc;
disp('Total Time Taken: ');
disp(overAllTime);
