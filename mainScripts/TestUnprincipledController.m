%% Script to test the performance of an Unprincipled Controller, when
% Trained using output from a principled controller (in our application)

%% Exact controller has been implemented in controllerOptimizer:
%[energyToBattery, exitFlag] = controllerOptimizer(forecast, ...
%    stateOfCharge, demandNow, batteryCapacity, maximumChargeRate, ...
%    stepsPerHour, peakSoFar, MPC)

% And it requires the following inputs:
% forecast: demand forecast for next k steps [kWh]
% stateOfCharge: SoC of battery at start of horizon [kWh]
% demandNow: actual demand for the 1st interval of the horizon [kWh]
% batteryCapacity: energy capacity of the battery [kWh]
% maximumChargeRate: maximum kW in/out of battery [kW]
% stepsPerHour: No. of intervals per hour
% peakSoFar: peak per-interval grid power in billing period [kWh]
% MPC: structure containing running options:

%% 0) Tidy up
clearvars; close all; clc;
tic;

%% 1) Declare simulation parameters:
MPC.clipNegativeFcast = true;
MPC.horizon = 48;
Sim.horizon = MPC.horizon;
MPC.knowDemandNow = false;
MPC.setPoint = true;
MPC.chargeWhenCan = false;
MPC.secondWeight = 0;
MPC.rewardMargin = true;
MPC.iterationFactor = 1;
MPC.resetPeakToMean = true;
MPC.SPrecourse = false;
MPC.billingPeriodDays = 7;

%% And trainControl parameters
trainControl.maxTime = 60*20;
trainControl.suppressOutput = false;

nObservations = 10.^(1:6);
nNodes = ones(1,6).*100;
nOutputs = 1;
trainRatio = 0.75;
tsTestLength = 10*MPC.horizon*MPC.billingPeriodDays;

%% 2) Delcare instance parameters which do not change:
batteryCapacity = 2.5;
maximumChargeRate = 5;
stepsPerHour = 2;

exact_godCast_prr = zeros(length(nObservations), 1);
exact_NP_prr = zeros(length(nObservations), 1);
UP_prr = zeros(length(nObservations), 1);

testDemandSeries = unifrnd(0, 5, [tsTestLength, 1]);
demandDelays = zeros(MPC.horizon, 1);

for nObsIdx = 3:(length(nObservations))
    
    nObservation = nObservations(nObsIdx);
    
    %% 3) Generate some training data, for each variable create a matrix
    % with dimension [nDim x nObservations]
    [forecasts, stateOfCharges, demandNows, peakSoFars] = ...
        generateControllerData(batteryCapacity, MPC, nObservation);
    
    %% 4) Determine response for each input data point
    responseVectors = zeros(MPC.horizon, nObservation);
    
    for iObs = 1:nObservation
        [responseVectors(:, iObs), ~] = ...
            controllerOptimizer(forecasts(:, iObs), ...
            stateOfCharges(:, iObs), demandNows(:, iObs), batteryCapacity, ...
            maximumChargeRate, stepsPerHour, peakSoFars(:, iObs), MPC);
    end
    
    
    %% 5) Divide data in training and testing
    trainIdxs = 1:ceil(nObservation*trainRatio);
    testIdxs = (max(trainIdxs)+1):nObservation;
    featureVectors = [forecasts; stateOfCharges; demandNows; peakSoFars];
    
    featureVectorsTrain = featureVectors(:, trainIdxs);
    responseVectorsTrain = responseVectors(nOutputs, trainIdxs);
    
    featureVectorsTest = featureVectors(:, testIdxs);
    responseVectorsTest = responseVectors(nOutputs, testIdxs);
    
    
    %% 6) Train the unprincipled controller
    trainControl.nNodes = nNodes(nObsIdx);
    unprincipledController = ...
        trainFfnn(featureVectorsTrain, responseVectorsTrain, trainControl);
    
    %% 7) Test performance on test data-set
    outputVectorsTest = unprincipledController(featureVectorsTest);
    figure();
    plotregression(responseVectorsTest, outputVectorsTest);
    
    %% 8) Simulate t-series behaviour of various controllers
    % NB: this uses simulated/fake data so YMMV
    godCast = createGodCast(testDemandSeries, MPC.horizon);
    
    Sim.stepsPerHour = stepsPerHour;
    Sim.hourNumberTest = mod((1:length(testDemandSeries))', MPC.horizon);
    Sim.k = Sim.horizon;
    Sim.forecastModels = 'FFNN';
    runControl.MPC = MPC;
    runControl.forecastModels = Sim.forecastModels;
    runControl.godCast = true;
    runControl.naivePeriodic = false;
    runControl.MPC.setPoint = false;
    runControl.MPC.trainControl = trainControl;
    
    % 8.1) Exact controller with godCast
    [ runningPeak, ~, ~ ] = ...
        mpcController(unprincipledController, godCast, testDemandSeries,...
        batteryCapacity, maximumChargeRate, demandDelays, ...
        Sim, runControl);
    
    exact_godCast_prr(nObsIdx) =...
        extractSimulationResults(runningPeak', testDemandSeries,...
        MPC.horizon*MPC.billingPeriodDays);
    
    figure();
    plot([testDemandSeries, runningPeak'])
    title(['Exact controller with perfect foresight, ' ...
        num2str(nObservation) ' data points']);
    
    % 8.2) Exact controller with NP forecast
    runControl.godCast = false;
    runControl.naivePeriodic = true;
    
    [ runningPeak, exitFlag, forecastUsed ] = ...
        mpcController(unprincipledController, godCast, testDemandSeries,...
        batteryCapacity, maximumChargeRate, demandDelays, ...
        Sim, runControl);
    
    exact_NP_prr(nObsIdx) = extractSimulationResults(runningPeak', testDemandSeries,...
        MPC.horizon*MPC.billingPeriodDays);
    
    figure();
    plot([testDemandSeries, runningPeak'])
    title(['Exact controller with NP forecast, ' ...
        num2str(nObservation) ' data points']);
    
    % 8.3) Unprincipled controller
    MPC.knowFuture = true;
    
    MPC.setPoint = false;
    [ runningPeak ] = mpcControllerForecastFree( unprincipledController, ...
        testDemandSeries, batteryCapacity, maximumChargeRate, demandDelays, ...
        MPC, Sim);
    MPC.setPoint = true;
    
    UP_prr(nObsIdx) = extractSimulationResults(runningPeak', ...
        testDemandSeries, MPC.horizon*MPC.billingPeriodDays);
    
    figure();
    plot([testDemandSeries, runningPeak'])
    title(['Unprincipled Controller Peak Import VS Local Demand, ' ...
        num2str(nObservation) ' data points']);
    
    disp(['Completed run with ' num2str(nObservation) ' data points']);
    disp(['and ' num2str(unprincipledController.numWeightElements) ...
        ' weighted elements']);
    toc;
end

figure();
semilogx(nObservations, [exact_godCast_prr, exact_NP_prr, UP_prr]);
legend({'Exact Controller, God Cast', 'Exact Controller, NP', ...
    'Unprincipled Controller, God Cast'});


toc;