%% Script to test the performance of an Unprincipled Controller, when
% Trained using output from a principled controller (in our application)

%% minMaxDemand controller has been implemented in controllerOptimizer:
%[ runningPeak, exitFlag, forecastUsed, respVecs, featVecs, ...
%    b0_raw ] = mpcController(cfg, trainedModel, godCast, demand, ...
%    demandDelays, battery, runControl)

% And it requires the following INPUTS:
% cfg:              Structure of running options
% trainedModel:     Trained forecast (or unprincipled controller) model
% godCast:          Matrix of perfect foresight forecasts
% denmand:          Demand time series on which to run model [kWh]
% demandDelays:     Initial nLag lags of demand [kWh]
% battery:          Structure containing information about the batt
% runControl:       Running options


%% oso controller implemented in controllerDp.m
% [ totalCost, chargeProfile, totalDamageCost, demForecastUsed,...
%    pvForecastUsed, respVecs, featVecs, bestCTG] = mpcControllerDp(cfg, ...
%    trainedModel, demGodCast, demand, pvGodCast, pv, demandDelays,...
%    pvDelays, battery, runControl)

% And it requires the following INPUTS:
% cfg:              Structure of running options
% trainedModel:     Trained forecast (or unprincipled controller) model
% dem|pv|godCast:   Demand and PV perfect foresight forecast [kWh]
% demand|pv:        Demand and PV time series on which to run mdoel [kWh]
% demand|pv|Delays: Initial nLag lags of demand and pv [kWh]
% battery:          Object representing the battery
% runControl:       Running options


%% 0) Tidy up & Load functions
clearvars; close all; clc;
rng(42);
tic;
LoadFunctions;
plotEachTrainLength = true;  %#ok<*UNRCH>


%% 1) Running Options
% Load from Config():
cfg = Config(pwd);


%% Declare properties of artificial demand / pv signal
sglMagnitude = 5/cfg.sim.stepsPerHour;  % peak of 5kWh/hour
noiseMagnitudes = sglMagnitude.*[0, 0.5, 1, 1.5]; % ];
tsTrainLengths = [8, 16]; 
tsTestLength = 16*cfg.sim.horizon*cfg.sim.billingPeriodDays;


%% Initialize results vectors
% NB: performance is Peak reduction ratio for minMaxDemand (high good), for
% oso it is the totalCost (low good)
perf_UC = zeros(length(tsTrainLengths), length(noiseMagnitudes));
perf_exactNP = perf_UC;
perf_exactMC = perf_UC;
perf_SP = perf_UC;
perf_exactGodCast = perf_UC;

estNoiseRatio = zeros(length(tsTrainLengths), length(noiseMagnitudes));

for tsTrIdx = 1:length(tsTrainLengths)
    
    tsTrainLength = tsTrainLengths(tsTrIdx)*cfg.sim.horizon*...
        cfg.sim.billingPeriodDays;
    
    parfor noiseIdx = 1:length(noiseMagnitudes)
