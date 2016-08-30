%% Script to test the performance of a Forecast-free Controller, when
% Trained using output from an exact controller (in our application)

%% minMaxDemand controller has been implemented in mpcController:
%[ runningPeak, exitFlag, forecastUsed, respVecs, featVecs, ...
%    b0_raw ] = mpcController(cfg, trainedModel, godCast, demand, ...
%    demandDelays, battery, runControl)

% And it requires the following INPUTS:
% cfg:              Structure of running options
% trainedModel:     Trained forecast (or integrated controller) model
% godCast:          Matrix of perfect foresight forecasts
% demand:           Demand time series on which to run model [kWh]
% demandDelays:     Initial nLag lags of demand [kWh]
% battery:          Object containing information about the battery
% runControl:       Running options specific to that case/method


%% oso controller implemented in controllerDp.m
% [ totalCost, chargeProfile, totalDamageCost, demForecastUsed,...
%    pvForecastUsed, respVecs, featVecs, bestCTG, imp, exp] = ...
%    mpcControllerDp(cfg, trainedModel, demGodCast, demand, pvGodCast, ...
%    pv, demandDelays, pvDelays, battery, runControl)

% And it requires the following INPUTS:
% cfg:              Structure of running options
% trainedModel:     Trained forecast (or unprincipled controller) model
% dem|pv|godCast:   Demand and PV perfect foresight forecast [kWh]
% demand|pv:        Demand and PV time series on which to run mdoel [kWh]
% demand|pv|Delays: Initial nLag lags of demand and pv [kWh]
% battery:          Object representing the battery
% runControl:       Running options specific to that case/method


%% 0) Tidy up & Load functions
clearvars; close all; clc;
rng(42);
tic;
LoadFunctions;
plotEachTrainLength = true;  %#ok<*UNRCH>


%% 1) Running Options
% Load from Config():
cfg = Config(pwd);


%% Recompile mexes if required:
if strcmp(cfg.type, 'oso')
    RecompileMexes;
end


%% Declare properties of artificial demand / pv signal
sglMagnitude = 5/cfg.sim.stepsPerHour;  % peak of 5kWh/hour
noiseMagnitudes = sglMagnitude.*[0.25 1.0];        % noise levels to run
tsTrainLengths = [10 20];              % weeks of training data
tsTestLength = 10*cfg.sim.horizon*cfg.sim.billingPeriodDays;


%% Initialize results vectors
% NB: performance is Peak reduction ratio for minMaxDemand (high good), for
% oso it is the totalCost (low good)
perf_FF = zeros(length(tsTrainLengths), length(noiseMagnitudes));
perf_exactNP = perf_FF;
perf_exactMC = perf_FF;
perf_SP = perf_FF;
perf_exactGodCast = perf_FF;

estNoiseRatio = zeros(length(tsTrainLengths), length(noiseMagnitudes));

