function [ featureVectors, decisionVectors ] = ...
    mpcGenerateForecastFreeExamples(demandGodCast, demand, ...
    batteryCapacity, maximumChargeRate, demandDelays, Sim, MPC)

% mpcGenerateForecastFreeExamples: Simulate time series behaviour of MPC
% controller with godCast input to generate forecast-free training
% examples.

%% Initializations
stateOfCharge = 0.5*batteryCapacity;
nIdxs = size(demandGodCast, 1);
hourNum = Sim.hourNumberTrainOnly;
stepsPerHour = Sim.stepsPerHour;
maximumChargeEnergy = maximumChargeRate/stepsPerHour; % kW -> kWh/interval

% Set default values of MPC structure
MPC = setDefaultValues(MPC, {'SPrecourse', true, ...
    'resetPeakToMean', false, 'knowDemandNow', false, ...
    'billingPeriodDays', 7});

if MPC.resetPeakToMean
    peakSoFar = mean(demandDelays);
else
    peakSoFar = 0;
end

daysPassed = 0;

%% Pre-Allocations
% featureVectors = [nLags previous demands; stateOfCharges; (demandNows); peakSoFars];
if MPC.knowDemandNow
    featureVectors = zeros(Sim.trainControl.nLags + 3, nIdxs);
else
    featureVectors = zeros(Sim.trainControl.nLags + 2, nIdxs);
end

% Response <next step charging power, (peakForecastPower)>
if MPC.SPrecourse
    decisionVectors = zeros(2, nIdxs);
else
    decisionVectors = zeros(1, nIdxs);
end


%% Run through time series
for idx = 1:nIdxs
    demandNow = demand(idx);
    hourNow = hourNum(idx);
    
    % Use godCast as we want on-line controller to be as effective
    % as possible
    forecast = demandGodCast(idx, :)';
    
    % And we're not using setPoint:
    MPC.setPoint = false;
    
    % Find optimal battery charging actions
    [energyToBattery, ~] = controllerOptimizer(forecast, stateOfCharge, ...
        demandNow, batteryCapacity, maximumChargeRate, stepsPerHour, ...
        peakSoFar, MPC);
    
    % Save feature and response vectors:
    % featureVectors = [nLags previous demands; stateOfCharges; (demandNows); peakSoFars];
    if MPC.knowDemandNow
        featureVectors(:, idx) = [demandDelays; stateOfCharge; ...
            demandNow; peakSoFar];
    else
        featureVectors(:, idx) = [demandDelays; stateOfCharge; peakSoFar];
    end
    
    % Save data for set-point recourse if required
    if MPC.SPrecourse
        % Peak power over horizon if forecasts correct and actions taken
        peakForecastPower = max([energyToBattery(:) + forecast(:); peakSoFar]);
        decisionVectors(2, idx) = peakForecastPower;
    end
    
    energyToBatteryNow = energyToBattery(1);
    decisionVectors(1, idx) =  energyToBatteryNow;
    
    % Apply control action to plant, subject to rate and state of charge
    % constraints
    energyToBatteryNow = max([energyToBatteryNow, -stateOfCharge, ...
        -demandNow, -maximumChargeEnergy]);
    
    energyToBatteryNow = min([energyToBatteryNow, ...
        (batteryCapacity-stateOfCharge), maximumChargeEnergy]);
    
    stateOfCharge = stateOfCharge + energyToBatteryNow;
    
    % Update current peak energy
    % Reset if we are at start of day (and NOT first interval)
    if hourNow == 0
        daysPassed = daysPassed + 1;
    end
    
    if daysPassed == MPC.billingPeriodDays
        daysPassed = 0;
        
        if MPC.resetPeakToMean
            peakSoFar = mean(demandDelays);
        else
            peakSoFar = 0;
        end
    else
        peakSoFar = max(peakSoFar, demandNow + energyToBatteryNow);
    end
    
    % Shift demand delays and add current demand
    demandDelays = [demandDelays(2:end); demandNow];
end

end
