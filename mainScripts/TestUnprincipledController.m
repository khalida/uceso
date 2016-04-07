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

%% 0) Tidy up & Load functions
clearvars; close all; clc;
rng(42);
tic;
LoadFunctions;
plotEachTrainLength = true;  %#ok<*UNRCH>

%% 1) Running Options
% Optimization
MPC.clipNegativeFcast = true;
MPC.horizon = 48;
Sim.horizon = MPC.horizon;
MPC.knowDemandNow = false;
MPC.chargeWhenCan = false;
MPC.secondWeight = 0;
MPC.rewardMargin = true;
MPC.iterationFactor = 1.0;
MPC.resetPeakToMean = true;
MPC.SPrecourse = true;
MPC.billingPeriodDays = 7;

% Battery System
batteryCapacity = 2.5;
maximumChargeRate = 5;
stepsPerHour = 2;

% Simulation
Sim.stepsPerHour = stepsPerHour;
Sim.k = Sim.horizon;
Sim.forecastModels = 'FFNN';
runControl.MPC = MPC;
runControl.forecastModels = Sim.forecastModels;

% Training Control
trainRatio = 0.75;
trainControl.maxTime = 30*60;
trainControl.suppressOutput = false;
trainControl.trainRatio = trainRatio;
trainControl.performanceDifferenceThreshold = 0.05;
nNodes = 50;


sglMagnitude = 5;
noiseMagnitudes = [0, 1, 2, 3, 4, 5, 6.25, 7.5];

% Attach trainControl to Sim structure, and attach missing data
% (hacky; need to tidy this lot up!!!)
trainControl.horizon = Sim.horizon;
trainControl.nLags = Sim.horizon;
Sim.trainControl = trainControl;
trainControl.nNodes = nNodes;

tsTrainLengths = [16, 32, 64]; % [1, 2, 3]; %

UP_prr = zeros(length(tsTrainLengths), length(noiseMagnitudes));
exact_NP_prr = zeros(length(tsTrainLengths), length(noiseMagnitudes));
exact_MC_prr = zeros(length(tsTrainLengths), length(noiseMagnitudes));
exact_godCast_prr = zeros(length(tsTrainLengths), length(noiseMagnitudes));

