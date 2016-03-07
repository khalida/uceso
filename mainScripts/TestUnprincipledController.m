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
rng(42);
tic;

%% 1) Declare simulation parameters:
MPC.clipNegativeFcast = true;
MPC.horizon = 48;
Sim.horizon = MPC.horizon;
MPC.knowDemandNow = false;
MPC.chargeWhenCan = false;
MPC.secondWeight = 0;
MPC.rewardMargin = true;
MPC.iterationFactor = 1;
MPC.resetPeakToMean = true;
MPC.SPrecourse = false;
MPC.billingPeriodDays = 7;

batteryCapacity = 2.5;
maximumChargeRate = 5;
stepsPerHour = 2;

Sim.stepsPerHour = stepsPerHour;
Sim.k = Sim.horizon;
Sim.forecastModels = 'FFNN';
runControl.MPC = MPC;
runControl.forecastModels = Sim.forecastModels;


%% And trainControl parameters
trainControl.maxTime = 60*60;
trainControl.suppressOutput = false;

nOutputs = 1;
trainRatio = 0.75;
tsTestLength = 10*runControl.MPC.horizon*runControl.MPC.billingPeriodDays;
tsTrainLengths = [50 100].*...
    runControl.MPC.horizon*runControl.MPC.billingPeriodDays;

nNodes = 100.*ones(length(tsTrainLengths));

%% 2) Pre-declarations
exact_godCast_prr = zeros(length(tsTrainLengths), 1);
exact_NP_prr = zeros(length(tsTrainLengths), 1);
exact_MC_prr = zeros(length(tsTrainLengths), 1);
UP_prr = zeros(length(tsTrainLengths), 1);
noiseLevel = 5;

