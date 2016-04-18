function [ results ] = testAllForecasts(cfg, trainedModels, data)

%% INPUTS
% cfg:           Structure of running options
% trainedModels: cellArray of trained model objects
% demandData:    Vector of testing demand data [nIntervals x nInstances]

%% OUTPUTS
% results:      Structure of output/final results


%% Pre-Allocation
if isequal(cfg.type, 'oso')
    totalCost = cell(cfg.sim.nInstances, 1);
    totalDamageCost = cell(cfg.sim.nInstances, 1);
    storageProfile = cell(cfg.sim.nInstances, 1);
    lossTestResultsDemand = cell(cfg.sim.nInstances, 1);
    lossTestResultsPv = cell(cfg.sim.nInstances, 1);
    allDemFcs = cell(cfg.sim.nInstances, 1);
    allPvFcs = cell(cfg.sim.nInstances, 1);
    
    for instance = 1:cfg.sim.nInstances
        totalCost{instance} = zeros(cfg.sim.nMethods,1);
        totalDamageCost{instance} = zeros(cfg.sim.nMethods,1);
        storageProfile{instance} = zeros(cfg.sim.nMethods, ...
            length(data.demand(:, 1))-cfg.fc.nLags-cfg.sim.horizon+1);
        
        lossTestResultsDemand{instance} = zeros(cfg.sim.nMethods, 1);
        lossTestResultsPv{instance} = zeros(cfg.sim.nMethods, 1);
        allDemFcs{instance} = cell(cfg.sim.nMethods, 1);
        allPvFcs{instance} = cell(cfg.sim.nMethods, 1);
    end
    % Avoid parfor error:
    meanKWhs = zeros(cfg.sim.nInstances, 1);
else
    peakReductions = cell(cfg.sim.nInstances, 1);
    peakPowers = cell(cfg.sim.nInstances, 1);
    smallestExitFlag = cell(cfg.sim.nInstances, 1);
    meanKWhs = zeros(cfg.sim.nInstances, 1);
    lossTestResultsDemand = cell(cfg.sim.nInstances, 1);
    noiseSglRatio = cell(cfg.sim.nInstances, 1);
    featureVectorsFF = cell(cfg.sim.nInstances, 1);
    featureVectors = cell(cfg.sim.nInstances, 1);
    
    for instance = 1:cfg.sim.nInstances
        meanKWhs(instance) = mean(data.demand(:, instance));
        peakReductions{instance} = zeros(cfg.sim.nMethods,1);
        peakPowers{instance} = zeros(cfg.sim.nMethods,1);
        smallestExitFlag{instance} = zeros(cfg.sim.nMethods,1);
        lossTestResultsDemand{instance} = zeros(cfg.sim.nMethods, 1);
        noiseSglRatio{instance} = zeros(cfg.sim.nMethods, 1);
    end
end


%% Run Models for Performance Testing
testingTic = tic;

% Delete parrallel pool if one already exists
poolobj = gcp('nocreate');
delete(poolobj);

