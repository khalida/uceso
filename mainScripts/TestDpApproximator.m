%% TestDpApproximator.m
% This script attempts to replace a DP (used to optimize energy storage
% operation) with a NN.

%% DP to be replaced has the form:
% [bestDischargeStep, bestCTG(idx)] = controllerDp(cfg, ...
%                demandForecast, pvForecast, battery, hourNow);

% And it requires the following INPUTS:
% cfg:              Structure of running options
% demandForecast:   Forecast of demand values over the horizon
% pvForecast:       Forecast of PV output over horizon
% battery:          Structure representing the battery object
% hourNow:          Hour of the day for the 1st horizon

%% 0) Tidy up & Load functions
% clearvars; close all; clc;
tic;
rng(42);
LoadFunctions;

%% 1) Choose running options (set locally)
cfg.sim.horizon = 48;
cfg.sim.stepsPerHour = 2;
cfg.sim.batteryEtaD = 0.95;
cfg.sim.batteryEtaC = 0.95;
cfg.bat.costPerKwhUsed = 0.15;
cfg.sim.batteryChargingFactor = 2;
cfg.sim.minCostDiff = 1e-10;
cfg.sim.eps = 1e-10;
cfg.type = 'oso';
cfg.opt.statesPerKwh = 8;
cfg.fc.trainRatio = 0.8;
cfg.fc.nNodes = [2*98 2*98];
cfg.fc.suppressOutput = false;
cfg.fc.maxTime = 20*60;

% Initilaize the Battery Object
battery = Battery(getCfgForController(cfg), 0.5);
nObservations = 100000;

%% 2) Generate (random) PV and demand data;
muDemand = 5;
sigmaDemand = 5;
muPv = 5;
sigmaPv = 10;
demandData = max(normalNumbers(muDemand, sigmaDemand, [nObservations, ...
    cfg.sim.horizon]), 0);

pvData = max(normalNumbers(muPv, sigmaPv, [nObservations, ...
    cfg.sim.horizon]), 0);

%% 3) Generate random battery states, and hours
% A limitation of this approach is that there will be siginificant
% correlation between decision and these states (and other inputs) in real
% data.
batteryStates = randsample(battery.statesInt, nObservations, true)';
hourNumbers = randsample(1:cfg.sim.horizon, nObservations, true)';


%% 4) Find DP solutions;

% Test speed-up offered by using compiled MEX-code
runDpTimer = tic;
dpSolutionsMex = zeros(nObservations, 1);
for ii = 1:nObservations
    nonClassBatt.state = batteryStates(ii);
    dpSolutionsMex(ii) = controllerDp_mex(getCfgForController(cfg),...
        demandData(ii, :), pvData(ii, :), battery.getStruct(),...
        hourNumbers(ii));
end
disp(['Running DP in MEX took: ' num2str(toc(runDpTimer))]);

% runDpTimer = tic;
% dpSolutionsMlab = zeros(nObservations, 1);
% for ii = 1:nObservations
%     nonClassBatt.state = batteryStates(ii);
%     dpSolutionsMlab(ii) = controllerDp(cfg, demandData(ii, :), ...
%         pvData(ii, :), nonClassBatt, hourNumbers(ii));
% end
% disp(['Running DP in Matlab took: ' num2str(toc(runDpTimer))]);
% 
% % Check that results are the same
% disp(['Max difference: ' num2str(max(abs(dpSolutionsMex - ...
%     dpSolutionsMlab)))]);

%% 5) Train and evaluate NN;

% Compose input vectors (& seperate to test and train data)
featureVectors = [demandData, pvData, batteryStates, hourNumbers];
[responseVectors, labels] = labelsToTargets(dpSolutionsMex);
nTrain = floor(cfg.fc.trainRatio*nObservations);
trainIdxs = 1:nTrain;
testIdxs = (nTrain + 1):nObservations;

trainFeatVecs = featureVectors(trainIdxs, :);
trainRespVecs = responseVectors(trainIdxs, :);
trainRespVals = dpSolutionsMex(trainIdxs, :);

testFeatVecs = featureVectors(testIdxs, :);
testRespVecs = responseVectors(testIdxs, :);
testRespVals = dpSolutionsMex(testIdxs, :);

% Try classification network:

% NB: Not sure why, but classifying NN trained from CLI not working at
% all. That trained from GUI does work which is strange.
% Need to dig into this!!! Or just give up on Matlab for ML!

modelClass = trainClassifierNN(cfg, trainFeatVecs, trainRespVecs);
[ testRespVecs_hat, performance, percentErrors ] = testClassifierNN(...
    modelClass, testFeatVecs, testRespVecs);

figure();
scatter(targetsToLabels(testRespVecs, labels), ...
    targetsToLabels(testRespVecs_hat, labels));

xlabel('Target Response');
ylabel('NN Response');
grid on; refline(1, 0);
title('Performance of Classification Network');

% Try classification network:
modelReg = trainFfnn(cfg,  trainFeatVecs', dpSolutionsMex(trainIdxs)');
figure();
scatter(dpSolutionsMex(testIdxs), modelReg(testFeatVecs'));
xlabel('Target Response');
ylabel('NN Response');
grid on; refline(1, 0);
title('Performance of Regression Network');

disp(['Total time taken: ' num2str(toc)]);
