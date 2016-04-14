%% Script to test the performance of an Unprincipled Controller, when
% Trained using output from a principled controller (in our application)

%% minMaxDemand controller has been implemented in controllerOptimizer:
%[energyToBattery, exitFlag] = controllerOptimizer(cfg, ...
            % forecast, demandNow, battery, peakSoFar)

% And it requires the following INPUTS:
% cfg:              Structure of running options
% forecast:         Demand forecast for next k steps [kWh]
% stateOfCharge:    [kWh] in battery at start of interval
% demandNow:        Actual demand for current interval [kWh]
% battery:          Structure containing information about the batt [kWh]
% peakSoFar:        Running peak demand in billing period [kWh]


%% oso controller implemented in controllerDp.m
% [bestChargeStep, bestCTG] = controllerDp(cfg, demForecast, pvForecast, ...
            % battery, hourNow);
            
% cfg:              Structure of running options
% dem|pv|forecast:  Demand and PV forecast for next cfg.sim.horizon steps [kWh]
% SoC_initstateOfCharge:    [kWh] in battery at start of interval
% battery:          Object representing the battery
% hourNow:          Time of day


%% 0) Tidy up & Load functions
clearvars; close all; clc;
rng(42);
tic;
LoadFunctions;
plotEachTrainLength = true;  %#ok<*UNRCH>

%% 1) Running Options
% Load from Config():
cfg = Config(pwd);
type = 'oso';      % {'oso', 'minMaxDemand'}, division between two methods messy at the moment


%% Declare properties of artificial demand / pv signal
sglMagnitude = 5;
noiseMagnitudes = [0, 2.5, 5, 7.5, 10];
tsTrainLengths = 2; %[32]; %#ok<NBRAK>
tsTestLength = 2*cfg.sim.horizon*cfg.sim.billingPeriodDays;

%% Initialize results vectors
prr_UC = zeros(length(tsTrainLengths), length(noiseMagnitudes));
prr_exactNP = prr_UC;
prr_exactMC = prr_UC;
prr_SP = prr_UC;
prr_exactGodCast = prr_UC;