for tsTrIdx = 1:length(tsTrainLengths)
    
    tsTrainLength = tsTrainLengths(tsTrIdx)*cfg.sim.horizon*...
        cfg.sim.billingPeriodDays;
    
    parfor noiseIdx = 1:length(noiseMagnitudes)
    % for noiseIdx = 1:length(noiseMagnitudes)
        noiseMagnitude = noiseMagnitudes(noiseIdx);
        
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
        featVecs = [];
        
               
        %% 2) Create artificial data
        disp(' === Creating Data === ');
        timeSeriesDataDem = noisySine(sglMagnitude/2, ...
            cfg.fc.seasonalPeriod, noiseMagnitude, ...
            tsTrainLength + tsTestLength); %#ok<*PFBNS>
        
        timeSeriesDataDem = max(0, timeSeriesDataDem);
        
        timeSeriesDataDem = timeSeriesDataDem + 2.*circshift(...
            timeSeriesDataDem, [floor(cfg.fc.seasonalPeriod/2),0]);
        
        avgLoad = mean(timeSeriesDataDem);
        
        % And PV data if we're looking at OSO:
        if isequal(cfg.type, 'oso')
            timeSeriesDataPv = noisySine(sglMagnitude, ...
                cfg.fc.seasonalPeriod, noiseMagnitude, ...
                tsTrainLength + tsTestLength); %#ok<*PFBNS>
            
            timeSeriesDataPv = max(0, timeSeriesDataPv);
            
            timeSeriesDataPv = circshift(timeSeriesDataPv, ...
                [floor(cfg.fc.seasonalPeriod/4), 0]);
            
            % Declare battery properties (oso)
            if ~isfield(cfg.sim, 'batteryCapacityTotal');
                battery = Battery(getCfgForController(cfg),...
                    cfg.sim.batteryCapacityPerCustomer);
            else
                battery = Battery(getCfgForController(cfg),...
                    cfg.sim.batteryCapacityTotal);
            end
            
        elseif isequal(cfg.type, 'minMaxDemand')
            % Declare battery properties (minMaxDemand)
            battery = Battery(getCfgForController(cfg),...
                avgLoad*cfg.sim.batteryCapacityRatio*...
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
        
        noiseFreeTsDem = noisySine(sglMagnitude/2, ...
            cfg.fc.seasonalPeriod, 0, tsTrainLength + tsTestLength);
        
        noiseFreeTsDem = max(0, noiseFreeTsDem);
        
        noiseFreeTsDem = noiseFreeTsDem + 2.*circshift(...
            noiseFreeTsDem, [floor(cfg.fc.seasonalPeriod/2),0]);
        
        noiseFreeTsTestDem = noiseFreeTsDem((end - (tsTestLength-1)):end);
        
        if isequal(cfg.type, 'oso')
            noiseFreeTsPv = noisySine(sglMagnitude,...
                cfg.fc.seasonalPeriod, 0, tsTrainLength + tsTestLength);
            
            noiseFreeTsPv = max(0, noiseFreeTsPv);
            
            noiseFreeTsPv = circshift(noiseFreeTsPv, ...
                [floor(cfg.fc.seasonalPeriod/4), 0]);
            
            noiseFreeTsTestPv = noiseFreeTsPv((end - (tsTestLength-1)):...
                end);
        end
        
        % Separate off data for initialization:
        demandDelays = trainDemandSeries(1:cfg.fc.nLags);
        trainDemandData = trainDemandSeries((cfg.fc.nLags + 1):end);
        
        if isequal(cfg.type, 'oso')
            % Separate off pv data for initialization:
            pvDelays = trainPvSeries(1:cfg.fc.nLags);
            trainPvData = trainPvSeries((cfg.fc.nLags + 1):end);
        end
        
        %% 3) Run exact controller on training data, with godCast
        % to get training data for FF controller:
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
        
        % How often to randomise storage SoC; train in robustness
        runControl.randomizeInterval = cfg.fc.randomizeInterval;
        
        if isequal(cfg.type, 'oso')
            
            [ ~, ~, ~, ~, ~, responseGc, featureVectorGc, bestCTG, imp,...
                exp] = mpcControllerDp(cfg, [], godCastTrainDem,...
                trainDemandData, godCastTrainPv, trainPvData,...
                demandDelays, pvDelays, battery, runControl);
            
            % featVec = [nLag prev dem, (demandNow), nLag prev pv, ...
            % (pvNow), SoC, hourNum]
            
            % but if config.fc.knowFutureFF, then we provide future PV and
            % demand as inputs!
        else
            [ ~, ~, ~, responseGc, featureVectorGc, ~] = mpcController(...
                cfg, [], godCastTrainDem, trainDemandData, demandDelays,...
                battery, runControl);
            
            % featVec = [demandDelay; stateOfCharge; (demandNow); ...
            % peakSoFar];
            
            % but if config.fc.knowFutureFF, then we provide future PV and
            % demand as inputs!
        end
        
        runControl = rmfield(runControl, 'randomizeInterval');
        
        %% 4a) Divide data into training/testing and train FF
        nObsTrain = size(featureVectorGc, 2);
        randIdxs = 1:nObsTrain; % randIdxs = randperm(nObsTrain);
        trainIdxs = randIdxs(1:ceil(nObsTrain*cfg.fc.trainRatio));
        testIdxs = randIdxs((length(trainIdxs)+1):nObsTrain);
        
        featVecsTrain = featureVectorGc(:, trainIdxs);
        respVecsTrain = responseGc(:, trainIdxs);
        
        featVecsVal = featureVectorGc(:, testIdxs);
        respVecsVal = responseGc(:, testIdxs);
        
        
        %% 4b) Train FF controller
        disp('=== Train FF controller ===');
        ffController = trainFfnnMultiInit(cfg, featVecsTrain,...
            respVecsTrain);
        
        
        %% 4c) Performance on validation data
        % (this just tests how well an input/output mapping replicates the
        % optimiser, nothing to do with if controller works!)
        if plotEachTrainLength
            figure();
            estimatedRespVecsVal = forecastFfnn(cfg, ffController, ...
                featVecsVal);
            
            scatter(respVecsVal, estimatedRespVecsVal);
            
            hold on; grid on;
            hline = refline(1,0); hline.Color='r'; hline.LineWidth=1.5;
            
            saveas(gcf, [cfg.sav.resultsDir filesep 'reg_nseIdx'...
                num2str(noiseIdx) 'tsIdx' num2str(tsTrIdx) '.fig']);
            
            xlabel({['Train Length=' num2str(tsTrainLength)],...
                'Control Response'});
            
            ylabel({['Noise:Signal=' num2str(noiseMagnitude)],...
                'NN Response'});
        end
        
        
        %% 5) Simulate t-series behaviour of various controllers
        % on test data, NB: this uses simulated/fake data so YMMV!
        
        
        %% 5a) Exact controller with godCast
        runControl.godCast = true;
        runControl.naivePeriodic = false;
        runControl.setPoint = false;
        runControl.modelCast = false;
        runControl.forecastFree = false;
        runControl.NB = false;
        runControl.randomizeInterval = 9e9;     % Don't randomize state
        
        % Separate off data for initialization:
        demandDelays = testDemandSeries(1:cfg.fc.nLags);
        testDemandData = testDemandSeries((cfg.fc.nLags + 1):end);
        godCastTestDem = createGodCast(testDemandData, cfg.sim.horizon);
        
        disp('=== SIM: Exact controller, godCast ===');
        if isequal(cfg.type, 'oso')
            nStates = length(battery.statesInt);
            
            % Run OSO model
            pvDelays = testPvSeries(1:cfg.fc.nLags);
            testPvData = testPvSeries((cfg.fc.nLags + 1):end);
            godCastTestPv = createGodCast(testPvData, cfg.sim.horizon);
            
            [ totalCost, ~, totalDamageCost, ~, ~,...
                respGcTest, featVectorGcTest, ~, imp, exp] = ...
                mpcControllerDp(cfg, [], godCastTestDem, testDemandData,...
                godCastTestPv, testPvData, demandDelays, pvDelays,...
                battery, runControl);
            
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
        runControl.randomizeInterval = 9e9;
        
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
        runControl.randomizeInterval = 9e9;
        
        disp('=== SIM: Exact controller, NP ===');
        if isequal(cfg.type, 'oso')
            % Run OSO model
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
        
        
        %% 5d) Forecast-Free controller
        runControl.godCast = false;
        runControl.naivePeriodic = false;
        runControl.setPoint = false;
        runControl.modelCast = false;
        runControl.forecastFree = true;
        runControl.NB = false;
        runControl.randomizeInterval = 9e9;
        
        disp(['=== SIM: FF controller, sees future: ',...
            num2str(cfg.fc.knowFutureFF), ' ===']);
        
        if isequal(cfg.type, 'oso')
            % Run OSO model
            [ totalCost, b0_Ff_raw, totalDamageCost, ~, ~, ...
                respVecUp, featVecUp, ~, imp, exp] = mpcControllerDp(...
                cfg, ffController, godCastTestDem, testDemandData,...
                godCastTestPv, testPvData, demandDelays, pvDelays,...
                battery, runControl);
            
            perf_FF(tsTrIdx, noiseIdx) = totalCost - totalDamageCost;
            
        else
            % Run minMaxDemand model
            [ runningPeak, ~, ~, respVecUp, featVecUp, b0_Ff_raw ] = ...
                mpcController(cfg, ffController, ...
                godCastTestDem, testDemandData, demandDelays, battery, ...
                runControl);
            
            perf_FF(tsTrIdx, noiseIdx) = extractSimulationResults(...
                runningPeak(idxsCommon)', testDemandSeries(idxsCommon), ...
                cfg.sim.horizon*cfg.sim.billingPeriodDays);
        end
        
        
        if plotEachTrainLength
            plotIdx = 4;
            if isequal(cfg.type, 'minMaxDemand')
                ax{plotIdx} = plotMpcTseries(tsFig, plotIdx, ...
                    testDemandSeries(idxsCommon), runningPeak(idxsCommon),...
                    avgLoad, featVecUp(cfg.fc.nLags+1,idxsCommon), battery,...
                    'Fcast-free ctrl', nObsTrain);
                
            else
                ax{plotIdx} = plotDpTseries(tsFig, plotIdx, ...
                    testDemandData, testPvData, ...
                    featVecUp(end-1,:), battery, ...
                    'Fcast-free ctrl', nObsTrain, imp, exp);
            end
        end
        
        %% 5e) Set-Point Controller
        runControl.godCast = false;
        runControl.naivePeriodic = false;
        runControl.setPoint = true;
        runControl.modelCast = false;
        runControl.forecastFree = false;
        runControl.NB = false;
        runControl.randomizeInterval = 9e9;
        
        disp('=== SIM: Set Point Controller ===');
        if isequal(cfg.type, 'oso')
            % Run OSO model
            [ totalCost, ~, totalDamageCost, ~, ~, ~, featVecSp, ~,...
                imp, exp]= mpcControllerDp(cfg, ffController, ...
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
                    'Set Point ctrl', nObsTrain);
                
            else
                ax{plotIdx} = plotDpTseries(tsFig, plotIdx, ...
                    testDemandData, testPvData, ...
                    featVecSp(end-1,:), battery, ...
                    'Set Point ctrl', nObsTrain, imp, exp);
            end
            
            % Link x axes for plotting:
            linkaxes([ax{:}], 'x');
            
            saveas(gcf, [cfg.sav.resultsDir filesep 'tSeries_nseIdx'...
                num2str(noiseIdx) 'tsIdx' num2str(tsTrIdx) '.fig']);
        end
        
        disp(['Completed run with ' num2str(nObsTrain) ' data points']);
        disp(['and ' num2str(ffController.numWeightElements) ...
            ' weighted elements']);
    end