disp('===== Forecast Testing =====')
parfor instance = 1:cfg.sim.nInstances
% for instance = 1:cfg.sim.nInstances
    
    % Avoid parfor errors:
    runControl = [];
    runningPeak = [];
    pvDelays = [];
    pvDataTest = [];
    godCastPv = [];
    pvForecastUsed = [];
    peakLocalPower = [];
    exitFlag = [];
        
    %% Battery properties
    if isequal(cfg.type, 'oso') %#ok<*PFBNS>
        battery = Battery(cfg, cfg.sim.batteryCapacity);
    else
        battery = Battery(cfg, meanKWhs(instance)*...
            cfg.sim.batteryCapacityRatio*cfg.sim.stepsPerDay);
    end
    
    % Separate data into that used for delays, and actual testing
    delayIdxs = 1:cfg.fc.nLags;
    demandDelays = data.demand(delayIdxs, instance);
    demandDataTest = data.demand((max(delayIdxs)+1):end, instance);
    % Create godCast (perfect foresight) forecasts
    godCastDem = createGodCast(demandDataTest, cfg.sim.horizon);
    
    % Avoid parfor errors
    demForecastUsed = [];
    
    if isequal(cfg.type, 'oso')
        pvDelays = data.pv(delayIdxs, instance); %#o%#ok<MSNU> k<PFBNS>
        pvDataTest = data.pv((max(delayIdxs)+1):end, instance);
        % Create godCast (perfect foresight) forecasts
        godCastPv = createGodCast(pvDataTest, cfg.sim.horizon);
        % Avoid parfor errors
        pvForecastUsed = [];
    else
        peakLocalPower = max(demandDataTest);
        exitFlag = [];
    end
    
    %% Test performance of all methods
    for methodType = 1:cfg.sim.nMethods
        
        thisMethodString = cfg.sim.methodList{methodType};
        
        if strcmp(thisMethodString, 'IMFC')
            
            runControl.naivePeriodic = false;
            runControl.godCast = false;
            runControl.setPoint = false;
            runControl.forecastFree = true;
            
            %% Forecast Free Controller
            if isequal(cfg.type, 'oso')
                [ totalCost{instance}(methodType,1), ...
                    storageProfile{instance}(methodType,:), ...
                    totalDamageCost{instance}(methodType,1), ...
                    demForecastUsed, pvForecastUsed, ~, ~, ~] = ...
                    mpcControllerDp(cfg, trainedModels{instance, ...
                    methodType}, godCastDem, demandDataTest, godCastPv,...
                    pvDataTest, demandDelays,...
                    pvDelays, battery, runControl);
                
            else
                [ runningPeak, ~, ~, ~, featureVectorsFF{instance}, ~] = ...
                    mpcController(cfg, trainedModels{instance, methodType},...
                    godCastDem, demandDataTest, demandDelays, battery, ...
                    runControl);
            end
            
        else
            %% Normal forecast-driven or set-point controller
            
            % Check for godCast or naivePeriodic
            runControl.naivePeriodic = strcmp(thisMethodString, 'NPFC');
            runControl.godCast = strcmp(thisMethodString, 'PFFC');
            runControl.setPoint = strcmp(thisMethodString, 'SP');
            runControl.forecastFree = false;
            
            % If method is set-point then show it current demand
            if(runControl.setPoint)
                runControl.knowDemandNow = true;
            end
            
            if isequal(cfg.type, 'oso')
                runControl.NB = strcmp(thisMethodString, 'NB');
                [ totalCost{instance}(methodType,1), ...
                    storageProfile{instance}(methodType,:), ...
                    totalDamageCost{instance}(methodType,1), ...
                    demForecastUsed, pvForecastUsed, ~, ~, ~] = ...
                    mpcControllerDp(cfg, trainedModels{instance, ...
                    methodType}, godCastDem, demandDataTest, godCastPv,...
                    pvDataTest, demandDelays,...
                    pvDelays, battery, runControl);
            else
                [runningPeak, exitFlag, demForecastUsed, ~,...
                    featureVectors{instance}, ~] = mpcController(cfg, ...
                    trainedModels{instance, methodType}, godCastDem,...
                    demandDataTest, demandDelays, battery, runControl);
            end
        end
        
        if isequal(cfg.type, 'oso')
            % Extract oso sim results
        else
            % Extract minMaxDemand sim results
            lastIdxCommon = length(runningPeak) - mod(length(runningPeak), ...
                cfg.sim.stepsPerDay*cfg.sim.billingPeriodDays);
            
            idxsCommon = 1:lastIdxCommon;
            
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
        end
        
        % Compute the performance of the forecast
        isForecastFree = strcmp(thisMethodString, 'IMFC');
        isSetPoint = strcmp(thisMethodString, 'SP');
        
        if (~isForecastFree && ~isSetPoint)
            lossTestResultsDemand{instance}(methodType) = mse(godCastDem', ...
                demForecastUsed);
            
            if isequal(cfg.type, 'oso')
                lossTestResultsPv{instance}(methodType) = mse(godCastPv',...
                    pvForecastUsed);
                allDemFcs{instance}{methodType} = demForecastUsed;
                allPvFcs{instance}{methodType} = pvForecastUsed;
            else
                noiseSglRatio{instance}(methodType) = sqrt(mse(godCastDem', ...
                    demForecastUsed))/rms(demForecastUsed(:));
            end
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

if isequal(cfg.type, 'oso')
    %% Data from OSO type solution
    totalCostArray = zeros(cfg.sim.nInstances, cfg.sim.nMethods);
    totalDamageCostArray = zeros(cfg.sim.nInstances, cfg.sim.nMethods);
    demandTestResultsArray = zeros([cfg.sim.nInstances, cfg.sim.nMethods]);
    pvTestResultsArray = zeros([cfg.sim.nInstances, cfg.sim.nMethods]);
    storageProfilesArray = zeros([cfg.sim.nInstances, cfg.sim.nMethods, ...
        length(data.demand(:, 1))-cfg.fc.nLags-cfg.sim.horizon+1]);
    
    for instance = 1:cfg.sim.nInstances
        for iMethod = 1:cfg.sim.nMethods
            
            totalCostArray(instance, iMethod) = ...
                totalCost{instance}(iMethod, 1);
            
            totalDamageCostArray(instance, iMethod) = ...
                totalDamageCost{instance}(iMethod, 1);
            
            demandTestResultsArray(instance, iMethod) = ...
                lossTestResultsDemand{instance}(iMethod);
            
            pvTestResultsArray(instance, iMethod) = ...
                lossTestResultsPv{instance}(iMethod);
            
            storageProfilesArray(instance, iMethod, :) = ...
                storageProfile{instance}(iMethod, :);
        end
    end
    
    %% Put results together in structure for passing out
    results.totalCost = totalCostArray;
    results.totalDamageCost = totalDamageCostArray;
    results.demandTestResults = demandTestResultsArray;
    results.pvTestResults = pvTestResultsArray;
    results.storageProfile = storageProfilesArray;
    results.allDemFcs = allDemFcs;
    results.allPvFcs = allPvFcs;
    
else
    %% Data from minMaxDemand type solution
    peakPowersArray = zeros(cfg.sim.nMethods, cfg.sim.nAggregates,...
        length(cfg.sim.nCustomers));
    
    peakReductionsArray = peakPowersArray;
    smallestExitFlagArray = peakPowersArray;
    lossTestResultsArray = peakPowersArray;
    noiseSglRatioArray = peakPowersArray;
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
                    lossTestResultsDemand{instance}(iMethod);
                
                noiseSglRatioArray(iMethod, trial, nCustIdx) = ...
                    noiseSglRatio{instance}(iMethod);
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
    results.noiseSglRatio = noiseSglRatioArray;
    results.featureVectorsFF = featureVectorsFF;
    results.featureVectors = featureVectors;
end

end