for tsTrIdx = 1:length(tsTrainLengths)
    
    tsTrainLength = tsTrainLengths(tsTrIdx)*cfg.sim.horizon*...
        cfg.sim.billingPeriodDays;
    
    parfor noiseIdx = 1:length(noiseMagnitudes)
        
        runControl = [];        % avoid parfor error
        ax = cell(5,1);
        tsFig = [];
        
        noiseMagnitude = noiseMagnitudes(noiseIdx);
        
        %% 2) Create artificial data
        disp('=== Creating Data ===');
        timeSeriesData = noisySine(sglMagnitude, cfg.fc.seasonalPeriod,...
            noiseMagnitude, tsTrainLength + tsTestLength); %#ok<*PFBNS>
        
        timeSeriesData = max(0, timeSeriesData);
        avgLoad = mean(timeSeriesData);
        
        % And PV data if we're looking at OSO:
        if isequal(type, 'oso')
            timeSeriesDataPv = noisySine(sglMagnitude, cfg.fc.seasonalPeriod,...
                noiseMagnitude, tsTrainLength + tsTestLength); %#ok<*PFBNS>
        
            timeSeriesDataPv = max(0, timeSeriesDataPv);
            timeSeriesDataPv = circshift(timeSeriesDataPv, ...
                [floor(cfg.fc.seasonalPeriod/2), 0]);
            
        % Declare battery properties
        elseif isequal(type, 'minMaxDemand')
            battery = Battery(cfg, avgLoad*cfg.sim.batteryCapacityRatio*...
            cfg.sim.stepsPerDay);
        else
            error('type of optimization not implemented yet');
        end
        
        trainDemandSeries = timeSeriesData(1:tsTrainLength);
        testDemandSeries = timeSeriesData((length(trainDemandSeries)...
            +1):end);
        if length(testDemandSeries) ~= tsTestLength
            error('Demand Test time series length not as expected');
        end
        
        if isequal(type, 'oso')
            trainPvSeries = timeSeriesDataPv(1:tsTrainLength);
            testPvSeries = timeSeriesDataPv((length(trainDemandSeries)...
                +1):end);
            if length(testPvSeries) ~= tsTestLength
                error('PV Test time series length not as expected');
            end
        end
        
        noiseFreeTs = noisySine(sglMagnitude, cfg.fc.seasonalPeriod, 0, ...
            tsTrainLength + tsTestLength);
        
        noiseFreeTs = max(0, noiseFreeTs);
        noiseFreeTsTest = noiseFreeTs((end - (tsTestLength-1)):end);
        
        if isequal(type, 'oso')
            noiseFreeTsPv = circshift(noiseFreeTs, ...
                [floor(cfg.fc.seasonalPeriod/2), 0]);
            
            noiseFreeTsPvTest = noiseFreeTsPv((end - (tsTestLength-1)):...
                end);
        end
        
        % Separate off data for initialization:
        demandDelays = trainDemandSeries(1:cfg.fc.nLags);
        trainDemandData = trainDemandSeries((cfg.fc.nLags + 1):end);
        
        if isequal(type, 'oso')
            % Separate off data for initialization:
            pvDelays = trainPvSeries(1:cfg.fc.nLags);
            trainPvData = trainPvSeries((cfg.fc.nLags + 1):end); 
        end
        
        %% 3a) Run exact controller on training data, with godCast
        % to get training data for UC
        godCastTrain = createGodCast(trainDemandData, cfg.sim.horizon);
        
        if isequal(type, 'oso')
            godCastTrainPv = createGodCast(trainPvData, cfg.sim.horizon);
        end
        
        disp('=== Run t-series Experiments ===');
        
        if isequal(type, '')
            runControl.godCast = true;
            runControl.naivePeriodic = false;
            runControl.setPoint = false;
            runControl.modelCast = false;
            runControl.forecastFree = false;
            runControl.type = type;
            
            [ ~, ~, ~, responseGc, featureVectorGc, ~] = mpcController(cfg, ...
                [], godCastTrain, trainDemandData, demandDelays, battery,...
                runControl);
        else
            % For now: just have separate controller function (to be tidied)
            [ totalCost, chargeProfile, totalDamageCost, ...
                demForecastUsed, pvForecastUsed, chargeDecisions] = ...
                mpcControllerDp( [], godCastTrain, trainDemandData,...
                godCastTrainPv, trainPvData, cfg.sim, demandDelays, pvDelays,...
                runControl)
            
            % Response <chargeDecision, (Var. to do with SetPoint)>
            responseGc = ;
            
            % Feature <>
            featureVectorGc = ;
        end
        
        %% 4a) Divide data into training/testing and train UC
        nObsTrain = size(godCastTrain, 1);
        trainIdxs = 1:ceil(nObsTrain*cfg.fc.trainRatio);
        testIdxs = (max(trainIdxs)+1):nObsTrain;
        
        featVecsTrain = featureVectorGc(:, trainIdxs);
        respVecsTrain = responseGc(:, trainIdxs);
        
        featVecsVal = featureVectorGc(:, testIdxs);
        respVecsVal = responseGc(:, testIdxs);
        
        
        %% 4b) Train UP controller
        disp('=== Train UP controller ===');
        unprincipledController = trainFfnnMultiInit(cfg, featVecsTrain,...
            respVecsTrain);
        
        
        %% 4c) Performance on validation data
        %(this just tests how well an input/output mapping replicates the
        %optimiser)
        if plotEachTrainLength
            figure();
            estimatedRespVecsVal = unprincipledController(featVecsVal);
            plotregression(respVecsVal, estimatedRespVecsVal);
            title('Train Unprincipled Controller i/o mapping perf.');
            saveas(gcf, [cfg.sav.resultsDir filesep 'reg_nseIdx'...
                num2str(noiseIdx) 'tsIdx' num2str(tsTrIdx) '.fig']);
        end
        
        
        %% 5) Simulate t-series behaviour of various controllers
        % on test data, NB: this uses simulated/fake data so YMMV!
        
        %% 5a) Exact controller with godCast
        % Separate off data for initialization:
        runControl.godCast = true;
        runControl.naivePeriodic = false;
        runControl.setPoint = false;
        runControl.modelCast = false;
        runControl.forecastFree = false;
        
        demandDelays = testDemandSeries(1:cfg.fc.nLags);
        testDemandData = testDemandSeries((cfg.fc.nLags + 1):end);
        godCastTest = createGodCast(testDemandData, cfg.sim.horizon);
        
        disp('=== SIM: Exact controller, godCast ===');
        [ runningPeak, ~, ~, respGcTest, featVectorGcTest, ~] = ...
            mpcController(cfg, [], godCastTest, testDemandData, ...
            demandDelays, battery, runControl);
        
        lastIdxCommon = length(runningPeak) - mod(length(runningPeak), ...
            cfg.sim.horizon*cfg.sim.billingPeriodDays);
        
        idxsCommon = 1:lastIdxCommon;
        
        prr_exactGodCast(tsTrIdx, noiseIdx) = ...
            extractSimulationResults(runningPeak(idxsCommon)', ...
            testDemandSeries(idxsCommon),...
            cfg.sim.horizon*cfg.sim.billingPeriodDays);
        
        if plotEachTrainLength
            tsFig = figure();
            plotIdx = 1;
            ax{plotIdx} = plotMpcTseries(tsFig, plotIdx, ...
                testDemandSeries(idxsCommon), runningPeak(idxsCommon), ...
                avgLoad, featVectorGcTest(cfg.fc.nLags+1,idxsCommon), ...
                battery, 'Exact ctrl, PF fcast', nObsTrain);
        end
        
        %% 5b) Exact controller with modelCast
        modelCastData = noiseFreeTsTest((cfg.fc.nLags + 1):end);
        modelCast = createGodCast(modelCastData, cfg.sim.horizon);
        
        runControl.godCast = false;
        runControl.naivePeriodic = false;
        runControl.setPoint = false;
        runControl.modelCast = true;
        runControl.forecastFree = false;
                        
        disp('=== SIM: Exact controller, modelCast ===');
        [ runningPeak, ~, ~, respVectorMc, featVectorMc, ~] = ...
            mpcController(cfg, [], modelCast, testDemandData, ...
            demandDelays, battery, runControl);
        
        prr_exactMC(tsTrIdx, noiseIdx) = ...
            extractSimulationResults(runningPeak(idxsCommon)', ...
            testDemandSeries(idxsCommon),...
            cfg.sim.horizon*cfg.sim.billingPeriodDays);
        
        if plotEachTrainLength
            plotIdx = 2;
            ax{plotIdx} = plotMpcTseries(tsFig, plotIdx, testDemandSeries(idxsCommon),...
                runningPeak(idxsCommon), avgLoad, ...
                featVectorMc(cfg.fc.nLags+1,idxsCommon), battery,...
                'Exact ctrl, Mdl fcast', nObsTrain);
        end
        
        %% 5c) Exact controller with NP forecast
        runControl.godCast = false;
        runControl.naivePeriodic = true;
        runControl.setPoint = false;
        runControl.modelCast = false;
        runControl.forecastFree = false;
        
        disp('=== SIM: Exact controller, NP ===');
        [ runningPeak, ~, ~, respVecNp, featVecNp, ~] = ...
            mpcController(cfg, [], godCastTest, testDemandData, ...
            demandDelays, battery, runControl);

        prr_exactNP(tsTrIdx, noiseIdx) = ...
            extractSimulationResults(runningPeak(idxsCommon)', ...
            testDemandSeries(idxsCommon),...
            cfg.sim.horizon*cfg.sim.billingPeriodDays);
        
        if plotEachTrainLength
            plotIdx = 3;
            ax{plotIdx} = plotMpcTseries(tsFig, plotIdx, testDemandSeries(idxsCommon),...
                runningPeak(idxsCommon), avgLoad, ...
                featVecNp(cfg.fc.nLags+1,idxsCommon), battery,...
                'Exact ctrl, NP fcast', nObsTrain);
        end
        
        %% 5d) Unprincipled controller
        runControl.godCast = false;
        runControl.naivePeriodic = false;
        runControl.setPoint = false;
        runControl.modelCast = false;
        runControl.forecastFree = true;
        
        disp(['=== SIM: UP controller, sees future: ',...
            num2str(cfg.fc.knowFutureFF), ' ===']);
        
        [ runningPeak, ~, ~, respVecUp, featVecUp, b0_Up_raw ] = ...
            mpcController(cfg, unprincipledController, ...
            godCastTest, testDemandData, demandDelays, battery, ...
            runControl);
        
        prr_UC(tsTrIdx, noiseIdx) = extractSimulationResults(...
            runningPeak(idxsCommon)', testDemandSeries(idxsCommon), ...
            cfg.sim.horizon*cfg.sim.billingPeriodDays);
        
        if plotEachTrainLength
            plotIdx = 4;
            ax{plotIdx} = plotMpcTseries(tsFig, plotIdx, testDemandSeries(idxsCommon),...
                runningPeak(idxsCommon), avgLoad, ...
                featVecUp(cfg.fc.nLags+1,idxsCommon), battery,...
                'Unprinc ctrl, NP fcast', nObsTrain);
        end
        
        %% 5e) Set-Point Controller
        runControl.godCast = false;
        runControl.naivePeriodic = false;
        runControl.setPoint = true;
        runControl.modelCast = false;
        runControl.forecastFree = false;
        
        disp('=== SIM: SP Controller ===');
        [ runningPeak, exitFlag, fcUsed, ~, featVecSp, ~] = ...
            mpcController(cfg, [], godCastTest, testDemandData, ...
            demandDelays, battery, runControl);

        prr_SP(tsTrIdx, noiseIdx) = ...
            extractSimulationResults(runningPeak(idxsCommon)', ...
            testDemandSeries(idxsCommon),...
            cfg.sim.horizon*cfg.sim.billingPeriodDays);
        
        if plotEachTrainLength
            plotIdx = 5;
            ax{plotIdx} = plotMpcTseries(tsFig, plotIdx, testDemandSeries(idxsCommon),...
                runningPeak(idxsCommon), avgLoad, ...
                featVecUp(cfg.fc.nLags+1,idxsCommon), battery,...
                'SP ctrl', nObsTrain);
            
            % Link x axes for plotting:
            linkaxes([ax{:}], 'x');
            
            saveas(gcf, [cfg.sav.resultsDir filesep 'tSeries_nseIdx'...
                num2str(noiseIdx) 'tsIdx' num2str(tsTrIdx) '.fig']);
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