end


%% Plotting results
fig_1 = figure();
for idx = 1:length(tsTrainLengths)
    subplot(length(tsTrainLengths), 2, 2*idx-1);
    plot((noiseMagnitudes./sglMagnitude)', [perf_exactNP(idx, :);...
        perf_exactMC(idx, :); perf_exactGodCast(idx, :);...
        perf_FF(idx, :); perf_SP(idx, :)]', '.-');
    
    legend({'Exact Controller, NP', 'Excat controller, modelCast', ...
        'Exact Controller, God Cast', 'Fcast free Controller', ...
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
        perf_FF(idx, :)./perf_exactGodCast(idx, :); ...
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
    'TestFcastFreeControllerResults.pdf']);


%% Plotting target VS actual noise:signal ratio
fig_2 = figure();
plot((noiseMagnitudes./sglMagnitude)', estNoiseRatio', '.');
grid on;
refline(1, 0);
xlabel('Target noise-to-signal ratio');
ylabel('Estimated noise-to-signal ratio');

print(fig_2, '-dpdf', [cfg.sav.resultsDir filesep ...
    'Actual_noise_to_signal_ratios.pdf']);


%% Combine the individual regression plots into a larger subplot:
allRegressionPlots = figure; % create new figure to paste regressions into
plotGaps = [0.04 0.04];

