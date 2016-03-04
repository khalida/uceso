function [ Sim, results ] = testAllForecasts( pars, allDemandValues, ...
    Sim, MPC)

%% Pre-Allocation
Sim.testIdxs = (1:(Sim.stepsPerHour*Sim.nHoursTest)) + ...
    Sim.trainIdxs(end);

Sim.hourNumberTest = Sim.hourNumber(Sim.testIdxs, :);

peakReductions = cell(Sim.nInstances, 1);
peakPowers = cell(Sim.nInstances, 1);
smallestExitFlag = cell(Sim.nInstances, 1);
allKWhs = zeros(Sim.nInstances, 1);
lossTestResults = cell(Sim.nInstances, 1);

for instance = 1:Sim.nInstances
    peakReductions{instance} = zeros(Sim.nMethods,1);
    peakPowers{instance} = zeros(Sim.nMethods,1);
    smallestExitFlag{instance} = zeros(Sim.nMethods,1);
    lossTestResults{instance} = zeros(Sim.nMethods, 1);
    allKWhs(instance) = mean(allDemandValues{instance});
end

Sim = setDefaultValues(Sim, {'forecastModels', 'FFNN'});


%% Run Models for Performance Testing
% Extract data from Sim struct for efficiency in parfor communication
nMethods = Sim.nMethods;
methodList = Sim.methodList;
hourNumberTest = Sim.hourNumberTest;
stepsPerHour = Sim.stepsPerHour;
stepsPerDay = Sim.stepsPerDay;
trainIdxs = Sim.trainIdxs;
testIdxs = Sim.testIdxs;
nInstances = Sim.nInstances;
batteryCapacityRatio = Sim.batteryCapacityRatio;
batteryChargingFactor = Sim.batteryChargingFactor;
forecastModels = Sim.forecastModels;
k = Sim.k;

testingTic = tic;

poolobj = gcp('nocreate');
delete(poolobj);

disp('===== Forecast Testing =====')

parfor instance = 1:nInstances
    
    %% Battery properties
    batteryCapacity = allKWhs(instance)*batteryCapacityRatio*stepsPerDay;
    maximumChargeRate = batteryChargingFactor*batteryCapacity;
    
    % Separate data for parameter selection and testing
    demandValuesTrain = allDemandValues{instance}(trainIdxs);
    demandValuesTest = allDemandValues{instance}(testIdxs);
    peakLocalPower = max(demandValuesTest);
    
    % Create 'historical load pattern' used for initialization etc.
    demandDelays = demandValuesTrain(end-k+1:end);
    
    % Create godCast forecasts
    godCastValues = createGodCast(demandValuesTest, k);
    
    % Avoid parfor errors
    forecastUsed = []; exitFlag = [];
    
    %% Test performance of all methods
    for methodType = 1:nMethods
        
        runControl = [];
        runControl.MPC = MPC;
        runControl.forecastModels = forecastModels;
        thisMethodString = methodList{methodType}; %#ok<PFBNS>
        
        if strcmp(thisMethodString, 'IMFC')
            
            %% Forecast Free Controller
            [ runningPeak ] = mpcControllerForecastFree( ...
                pars{instance, methodType}, demandValuesTest,...
                batteryCapacity, maximumChargeRate, demandDelays,...
                MPC, Sim);
        else
            
            %% Normal forecast-driven or set-point controller
            
            % Check for godCast or naivePeriodic
            runControl.naivePeriodic = strcmp(thisMethodString,...
                'NPFC');
            
            runControl.godCast = strcmp(thisMethodString, 'PFFC');
            
            runControl.MPC.setPoint = strcmp(thisMethodString, 'SP');
            
            % If method is set-point then show it current demand
            if(runControl.MPC.setPoint)
                runControl.MPC.knowDemandNow = true;
            end
            
            [runningPeak, exitFlag, forecastUsed] = mpcController( ...
                pars{instance, methodType}, godCastValues,...
                demandValuesTest, batteryCapacity, maximumChargeRate, ...
                demandDelays, Sim, runControl);
        end
        
        % Extract simulation results
        peakReductions{instance}(methodType) = ...
            extractSimulationResults(runningPeak',...
            demandValuesTest, k*MPC.billingPeriodDays);
        
        peakPowers{instance}(methodType) = peakLocalPower;
        if isempty(exitFlag)
            smallestExitFlag{instance}(methodType) = 0;
        else
            smallestExitFlag{instance}(methodType) = min(exitFlag);
        end
        
        % Compute the performance of the forecast
        isForecastFree = strcmp(thisMethodString, 'forecastFree');
        isSetPoint = strcmp(thisMethodString, 'SP');
        
        if (~isForecastFree && ~isSetPoint)
            lossTestResults{instance}(methodType) = mse(godCastValues', ...
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

peakPowersArray = zeros(nMethods, Sim.nAggregates, length(Sim.nCustomers));
peakReductionsArray = peakPowersArray;
smallestExitFlagArray = peakPowersArray;
allKWhsArray = zeros(Sim.nAggregates, length(Sim.nCustomers));
lossTestResultsArray = zeros([nMethods, Sim.nAggregates, ...
    length(Sim.nCustomers)]);

instance = 0;
for nCustomerIdx = 1:length(Sim.nCustomers)
    for trial = 1:Sim.nAggregates
        
        instance = instance + 1;
        allKWhsArray(trial, nCustomerIdx) = allKWhs(instance, 1);
        
        for iMethod = 1:nMethods
            
            peakPowersArray(iMethod, trial, nCustomerIdx) = ...
                peakPowers{instance}(iMethod, 1);
            
            peakReductionsArray(iMethod, trial, nCustomerIdx) = ...
                peakReductions{instance}(iMethod, 1);
            
            smallestExitFlagArray(iMethod, trial, nCustomerIdx) = ...
                smallestExitFlag{instance}(iMethod, 1);
            
            lossTestResultsArray(iMethod, trial, nCustomerIdx) = ...
                lossTestResults{instance}(iMethod);
            
        end
    end
end

%% Fromatting
% Collapse Trial Dimension
peakReductionsTrialFlattened = reshape(peakReductionsArray, ...
    [nMethods, length(Sim.nCustomers)*Sim.nAggregates]);

peakPowersTrialFlattened = reshape(peakPowersArray, ...
    [nMethods, length(Sim.nCustomers)*Sim.nAggregates]);

%% Put results together in structure for passing out
results.peakReductions = peakReductionsArray;
results.peakReductionsTrialFlattened = peakReductionsTrialFlattened;
results.peakPowers = peakPowersArray;
results.peakPowersTrialFlattened = peakPowersTrialFlattened;
results.smallestExitFlag = smallestExitFlagArray;
results.allKWhs = allKWhsArray;
results.lossTestResults = lossTestResultsArray;

end
