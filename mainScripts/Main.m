%% Load Running Configuration
clearvars; close all; clc;
tic;
timeStart = clock;
disp(timeStart);
Config;

%% Add path to the common functions (& any subfolders therein)
[parentFold, ~, ~] = fileparts(pwd);
commonFunctionFolder = [parentFold filesep 'functions'];
addpath(genpath(commonFunctionFolder), '-BEGIN');

%% Read in DATA
load(dataFileWithPath);
customerIdxs = cell(Sim.nInstances, 1);
allDemandValues = cell(Sim.nInstances, 1);
dataLengthRequired = (Sim.nDaysTrain + Sim.nDaysTest)*...
    Sim.stepsPerHour*Sim.hoursPerDay;

instance = 0;
for nCustomerIdx = 1:length(Sim.nCustomers)
    for trial = 1:Sim.nAggregates
        instance = instance + 1;
        customers = Sim.nCustomers(nCustomerIdx);
        customerIdxs{instance} = ...
            randsample(size(demandData, 2), customers);
        allDemandValues{instance} = ...
            sum(demandData(1:dataLengthRequired,...
            customerIdxs{instance}), 2);
    end
end

% Delete the original demand data (no longer needed)
clearvars demandData;

%% Train All Forecasts:
disp('======= FORECAST TRAINING =======');
[ Sim, pars ] = trainAllForecasts(MPC, Sim, allDemandValues);

%% Test All Forecasts:
disp('======= FORECAST TESTING =======');
MPC.trainControl = trainControl;
[ Sim, results ] = testAllForecasts( pars, allDemandValues, Sim, MPC);

%% Do Plotting:
disp('======= PLOTTING =======');
plotAllResults(Sim, results);

%% Save Results
disp('======= SAVING =======');
save(Sim.finalFileName, '-v7.3');
copyfile('Config.m', Sim.resultsDir);

overAllTime = toc;
disp('Total Time Taken: ');
disp(overAllTime);