for noiseIdx = 1:length(noiseMagnitudes)
    noistMagnitude = noiseMagnitudes(noiseIdx);
    
    for tsTrIdx = 1:length(tsTrainLengths)
        tsTrainLength = tsTrainLengths(tsTrIdx);
        
        thisFileName = [cfg.sav.resultsDir filesep 'reg_nseIdx'...
            num2str(noiseIdx) 'tsIdx' num2str(tsTrIdx) '.fig'];
        
        h1 = openfig(thisFileName, 'reuse'); %open existing figure
        ax1 = gca; %get handle to axes of figure
        
        plotIdx = (noiseIdx-1)*length(tsTrainLengths) + tsTrIdx;
        
        figure(allRegressionPlots);
        thisSub = subtightplot(length(noiseMagnitudes), length(tsTrainLengths),...
            plotIdx, plotGaps);
        
        xlabel(['Train Data: ' num2str(tsTrainLength) ' weeks']);
        axis square;
        grid on;
        
        thisFig = get(ax1, 'children'); %get handle to all children in fig
        copyobj(thisFig, thisSub);
        
    end
end

allRegressionPlots.PaperUnits = 'inches';
allRegressionPlots.PaperPosition = [0 0 6 4];

figure(allRegressionPlots);
print(allRegressionPlots, '-dpdf', [cfg.sav.resultsDir filesep ...
    'all_regression_results.pdf']);

% plotAsTixz([cfg.sav.resultsDir filesep 'all_regression_results.tikz']);

%% Save the data:
save([cfg.sav.resultsDir filesep 'TestFcastFreeResults.mat'], '-v7.3');

toc;