for trTrIdx = 1:length(tsTrainLengths)
    parfor noiseIdx = 1:length(noiseMagnitudes)
        % Local copies to avoid parfor issues
        thisSim = Sim;
        thisRunControl = runControl;
        
        noiseMagnitude = noiseMagnitudes(noiseIdx);
        tsTrainLength = tsTrainLengths(trTrIdx).*thisRunControl.MPC.horizon*...
            thisRunControl.MPC.billingPeriodDays; %#ok<*PFBNS>
        
        tsTestLength = 50*thisRunControl.MPC.horizon*...
            thisRunControl.MPC.billingPeriodDays;
        
        %% 2) Create artificial data
        disp('=== Creating Data ===');
        timeSeriesData = noisySine(sglMagnitude, thisSim.horizon, noiseMagnitude,...
            tsTrainLength + tsTestLength);
        
        timeSeriesData = max(0, timeSeriesData);
        avgLoad = mean(timeSeriesData);
        
        trainDemandSeries = timeSeriesData(1:tsTrainLength);
        testDemandSeries = timeSeriesData((length(trainDemandSeries)+1):end);
        if length(testDemandSeries) ~= tsTestLength
            error('Test time series length not as expected');
        end
        
        noiseFreeTs = noisySine(sglMagnitude, thisSim.horizon, 0, ...
            tsTrainLength + tsTestLength);
        
        noiseFreeTs = max(0, noiseFreeTs);
        noiseFreeTsTest = noiseFreeTs((end - (tsTestLength-1)):end);
        demandDelays = trainDemandSeries((end - trainControl.nLags + 1):end);
        
        
        %% 3a) Run exact controller on training data, with godCast to get training
        % data for UP controller
        
        thisSim.hourNumberTest = mod((1:length(trainDemandSeries))', ...
            thisRunControl.MPC.horizon);
        
        godCastTrain = createGodCast(trainDemandSeries, thisRunControl.MPC.horizon);
        
        % featureVectors = [forecasts; stateOfCharges; (demandNows); peakSoFars];
        disp('=== Run t-series Experiments ===');
        
        thisRunControl.godCast = true;
        thisRunControl.naivePeriodic = false;
        thisRunControl.MPC.setPoint = false;
        thisRunControl.MPC.trainControl = trainControl;
        thisRunControl.MPC.UPknowFuture = false;
        
        [ ~, ~, ~, responseGc, featureVectorGc ] = ...
            mpcController([], godCastTrain, ...
            trainDemandSeries, batteryCapacity, maximumChargeRate, ...
            demandDelays, thisSim, thisRunControl);
        
        
        %% 4a) Divide data-set into training/testing and train UP controller
        nObsTrain = size(godCastTrain, 1);
        trainIdxs = 1:ceil(nObsTrain*trainRatio);
        testIdxs = (max(trainIdxs)+1):nObsTrain;
        
        featureVectorsTrain = featureVectorGc(:, trainIdxs);
        responseVectorsTrain = responseGc(:, trainIdxs);
        
        featureVectorsTest = featureVectorGc(:, testIdxs);
        responseVectorsTest = responseGc(:, testIdxs);
        
        %% 4b) Train UP controller
        disp('=== Train UP controller ===');
        unprincipledController = trainFfnnMultiInit(featureVectorsTrain,...
            responseVectorsTrain, trainControl);
        
        
        %% 4c) Test performance on test data-set
        %(this just tests how well an input/output mapping replicates the
        %optimiser)
        if plotEachTrainLength
            disp('=== Train UP controller i/o mapping perf. ===');
            outputVectorsTest = unprincipledController(featureVectorsTest);
            figure();
            plotregression(responseVectorsTest, outputVectorsTest);
        end
        
        
        %% 5) Simulate t-series behaviour of various controllers on Test data set
        % NB: this uses simulated/fake data so YMMV!
        if thisSim.hourNumberTest(end) ~= 0
            error('The last hourNumber needs to be zero for below code to work');
        end
        thisSim.hourNumberTest = mod((1:length(testDemandSeries))', ...
            thisRunControl.MPC.horizon);
        
        thisRunControl.godCast = true;
        thisRunControl.naivePeriodic = false;
        thisRunControl.MPC.setPoint = false;
        thisRunControl.MPC.trainControl = trainControl;
        
        %% 5a) Exact controller with godCast
        godCastTest = createGodCast(testDemandSeries, thisRunControl.MPC.horizon);
        disp('=== SIM: Exact controller, godCast ===');
        [ runningPeak, ~, ~, respGcTest, featVectorGcTest ] = ...
            mpcController([], godCastTest, testDemandSeries,...
            batteryCapacity, maximumChargeRate, demandDelays, ...
            thisSim, thisRunControl);
        
        lastIdxCommon = length(runningPeak) - ...
            mod(length(runningPeak), ...
            thisRunControl.MPC.horizon*thisRunControl.MPC.billingPeriodDays);
        
        idxsCommon = 1:lastIdxCommon;
        
        exact_godCast_prr(trTrIdx, noiseIdx) = ...
            extractSimulationResults(runningPeak(idxsCommon)', ...
            testDemandSeries(idxsCommon),...
            thisRunControl.MPC.horizon*thisRunControl.MPC.billingPeriodDays);
        
        if plotEachTrainLength
            figure();
            plot([testDemandSeries(idxsCommon), runningPeak(idxsCommon)'])
            title(['Exact controller with perfect foresight, ' ...
                num2str(nObsTrain) ' data points']);
            refline(0, avgLoad);
        end
        
        
        %% 5b) Exact controller with modelCast
        modelCast = createGodCast(noiseFreeTsTest, thisRunControl.MPC.horizon);
        thisRunControl.godCast = false;
        thisRunControl.modelCast = true;
        
        disp('=== SIM: Exact controller, modelCast ===');
        [ runningPeak, ~, ~, respVectorMc, featVectorMc ] = ...
            mpcController(unprincipledController, modelCast, testDemandSeries,...
            batteryCapacity, maximumChargeRate, demandDelays, ...
            thisSim, thisRunControl);
        
        exact_MC_prr(trTrIdx, noiseIdx) = ...
            extractSimulationResults(runningPeak(idxsCommon)', ...
            testDemandSeries(idxsCommon),...
            thisRunControl.MPC.horizon*thisRunControl.MPC.billingPeriodDays);
        
        if plotEachTrainLength
            figure();
            plot([testDemandSeries(idxsCommon), runningPeak(idxsCommon)'])
            title(['Exact controller with Model Cast, ' ...
                num2str(nObsTrain) ' data points']);
            refline(0, avgLoad);
        end
        
        %% 5c) Exact controller with NP forecast
        thisRunControl.godCast = false;
        thisRunControl.modelCast = false;
        thisRunControl.naivePeriodic = true;
        thisRunControl.MPC.SPrecourse = true;
        
        disp('=== SIM: Exact controller, NP ===');
        [ runningPeak, exitFlag, fcUsed, respVecNp, featVecNp ] = ...
            mpcController([], godCastTest, testDemandSeries,...
            batteryCapacity, maximumChargeRate, demandDelays, thisSim, thisRunControl);
        
        exact_NP_prr(trTrIdx, noiseIdx) = ...
            extractSimulationResults(runningPeak(idxsCommon)', ...
            testDemandSeries(idxsCommon),...
            thisRunControl.MPC.horizon*thisRunControl.MPC.billingPeriodDays);
        
        if plotEachTrainLength
            figure();
            plot([testDemandSeries(idxsCommon), runningPeak(idxsCommon)'])
            title(['Exact controller with NP forecast, ' ...
                num2str(nObsTrain) ' data points']);
            refline(0, avgLoad);
        end
        
        %% 5d) Unprincipled controller
        thisRunControl.MPC.SPrecourse = true;
        thisRunControl.MPC.setPoint = false;
        
        disp(['=== SIM: UP controller, sees future: ',...
            num2str(thisRunControl.MPC.UPknowFuture), ' ===']);
        
        [ runningPeak, respVecUp, featVecUp, b0_Up_raw ] = ...
            mpcControllerForecastFree( unprincipledController, ...
            testDemandSeries, batteryCapacity, maximumChargeRate, ...
            demandDelays, thisRunControl.MPC, thisSim);
        
        UP_prr(trTrIdx, noiseIdx) = extractSimulationResults(...
            runningPeak(idxsCommon)', testDemandSeries(idxsCommon), ...
            thisRunControl.MPC.horizon*thisRunControl.MPC.billingPeriodDays);
        
        if plotEachTrainLength
            figure();
            plot([testDemandSeries(idxsCommon), runningPeak(idxsCommon)'])
            title(['Unprincipled Controller Peak Import VS Local Demand, ' ...
                num2str(nObsTrain) ' data points']);
            refline(0, avgLoad);
        end
        
        disp(['Completed run with ' num2str(nObsTrain) ' data points']);
        disp(['and ' num2str(unprincipledController.numWeightElements) ...
            ' weighted elements']);
    end
end

% figure();
% subplot(1,2,1);
% semilogx(tsTrainLengths, [exact_NP_prr, exact_MC_prr, exact_godCast_prr, ...
%     UP_prr], '.-');
% legend({'Exact Controller, NP', 'Excat controller, modelCast', ...
%     'Exact Controller, God Cast', 'Unprincipled Controller'});
% grid on;
% ylabel('Peak Reduction Ratio');
% xlabel('No. of training billing periods');
% subplot(1,2,2);
% semilogx(tsTrainLengths, [exact_NP_prr./exact_godCast_prr,...
%     exact_MC_prr./exact_godCast_prr, ...
%     exact_godCast_prr./exact_godCast_prr, UP_prr./exact_godCast_prr],'.-');
% ylabel('Relative Peak Reduction Ratio');
% xlabel('No. of training billing periods');
% grid on;

figure();
for idx = 1:length(tsTrainLengths)
    subplot(length(tsTrainLengths), 2, 2*idx-1);
    plot((noiseMagnitudes./sglMagnitude)', [exact_NP_prr(idx, :);...
        exact_MC_prr(idx, :); exact_godCast_prr(idx, :);...
        UP_prr(idx, :)]', '.-');
    
    legend({'Exact Controller, NP', 'Excat controller, modelCast', ...
        'Exact Controller, God Cast', 'Unprincipled Controller'});
    
    grid on;
    ylabel('Peak Reduction Ratio');
    xlabel('Noise-to-signal Ratio');
    
    subplot(length(tsTrainLengths), 2, 2*idx);
    plot((noiseMagnitudes./sglMagnitude)', ...
        [exact_NP_prr(idx, :)./exact_godCast_prr(idx, :);...
        exact_MC_prr(idx, :)./exact_godCast_prr(idx, :); ...
        exact_godCast_prr(idx, :)./exact_godCast_prr(idx, :);...
        UP_prr(idx, :)./exact_godCast_prr(idx, :)]','.-');
    
    ylabel('Relative Peak Reduction Ratio');
    xlabel('Noise-to-signal Ratio');
    grid on;
end

% figure();
% plot([respGcTest(1, 1:length(respVecUp)); ...
%     respVecNp(1, 1:length(respVecUp)); respVecUp(1, :)]');
%
% legend({'Exact Controller, God Cast', 'Exact Controller, NP', ...
%     'Unprincipled Controller'});
%
% ylabel('Charging decision [kWh]');

% figure();
% % Test performance during 'on-line' simulation:
% outputVectorsSim = unprincipledController(featVecUp);
% plotregression(respGcTest(1,:), outputVectorsSim(1,:));
% xlabel('God cast simulation behavior');
% ylabel('Response of NN to same inputs');

% figure();
% plotregression(outputVectorsSim(1,:), respVecUp(1,:));
% xlabel('Response of NN to godCast inputs');
% ylabel('b0_Up from t-series simulation');

% figure();
% plotregression(outputVectorsSim(1,:), b0_Up_raw);
% xlabel('Response of NN to godCast inputs');
% ylabel('b0_Up_raw from t-series simulation');

toc;