testDemandSeries = 2.5*(sin(2*pi*((1:tsTestLength)')/...
    runControl.MPC.horizon).^2) + unifrnd(0, noiseLevel, ...
    [tsTestLength, 1]);

testDemandSeries = max(0, testDemandSeries);

demandDelays = testDemandSeries(1:runControl.MPC.horizon);
godCastTest = createGodCast(testDemandSeries, runControl.MPC.horizon);

noiseFreeTs = 2.5*(sin(2*pi*((1:tsTestLength)')/...
    runControl.MPC.horizon).^2);

modelCast = createGodCast(noiseFreeTs, runControl.MPC.horizon);

for tsTrainIdx = 1:length(tsTrainLengths)
    
    tsTrainLength = tsTrainLengths(tsTrainIdx);
    trainDemandSeries = 2.5*(sin(2*pi*((1:tsTrainLength)')/...
        runControl.MPC.horizon).^2) + unifrnd(0, noiseLevel, ...
        [tsTrainLength, 1]);
    
    trainDemandSeries = max(0, trainDemandSeries);
    
    %% 3) Generate training data, based on tSeries simulation with godCast
    
    Sim.hourNumberTest = mod((1:length(trainDemandSeries))', ...
        runControl.MPC.horizon);
    
    trainControl.nNodes = nNodes(tsTrainIdx);
    runControl.godCast = true;
    runControl.naivePeriodic = false;
    runControl.MPC.setPoint = false;
    runControl.MPC.trainControl = trainControl;
    runControl.useNPvectors = true;
    
    godCastTrain = createGodCast(trainDemandSeries, runControl.MPC.horizon);
    
    % featureVectors = [forecasts; stateOfCharges; demandNows; peakSoFars];
    unprincipledController = [];
    
    [ ~, ~, ~, responseGc, featureVectorGc ] = ...
        mpcController(unprincipledController, godCastTrain, ...
        trainDemandSeries, batteryCapacity, maximumChargeRate, ...
        demandDelays, Sim, runControl);
    
    %% 4) Determine response for each input data point
    nObservationTrain = size(godCastTrain, 1);
    responseVectorsGc = zeros(runControl.MPC.horizon, nObservationTrain);
    
    for iObs = 1:nObservationTrain
        [responseVectorsGc(:, iObs), ~] = ...
            controllerOptimizer(featureVectorGc(1:48, iObs), ...
            featureVectorGc(49, iObs), featureVectorGc(50, iObs), ...
            batteryCapacity, maximumChargeRate, stepsPerHour,...
            featureVectorGc(51, iObs), runControl.MPC);
    end
    responseVectorsGc = responseVectorsGc(1,:);
    
    %if max(abs(responseVectorsGc - responseGc)) > 1e-10
    %    error('Get different response in time-series Simulation and out of it');
    %end
    
    %% 5) Divide data in training and testing
    trainIdxs = 1:ceil(nObservationTrain*trainRatio);
    testIdxs = (max(trainIdxs)+1):nObservationTrain;
    
    featureVectorsTrain = featureVectorGc(:, trainIdxs);
    responseVectorsTrain = responseGc(nOutputs, trainIdxs);
    
    featureVectorsTest = featureVectorGc(:, testIdxs);
    responseVectorsTest = responseGc(nOutputs, testIdxs);
    
    
    %% 6) Train the unprincipled controller
    unprincipledController = ...
        trainFfnn(featureVectorsTrain, responseVectorsTrain, trainControl);
    
    %% 7) Test performance on test data-set
    outputVectorsTest = unprincipledController(featureVectorsTest);
    figure();
    plotregression(responseVectorsTest, outputVectorsTest);
    
    
    %% 8) Simulate t-series behaviour of various controllers
    % NB: this uses simulated/fake data so YMMV!
    Sim.hourNumberTest = mod((1:length(testDemandSeries))', ...
        runControl.MPC.horizon);
    
    runControl.godCast = true;
    runControl.naivePeriodic = false;
    runControl.MPC.setPoint = false;
    runControl.MPC.trainControl = trainControl;
    
    %% 8.1) Exact controller with godCast
    [ runningPeak, ~, ~, b0_godCast, featureVectorGc ] = ...
        mpcController(unprincipledController, godCastTest, testDemandSeries,...
        batteryCapacity, maximumChargeRate, demandDelays, ...
        Sim, runControl);
    
    lastIdxCommon = length(runningPeak) - ...
        mod(length(runningPeak), ...
        runControl.MPC.horizon*runControl.MPC.billingPeriodDays);
    
    idxsCommon = 1:lastIdxCommon;
    
    exact_godCast_prr(tsTrainIdx) =...
        extractSimulationResults(runningPeak(idxsCommon)', ...
        testDemandSeries(idxsCommon),...
        runControl.MPC.horizon*runControl.MPC.billingPeriodDays);
    
    figure();
    plot([testDemandSeries(idxsCommon), runningPeak(idxsCommon)'])
    title(['Exact controller with perfect foresight, ' ...
        num2str(nObservationTrain) ' data points']);
    
    %% 8.1a) Exact controller with modelCast
    
        [ runningPeak, ~, ~, b0_modelCast, featureVectorMc ] = ...
        mpcController(unprincipledController, modelCast, testDemandSeries,...
        batteryCapacity, maximumChargeRate, demandDelays, ...
        Sim, runControl);
   
    exact_MC_prr(tsTrainIdx) =...
        extractSimulationResults(runningPeak(idxsCommon)', ...
        testDemandSeries(idxsCommon),...
        runControl.MPC.horizon*runControl.MPC.billingPeriodDays);
    
    figure();
    plot([testDemandSeries(idxsCommon), runningPeak(idxsCommon)'])
    title(['Exact controller with Model Cast, ' ...
        num2str(nObservationTrain) ' data points']);
    
    %% 8.2) Exact controller with NP forecast
    runControl.godCast = false;
    runControl.naivePeriodic = true;
    runControl.MPC.SPrecourse = true;
    
    [ runningPeak, exitFlag, forecastUsed, b0_NP, featureVectorNp ] = ...
        mpcController(unprincipledController, godCastTest, ...
        testDemandSeries, batteryCapacity, maximumChargeRate, ...
        demandDelays, Sim, runControl);
    
    exact_NP_prr(tsTrainIdx) = ...
        extractSimulationResults(runningPeak(idxsCommon)', ...
        testDemandSeries(idxsCommon),...
        runControl.MPC.horizon*runControl.MPC.billingPeriodDays);
    
    figure();
    plot([testDemandSeries(idxsCommon), runningPeak(idxsCommon)'])
    title(['Exact controller with NP forecast, ' ...
        num2str(nObservationTrain) ' data points']);
    
    %% 8.3) Unprincipled controller
    runControl.MPC.knowFuture = true;
    runControl.MPC.SPrecourse = false;
    runControl.MPC.setPoint = false;
    runControl.MPC.useNPvectors = true;
    
    [ runningPeak, b0_Up, featVectorsUp ] = ...
        mpcControllerForecastFree( unprincipledController, ...
        testDemandSeries, batteryCapacity, maximumChargeRate, ...
        demandDelays, runControl.MPC, Sim);
    
    UP_prr(tsTrainIdx) = extractSimulationResults(...
        runningPeak(idxsCommon)', testDemandSeries(idxsCommon), ...
        runControl.MPC.horizon*runControl.MPC.billingPeriodDays);
    
    figure();
    plot([testDemandSeries(idxsCommon), runningPeak(idxsCommon)'])
    title(['Unprincipled Controller Peak Import VS Local Demand, ' ...
        num2str(nObservationTrain) ' data points']);
    
    disp(['Completed run with ' num2str(nObservationTrain) ' data points']);
    disp(['and ' num2str(unprincipledController.numWeightElements) ...
        ' weighted elements']);
    toc;
end

figure();
semilogx(tsTrainLengths, [exact_godCast_prr, exact_NP_prr, UP_prr, ...
    exact_MC_prr]);
legend({'Exact Controller, God Cast', 'Exact Controller, NP', ...
    'Unprincipled Controller, God Cast', 'Excat controller, modelCast'});
grid on;

figure();
plot([b0_godCast(1:length(b0_Up)); b0_NP(1:length(b0_Up)); b0_Up]');
legend({'Exact Controller, God Cast', 'Exact Controller, NP', ...
    'Unprincipled Controller, God Cast'});
ylabel('Charging decision [kWh]');

figure();
% Test performance during 'on-line' simulation:
outputVectorsSim = unprincipledController(featureVectorGc);
plotregression(b0_godCast, outputVectorsSim);
xlabel('God cast simulation behavior');
ylabel('Response of NN to same inputs');

figure();
plotregression(outputVectorsSim, b0_Up);
xlabel('Response of NN to godCast inputs');
ylabel('b0_Up');

toc;