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

%% 1) Choose running options (set in Config file)
cfg = Config(pwd);

% Initilaize the Battery Object
battery = Battery(getCfgForController(cfg), 1);
nObservations = 1000;

%% 2) Generate (random) PV and demand data;
muDemand = 5;
sigmaDemand = 5;
muPv = 5;
sigmaPv = 10;
demandData = max(normalNumbers(muDemand, sigmaDemand, [nObservations, ...
    cfg.sim.horizon]), 0)';

pvData = max(normalNumbers(muPv, sigmaPv, [nObservations, ...
    cfg.sim.horizon]), 0)';

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
    battery.state = batteryStates(ii);
    dpSolutionsMex(ii) = controllerDp_mex(getCfgForController(cfg),...
        demandData(:, ii), pvData(:, ii), battery.getStruct(),...
        hourNumbers(ii));
end
disp(['Running DP in MEX took: ' num2str(toc(runDpTimer))]);

runDpTimer = tic;
dpSolutionsMlab = zeros(nObservations, 1);
for ii = 1:nObservations
    battery.state = batteryStates(ii);
    dpSolutionsMlab(ii) = controllerDp(cfg, demandData(:, ii), ...
        pvData(:, ii), battery, hourNumbers(ii));
end
disp(['Running DP in Matlab took: ' num2str(toc(runDpTimer))]);

% % Check that results are the same
disp(['Max difference: ' num2str(max(abs(dpSolutionsMex - ...
    dpSolutionsMlab)))]);

%% 5) Train and evaluate NN;

% Compose input vectors (& seperate to test and train data)
featureVectors = [demandData', pvData', batteryStates, hourNumbers];
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

% Train Regression network:
modelReg = trainFfnnMultiInit(cfg,  trainFeatVecs', dpSolutionsMex(trainIdxs)');
figure();
scatter(dpSolutionsMex(testIdxs), modelReg(testFeatVecs'));
xlabel('Solution from Exact Controller');
ylabel('Response from NN');
grid on; refline(1, 0);
plotAsTixz('NeuralNetworkDPapproximator.tikz');

disp(['Total time taken: ' num2str(toc)]);