fig_1 = figure();
for idx = 1:length(tsTrainLengths)
    subplot(length(tsTrainLengths), 2, 2*idx-1);
    plot((noiseMagnitudes./sglMagnitude)', [prr_exactNP(idx, :);...
        prr_exactMC(idx, :); prr_exactGodCast(idx, :);...
        prr_UC(idx, :); prr_SP(idx, :)]', '.-');
    
    legend({'Exact Controller, NP', 'Excat controller, modelCast', ...
        'Exact Controller, God Cast', 'Unprincipled Controller', ...
        'SP Controller'});
    
    grid on;
    ylabel(['PRR, billing periods train: ' num2str(tsTrainLengths(idx))]);
    xlabel('Noise-to-signal Ratio');
    
    subplot(length(tsTrainLengths), 2, 2*idx);
    plot((noiseMagnitudes./sglMagnitude)', ...
        [prr_exactNP(idx, :)./prr_exactGodCast(idx, :);...
        prr_exactMC(idx, :)./prr_exactGodCast(idx, :); ...
        prr_exactGodCast(idx, :)./prr_exactGodCast(idx, :);...
        prr_UC(idx, :)./prr_exactGodCast(idx, :); ...
        prr_SP(idx, :)./prr_exactGodCast(idx, :)]','.-');
    
    ylabel('Relative PRR');
    xlabel('Noise-to-signal Ratio');
    grid on;
end

% Save the above figure:
print(fig_1, '-dpdf', [cfg.sav.resultsDir filesep ...
    'TestUnprincipledControllerResults.pdf']);

% And the data:
save([cfg.sav.resultsDir filesep 'TestUnpCtrlrResults.mat'], '-v7.3');

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