%     for noiseIdx = 1:length(noiseMagnitudes)
        
        % Clear variables to avoid parfor warnings
        runControl = [];        
        ax = cell(5,1);
        tsFig = [];
        timeSeriesDataPv = [];
        battery = []; %#ok<NASGU>
        trainPvSeries = [];
        testPvSeries = [];
        noiseFreeTsTestPv = []; idxsCommon = [];
        pvDelays = []; trainPvData = []; godCastTrainPv = [];
        testPvData = []; godCastTestPv = []; runningPeak = [];
        imp = []; exp = [];
        
        noiseMagnitude = noiseMagnitudes(noiseIdx);
        
        %% 2) Create artificial data
        disp(' === Creating Data === ');
        timeSeriesDataDem = noisySine(sglMagnitude/2, cfg.fc.seasonalPeriod,...
            noiseMagnitude, tsTrainLength + tsTestLength); %#ok<*PFBNS>
        
        timeSeriesDataDem = max(0, timeSeriesDataDem);
        timeSeriesDataDem = timeSeriesDataDem + 2.*circshift(...
            timeSeriesDataDem, [floor(cfg.fc.seasonalPeriod/2),0]);
        
        avgLoad = mean(timeSeriesDataDem);
        
        % And PV data if we're looking at OSO:
        if isequal(cfg.type, 'oso')
            timeSeriesDataPv = noisySine(sglMagnitude, ...
                cfg.fc.seasonalPeriod, noiseMagnitude, tsTrainLength +...
                tsTestLength); %#ok<*PFBNS>
            
            timeSeriesDataPv = max(0, timeSeriesDataPv);
            timeSeriesDataPv = circshift(timeSeriesDataPv, ...
                [floor(cfg.fc.seasonalPeriod/4), 0]);
            
            % Declare battery properties (oso)
            battery = Battery(cfg, cfg.sim.batteryCapacity);
            
        elseif isequal(cfg.type, 'minMaxDemand')
            % Declare battery properties (minMaxDemand)
            battery = Battery(cfg, avgLoad*cfg.sim.batteryCapacityRatio*...
                cfg.sim.stepsPerDay);
        else
            error('type of optimization not implemented yet');
        end
        
        trainDemandSeries = timeSeriesDataDem(1:tsTrainLength);
        testDemandSeries = timeSeriesDataDem((length(trainDemandSeries)...
            +1):end);
        if length(testDemandSeries) ~= tsTestLength
            error('Demand Test time series length not as expected');
        end
        
        if isequal(cfg.type, 'oso')
            trainPvSeries = timeSeriesDataPv(1:tsTrainLength);
            testPvSeries = timeSeriesDataPv((length(trainDemandSeries)...
                +1):end);
            if length(testPvSeries) ~= tsTestLength
                error('PV Test time series length not as expected');
            end
        end
        
        timeSeriesDataDem = timeSeriesDataDem + 2.*circshift(...
            timeSeriesDataDem, [floor(cfg.fc.seasonalPeriod/2),0]);
        
        
        noiseFreeTsDem = noisySine(sglMagnitude/2, cfg.fc.seasonalPeriod,...
            0, tsTrainLength + tsTestLength);
        
        noiseFreeTsDem = max(0, noiseFreeTsDem);
        
        noiseFreeTsDem = noiseFreeTsDem + 2.*circshift(...
            noiseFreeTsDem, [floor(cfg.fc.seasonalPeriod/2),0]);
        
        noiseFreeTsTestDem = noiseFreeTsDem((end - (tsTestLength-1)):end);
        
        if isequal(cfg.type, 'oso')
            noiseFreeTsPv = circshift(noiseFreeTsDem, ...
                [floor(cfg.fc.seasonalPeriod/4), 0]);
            
            noiseFreeTsTestPv = noiseFreeTsPv((end - (tsTestLength-1)):...
                end);
        end
        
        % Separate off data for initialization:
        demandDelays = trainDemandSeries(1:cfg.fc.nLags);
        trainDemandData = trainDemandSeries((cfg.fc.nLags + 1):end);
        
        if isequal(cfg.type, 'oso')
            % Separate off data for initialization:
            pvDelays = trainPvSeries(1:cfg.fc.nLags);
            trainPvData = trainPvSeries((cfg.fc.nLags + 1):end);
        end
        
        %% 3a) Run exact controller on training data, with godCast
        % to get training data for UC
        godCastTrainDem = createGodCast(trainDemandData, cfg.sim.horizon);
        
        if isequal(cfg.type, 'oso')
            godCastTrainPv = createGodCast(trainPvData, cfg.sim.horizon);
        end
        
        disp('=== Run t-series Experiments ===');
        
        runControl.godCast = true;
        runControl.naivePeriodic = false;
        runControl.setPoint = false;
        runControl.modelCast = false;
        runControl.forecastFree = false;
        runControl.NB = false;
        runControl.randomizeInterval = cfg.fc.randomizeInterval;  
        
        if isequal(cfg.type, 'oso')
            % How often to randomise storage SoC; train in robustness
            runControl.randomizeInterval = cfg.fc.randomizeInterval;  
            
            [ ~, ~, ~, ~, ~, responseGc, featureVectorGc, bestCTG, imp,...
                exp] = mpcControllerDp(cfg, [], godCastTrainDem,...
                trainDemandData, godCastTrainPv, trainPvData,...
                demandDelays, pvDelays, battery, runControl);
            
        else
            [ ~, ~, ~, responseGc, featureVectorGc, ~] = mpcController(...
                cfg, [], godCastTrainDem, trainDemandData, demandDelays,...
                battery, runControl);
        end
        
        runControl = rmfield(runControl, 'randomizeInterval');
        
        %% 4a) Divide data into training/testing and train UC
        nObsTrain = size(featureVectorGc, 2);
        randIdxs = 1:nObsTrain; % randIdxs = randperm(nObsTrain);
        trainIdxs = randIdxs(1:ceil(nObsTrain*cfg.fc.trainRatio));
        testIdxs = randIdxs((length(trainIdxs)+1):nObsTrain);
        
        featVecsTrain = featureVectorGc(:, trainIdxs);
        respVecsTrain = responseGc(:, trainIdxs);
        
        featVecsVal = featureVectorGc(:, testIdxs);
        respVecsVal = responseGc(:, testIdxs);
        
        
        %% 4b) Train UP controller
        disp('=== Train UP controller ===');
        unprincipledController = trainFfnnMultiInit(cfg, featVecsTrain,...
            respVecsTrain);
        
        
        %% 4c) Performance on validation data
        % (this just tests how well an input/output mapping replicates the
        % optimiser, nothing to do with if controller works!)
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
        runControl.NB = false;
        
        demandDelays = testDemandSeries(1:cfg.fc.nLags);
        testDemandData = testDemandSeries((cfg.fc.nLags + 1):end);
        godCastTestDem = createGodCast(testDemandData, cfg.sim.horizon);
        
        disp('=== SIM: Exact controller, godCast ===');
        if isequal(cfg.type, 'oso')
            nStates = length(battery.statesInt);
            runControl.initialState = battery.statesInt(fix(nStates/2)+1);
            
            % Run OSO model
            pvDelays = testPvSeries(1:cfg.fc.nLags);
            testPvData = testPvSeries((cfg.fc.nLags + 1):end);
            godCastTestPv = createGodCast(testPvData, cfg.sim.horizon);
            
            [ totalCost, ~, totalDamageCost, ~, ~,...
                respGcTest, featVectorGcTest, ~, imp, exp] = mpcControllerDp(cfg, ...
                [], godCastTestDem, testDemandData, godCastTestPv,...
                testPvData, demandDelays, pvDelays, battery, runControl);
            
            perf_exactGodCast(tsTrIdx, noiseIdx) = totalCost - ...
                totalDamageCost;
            
        else
            % Run minMaxDemand model
            [ runningPeak, ~, ~, respGcTest, featVectorGcTest, ~] = ...
                mpcController(cfg, [], godCastTestDem, testDemandData, ...
                demandDelays, battery, runControl);
            
            lastIdxCommon = length(runningPeak) - mod(length(...
                runningPeak), cfg.sim.horizon*cfg.sim.billingPeriodDays);
            
            idxsCommon = 1:lastIdxCommon;
            
            perf_exactGodCast(tsTrIdx, noiseIdx) = ...
                extractSimulationResults(runningPeak(idxsCommon)', ...
                testDemandSeries(idxsCommon),...
                cfg.sim.horizon*cfg.sim.billingPeriodDays);
        end
        
        % Do plotting if requested
        if plotEachTrainLength
            tsFig = figure();
            plotIdx = 1;
            if isequal(cfg.type, 'minMaxDemand')
                ax{plotIdx} = plotMpcTseries(tsFig, plotIdx, ...
                    testDemandSeries(idxsCommon), runningPeak(idxsCommon),...
                    avgLoad, featVectorGcTest(cfg.fc.nLags+1,idxsCommon),...
                    battery, 'Exact ctrl, PF fcast', nObsTrain);
            else
                ax{plotIdx} = plotDpTseries(tsFig, plotIdx, ...
                    testDemandData, testPvData, ...
                    featVectorGcTest(end-1,:), battery, ...
                    'Exact ctrl, PF fcast', nObsTrain, imp, exp);
            end
        end
        
        %% 5b) Exact controller with modelCast
        modelCastDataDem = noiseFreeTsTestDem((cfg.fc.nLags + 1):end);
        modelCastDem = createGodCast(modelCastDataDem, cfg.sim.horizon);
        
        runControl.godCast = false;
        runControl.naivePeriodic = false;
        runControl.setPoint = false;
        runControl.modelCast = true;
        runControl.forecastFree = false;
        runControl.NB = false;
        
        disp('=== SIM: Exact controller, modelCast ===');
        
        if isequal(cfg.type, 'oso')
            % Run OSO model
            modelCastDataPv = noiseFreeTsTestPv((cfg.fc.nLags + 1):end);
            modelCastPv = createGodCast(modelCastDataPv, cfg.sim.horizon);
            
            [ totalCost, ~, totalDamageCost, ~, ~,...
                respVectorMc, featVectorMc, ~, imp, exp] = mpcControllerDp(cfg, [],...
                modelCastDem, testDemandData, modelCastPv, testPvData,...
                demandDelays, pvDelays, battery, runControl);
            
            perf_exactMC(tsTrIdx, noiseIdx) = totalCost - totalDamageCost;
            
        else
            % Run minMaxDemand model
            [ runningPeak, ~, ~, respVectorMc, featVectorMc, ~] = ...
                mpcController(cfg, [], modelCastDem, testDemandData, ...
                demandDelays, battery, runControl);
            
            perf_exactMC(tsTrIdx, noiseIdx) = ...
                extractSimulationResults(runningPeak(idxsCommon)', ...
                testDemandSeries(idxsCommon),...
                cfg.sim.horizon*cfg.sim.billingPeriodDays);
        end
        
        
        if plotEachTrainLength
            plotIdx = 2;
            if isequal(cfg.type, 'minMaxDemand')
                ax{plotIdx} = plotMpcTseries(tsFig, plotIdx,...
                    testDemandSeries(idxsCommon), ...
                    runningPeak(idxsCommon), avgLoad, ...
                    featVectorMc(cfg.fc.nLags+1,idxsCommon), battery,...
                    'Exact ctrl, Mdl fcast', nObsTrain);
            else
                ax{plotIdx} = plotDpTseries(tsFig, plotIdx, ...
                    testDemandData, testPvData, ...
                    featVectorMc(end-1,:), battery, ...
                    'Exact ctrl, Mdl fcast', nObsTrain, imp, exp);
            end
        end
        
        estNoiseRatio(tsTrIdx, noiseIdx) = sqrt(mse(godCastTestDem, ...
                    modelCastDem))/rms(modelCastDem(:));
        
        %% 5c) Exact controller with NP forecast
        runControl.godCast = false;
        runControl.naivePeriodic = true;
        runControl.setPoint = false;
        runControl.modelCast = false;
        runControl.forecastFree = false;
        runControl.NB = false;
        
        disp('=== SIM: Exact controller, NP ===');
        if isequal(cfg.type, 'oso')
            % Run OSO model
            modelCastDataPv = noiseFreeTsTestPv((cfg.fc.nLags + 1):end);
            modelCastPv = createGodCast(modelCastDataPv, cfg.sim.horizon);
            
            [  totalCost, ~, totalDamageCost, ~, ~, ...
                respVecNp, featVecNp, ~, imp, exp] = mpcControllerDp(cfg, [],...
                godCastTestDem, testDemandData, godCastTestPv, testPvData,...
                demandDelays, pvDelays, battery, runControl);
           
            perf_exactNP(tsTrIdx, noiseIdx) = totalCost - totalDamageCost;
            
        else
            % Run minMaxDemand model
            [ runningPeak, ~, ~, respVecNp, featVecNp, ~] = ...
                mpcController(cfg, [], godCastTestDem, testDemandData, ...
                demandDelays, battery, runControl);
            
            perf_exactNP(tsTrIdx, noiseIdx) = ...
                extractSimulationResults(runningPeak(idxsCommon)', ...
                testDemandSeries(idxsCommon),...
                cfg.sim.horizon*cfg.sim.billingPeriodDays);
        end
        
        if plotEachTrainLength
            plotIdx = 3;
            if isequal(cfg.type, 'minMaxDemand')
                ax{plotIdx} = plotMpcTseries(tsFig, plotIdx, ...
                    testDemandSeries(idxsCommon), runningPeak(idxsCommon),...
                    avgLoad, featVecNp(cfg.fc.nLags+1,idxsCommon), battery,...
                    'Exact ctrl, NP fcast', nObsTrain);
            else
                ax{plotIdx} = plotDpTseries(tsFig, plotIdx, ...
                    testDemandData, testPvData, ...
                    featVecNp(end-1,:), battery, ...
                    'Exact ctrl, NP fcast', nObsTrain, imp, exp);
            end
        end
        
    %% 5d) Unprincipled controller
    runControl.godCast = false;
        runControl.naivePeriodic = false;
        runControl.setPoint = false;
        runControl.modelCast = false;
        runControl.forecastFree = true;
        runControl.NB = false;
        
        disp(['=== SIM: UP controller, sees future: ',...
            num2str(cfg.fc.knowFutureFF), ' ===']);
        
        if isequal(cfg.type, 'oso')
            % Run OSO model
            [ totalCost, b0_Up_raw, totalDamageCost, ~, ~, ...
                respVecUp, featVecUp, ~, imp, exp] = mpcControllerDp(cfg, ...
                unprincipledController, godCastTestDem, testDemandData,...
                godCastTestPv, testPvData, demandDelays, pvDelays,...
                battery, runControl);

            perf_UC(tsTrIdx, noiseIdx) = totalCost - totalDamageCost;
            
        else
            % Run minMaxDemand model
            [ runningPeak, ~, ~, respVecUp, featVecUp, b0_Up_raw ] = ...
                mpcController(cfg, unprincipledController, ...
                godCastTestDem, testDemandData, demandDelays, battery, ...
                runControl);
            
            perf_UC(tsTrIdx, noiseIdx) = extractSimulationResults(...
                runningPeak(idxsCommon)', testDemandSeries(idxsCommon), ...
                cfg.sim.horizon*cfg.sim.billingPeriodDays);
        end
        
        
        if plotEachTrainLength
            plotIdx = 4;
            if isequal(cfg.type, 'minMaxDemand')
                ax{plotIdx} = plotMpcTseries(tsFig, plotIdx, ...
                    testDemandSeries(idxsCommon), runningPeak(idxsCommon),...
                    avgLoad, featVecUp(cfg.fc.nLags+1,idxsCommon), battery,...
                    'Unprinc ctrl, NP fcast', nObsTrain);
                
            else
                ax{plotIdx} = plotDpTseries(tsFig, plotIdx, ...
                    testDemandData, testPvData, ...
                    featVecUp(end-1,:), battery, ...
                    'Unprinc ctrl, NP fcast', nObsTrain, imp, exp);
            end
        end
        
        %% 5e) Set-Point Controller
        runControl.godCast = false;
        runControl.naivePeriodic = false;
        runControl.setPoint = true;
        runControl.modelCast = false;
        runControl.forecastFree = false;
        runControl.NB = false;
        
        disp('=== SIM: SP Controller ===');
        if isequal(cfg.type, 'oso')
            % Run OSO model
            [ totalCost, ~, totalDamageCost, ~, ~, ~, featVecSp, ~,...
                imp, exp]= mpcControllerDp(cfg, unprincipledController, ...
                godCastTestDem, testDemandData, godCastTestPv, ...
                testPvData, demandDelays, pvDelays, battery, runControl);
            
            perf_SP(tsTrIdx, noiseIdx) = totalCost - totalDamageCost;
        else
            % Run minMaxDemand model
            [ runningPeak, ~, ~, ~, featVecSp, ~] = ...
                mpcController(cfg, [], godCastTestDem, testDemandData, ...
                demandDelays, battery, runControl);
            
            perf_SP(tsTrIdx, noiseIdx) = ...
                extractSimulationResults(runningPeak(idxsCommon)', ...
                testDemandSeries(idxsCommon),...
                cfg.sim.horizon*cfg.sim.billingPeriodDays);
        end
        
        if plotEachTrainLength
            plotIdx = 5;
            if isequal(cfg.type, 'minMaxDemand')
                ax{plotIdx} = plotMpcTseries(tsFig, plotIdx, testDemandSeries(idxsCommon),...
                    runningPeak(idxsCommon), avgLoad, ...
                    featVecSp(cfg.fc.nLags+1,idxsCommon), battery,...
                    'SP ctrl', nObsTrain);
                
            else
                ax{plotIdx} = plotDpTseries(tsFig, plotIdx, ...
                    testDemandData, testPvData, ...
                    featVecSp(end-1,:), battery, ...
                    'SP ctrl', nObsTrain, imp, exp);
            end
            
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
    plot((noiseMagnitudes./sglMagnitude)', [perf_exactNP(idx, :);...
        perf_exactMC(idx, :); perf_exactGodCast(idx, :);...
        perf_UC(idx, :); perf_SP(idx, :)]', '.-');
    
    legend({'Exact Controller, NP', 'Excat controller, modelCast', ...
        'Exact Controller, God Cast', 'Unprincipled Controller', ...
        'SP Controller'});
    
    grid on;
    if isequal(cfg.type, 'oso')
        ylabel(['Cost, bill prds train: ' num2str(tsTrainLengths(idx))]);
    else
        ylabel(['PRR, bill prds train: ' num2str(tsTrainLengths(idx))]);
    end
    
    xlabel('Noise-to-signal Ratio');
    
    subplot(length(tsTrainLengths), 2, 2*idx);
    plot((noiseMagnitudes./sglMagnitude)', ...
        [perf_exactNP(idx, :)./perf_exactGodCast(idx, :);...
        perf_exactMC(idx, :)./perf_exactGodCast(idx, :); ...
        perf_exactGodCast(idx, :)./perf_exactGodCast(idx, :);...
        perf_UC(idx, :)./perf_exactGodCast(idx, :); ...
        perf_SP(idx, :)./perf_exactGodCast(idx, :)]','.-');
    
    if isequal(cfg.type, 'oso')
        ylabel('Relative Cost');
    else
        ylabel('Relative PRR');
    end
    xlabel('Noise-to-signal Ratio');
    grid on;
end

% Save the above figure:
print(fig_1, '-dpdf', [cfg.sav.resultsDir filesep ...
    'TestUnprincipledControllerResults.pdf']);

fig_2 = figure();
plot((noiseMagnitudes./sglMagnitude)', estNoiseRatio, '.');
grid on;
refline(1, 0);
xlabel('Target noise-to-signal ratio');
ylabel('Estimated noise-to-signal ratio');

print(fig_2, '-dpdf', [cfg.sav.resultsDir filesep ...
    'Actual_noise_to_signal_ratios.pdf']);


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