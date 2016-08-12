%% Main Script for UCESO
%  (Unprincipled Controllers for Energy Storage Optimization)


%% (Tidy up &) Load Configuration options
clearvars; close all; clc;
tic;
cfg = Config(pwd);


%% Load Functions into Environment (script)
LoadFunctions;


%% Load Data
disp('======= LOADING DATA =======');
[ dataTrain, dataTest, cfg ] = loadData( cfg );


%% Train Forecasts (& forecast-free controller)
disp('======= FORECAST TRAINING =======');
[ trainedModels, trainTime ] = trainAllForecasts(cfg, dataTrain);


%% Test All Methods:
disp('======= FORECAST TESTING =======');
[ results ] = testAllForecasts(cfg, trainedModels, dataTest);


%% Plotting:
disp('======= PLOTTING =======');
if isequal(cfg.type, 'oso')
    plotAllResultsDp( cfg, results, dataTrain)
else
    plotAllResults(cfg, results);
end


%% Save Results
disp('======= SAVING =======');
save(cfg.sav.finalFileName, '-v7.3');

overAllTime = toc;
disp('Total Time Taken: ');
disp(overAllTime);
