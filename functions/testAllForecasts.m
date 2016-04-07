function [ results ] = testAllForecasts(cfg, trainedModels, demandData)

%% INPUTS
% cfg:           Structure of running options
% trainedModels: cellArray of trained model objects
% demandData:    Vector of testing demand data [nIntervals x nInstances]

%% OUTPUTS
% results:      Structure of output/final results


%% Pre-Allocation
peakReductions = cell(cfg.sim.nInstances, 1);
peakPowers = cell(cfg.sim.nInstances, 1);
smallestExitFlag = cell(cfg.sim.nInstances, 1);
meanKWhs = zeros(cfg.sim.nInstances, 1);
lossTestResults = cell(cfg.sim.nInstances, 1);
featureVectorsFF = cell(cfg.sim.nInstances, 1);
featureVectors = cell(cfg.sim.nInstances, 1);

for instance = 1:cfg.sim.nInstances
    peakReductions{instance} = zeros(cfg.sim.nMethods,1);
    peakPowers{instance} = zeros(cfg.sim.nMethods,1);
    smallestExitFlag{instance} = zeros(cfg.sim.nMethods,1);
    lossTestResults{instance} = zeros(cfg.sim.nMethods, 1);
    meanKWhs(instance) = mean(demandData(:, instance));
end


%% Run Models for Performance Testing
testingTic = tic;

% Delete parrallel pool if one already exists
poolobj = gcp('nocreate');
delete(poolobj);

disp('===== Forecast Testing =====')
% parfor instance = 1:cfg.sim.nInstances
for instance = 1:cfg.sim.nInstances

    % Avoid parfor errors:
    battery = [];
    runControl = []; 
    %% Battery properties
    battery.capacity = meanKWhs(instance)*...
        cfg.sim.batteryCapacityRatio*cfg.sim.stepsPerDay;
    
    battery.maximumChargeRate = ...
        cfg.sim.batteryChargingFactor*battery.capacity;
    
    battery.maximumChargeEnergy = battery.maximumChargeRate/...
        cfg.sim.stepsPerHour;
    
    % Separate data into that used for delays, and actual testing
    delayIdxs = 1:cfg.fc.nLags;
    demandDelays = demandData(delayIdxs, instance);
    demandDataTest = demandData((max(delayIdxs)+1):end, instance);
    peakLocalPower = max(demandDataTest);
    
    % Create godCast (perfect foresight) forecasts
    godCast = createGodCast(demandDataTest, cfg.sim.horizon);
    
    % Avoid parfor errors
    forecastUsed = []; exitFlag = [];
    
    %% Test performance of all methods
    for methodType = 1:cfg.sim.nMethods
        
        thisMethodString = cfg.sim.methodList{methodType};
        
        if strcmp(thisMethodString, 'IMFC')
            
            %% Forecast Free Controller
            [ runningPeak, ~, featureVectorsFF{instance}, ~] = ...
                mpcControllerForecastFree(cfg, ...
                trainedModels{instance, methodType}, demandDataTest, ...
                demandDelays, battery);
            
        else
            
            %% Normal forecast-driven or set-point controller
            
            % Check for godCast or naivePeriodic
            runControl.naivePeriodic = strcmp(thisMethodString, 'NPFC');
            runControl.godCast = strcmp(thisMethodString, 'PFFC');           
            runControl.setPoint = strcmp(thisMethodString, 'SP');
            
            % If method is set-point then show it current demand
            if(runControl.setPoint)
                runControl.knowDemandNow = true;
            end
            
            [runningPeak, exitFlag, forecastUsed, ~,...
                featureVectors{instance}] = mpcController(cfg, ...
                trainedModels{instance, methodType}, godCast,...
                demandDataTest, demandDelays, battery, runControl);
        end
        
        lastIdxCommon = length(runningPeak) - mod(length(runningPeak), ...
            cfg.sim.stepsPerDay*cfg.sim.billingPeriodDays);

        idxsCommon = 1:lastIdxCommon;
        
        % Extract simulation results
        peakReductions{instance}(methodType) = ...
            extractSimulationResults(runningPeak(idxsCommon)',...
            demandDataTest(idxsCommon), ...
            cfg.sim.stepsPerDay*cfg.sim.billingPeriodDays);
        
        peakPowers{instance}(methodType) = peakLocalPower;
        
        if isempty(exitFlag)
            smallestExitFlag{instance}(methodType) = 0;
        else
            smallestExitFlag{instance}(methodType) = min(exitFlag);
        end
        
        % Compute the performance of the forecast
        isForecastFree = strcmp(thisMethodString, 'IMFC');
        isSetPoint = strcmp(thisMethodString, 'SP');
        
        if (~isForecastFree && ~isSetPoint)
            lossTestResults{instance}(methodType) = mse(godCast', ...
                forecastUsed);
        end
    end
    
    disp(' ===== Completed Instance: ===== ');
    disp(instance);
    
end

poolobj = gcp('nocreate');
delete(poolobj);

timeTesting = toc(testingTic);
disp('Time for Testing Forecasts:'); disp(timeTesting);


%% Convert to arrays from cellArrays
% Using for loops to avoid the confusion of reshape statements

peakPowersArray = zeros(cfg.sim.nMethods, cfg.sim.nAggregates,...
    length(cfg.sim.nCustomers));

peakReductionsArray = peakPowersArray;
smallestExitFlagArray = peakPowersArray;
lossTestResultsArray = peakPowersArray;
meanKWhsArray = zeros(cfg.sim.nAggregates, length(cfg.sim.nCustomers));

instance = 0;
for nCustIdx = 1:length(cfg.sim.nCustomers)
    for trial = 1:cfg.sim.nAggregates
        
        instance = instance + 1;
        meanKWhsArray(trial, nCustIdx) = meanKWhs(instance);
        
        for iMethod = 1:cfg.sim.nMethods
            
            peakPowersArray(iMethod, trial, nCustIdx) = ...
                peakPowers{instance}(iMethod);
            
            peakReductionsArray(iMethod, trial, nCustIdx) = ...
                peakReductions{instance}(iMethod);
            
            smallestExitFlagArray(iMethod, trial, nCustIdx) = ...
                smallestExitFlag{instance}(iMethod);
            
            lossTestResultsArray(iMethod, trial, nCustIdx) = ...
                lossTestResults{instance}(iMethod);
            
        end
    end
end

%% Formatting
% Collapse Trial Dimension
peakReductionsTrialFlattened = reshape(peakReductionsArray, ...
    [cfg.sim.nMethods, length(cfg.sim.nCustomers)*cfg.sim.nAggregates]);

peakPowersTrialFlattened = reshape(peakPowersArray, ...
    [cfg.sim.nMethods, length(cfg.sim.nCustomers)*cfg.sim.nAggregates]);

%% Put results together in structure for passing out of function
results.peakReductions = peakReductionsArray;
results.peakReductionsTrialFlattened = peakReductionsTrialFlattened;
results.peakPowers = peakPowersArray;
results.peakPowersTrialFlattened = peakPowersTrialFlattened;
results.smallestExitFlag = smallestExitFlagArray;
results.meanKWhs = meanKWhsArray;
results.lossTestResults = lossTestResultsArray;
results.featureVectorsFF = featureVectorsFF;
results.featureVectors = featureVectors;

end
