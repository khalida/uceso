function [ runningPeak, respVecs, featVecs, b0_raw ] = mpcControllerForecastFree( model, demand, ...
    batteryCapacity, maximumChargeRate, demandDelays, MPC, Sim)

% mpcControllerForecastFree: Time series simulation of a forecast free
% controller

%% Initialisations
stateOfCharge = 0.5*batteryCapacity;
nIdxs = length(demand);
hourNum = Sim.hourNumberTest;
stepsPerHour = Sim.stepsPerHour;
maximumChargeEnergy = maximumChargeRate/stepsPerHour; % kW -> kWh/interval

%% Set Default Values:
MPC = setDefaultValues(MPC, {'knowDemandNow', false, ...
    'SPrecourse', false, 'resetPeakToMean', false, ...
    'billingPeriodDays', 1});

if MPC.resetPeakToMean
    peakSoFar = mean(demandDelays);
else
    peakSoFar = 0;
end
daysPassed = 0;
lastIdx = nIdxs-Sim.trainControl.horizon + 1;
if MPC.SPrecourse
    respVecs = zeros(2, lastIdx);           % [b0, peakEst]
else
    respVecs = zeros(1, lastIdx);           % [b0]
end
b0_raw = zeros(1, lastIdx);
% featureVector = [demandDelay; stateOfCharges; (demandNow); peakSoFars];
if MPC.knowDemandNow
    nFeatures = Sim.trainControl.nLags + 3;
else
    nFeatures = Sim.trainControl.nLags + 2;
end
featVecs = zeros(nFeatures, lastIdx);

%% Pre-Allocations
runningPeak = zeros(1, lastIdx);

%% Run through time series
for idx = 1:lastIdx
    demandNow = demand(idx);
    hourNow = hourNum(idx);
    
    if MPC.UPknowFuture
        % featureVectors = [futureDemand; stateOfCharges; demandNows; peakSoFars];
        if MPC.knowDemandNow
            featureVector = [demand(idx:(idx+Sim.trainControl.horizon-1));...
                stateOfCharge; demandNow; peakSoFar];
        else
            featureVector = [demand(idx:(idx+Sim.trainControl.horizon-1));...
                stateOfCharge; peakSoFar];
        end
    else
        % featureVectors = [demandDelays; stateOfCharges; demandNows; peakSoFars];
        if MPC.knowDemandNow
            featureVector = [demandDelays; stateOfCharge; demandNow;...
                peakSoFar];
        else
            featureVector = [demandDelays; stateOfCharge; peakSoFar];
        end
    end
    
    featVecs(:, idx) = featureVector;
    
    switch Sim.forecastModels
        
        case 'RF'
            % Make forecasts using decision vector random forest model
            decisionVector = model.decisionModel.predict(featureVector');
            
            % Apply set point recourse if selected
            if MPC.SPrecourse
                peakPower = model.decisionModel.predict(featureVector');
                
                energyToBatteryNow = decisionVector(1);
                b0_raw(idx) = energyToBatteryNow;
                peakForecastEnergy = max([peakPower; peakSoFar]);
                
                if (demandNow + energyToBatteryNow) > peakForecastEnergy
                    energyToBatteryNow = peakForecastEnergy - demandNow;
                end
            else
                energyToBatteryNow = decisionVector(1);
                b0_raw(idx) = energyToBatteryNow;
            end
            
        case 'FFNN'
            forecastFreeControllerOutput = model( featureVector );
            
            % Apply set point recourse if selected
            if MPC.SPrecourse
                energyToBatteryNow = forecastFreeControllerOutput(1);
                b0_raw(idx) = energyToBatteryNow;
                peakForecastEnergy = ...
                    max([forecastFreeControllerOutput(2); peakSoFar]);
                
                if (demandNow + energyToBatteryNow) > peakForecastEnergy
                    energyToBatteryNow = peakForecastEnergy - demandNow;
                end
            else
                energyToBatteryNow = forecastFreeControllerOutput;
                b0_raw(idx) = energyToBatteryNow;
            end
            
        otherwise
            error('Model not yet implemented');
            
    end
    
    % Apply control decision, subject to rate and state of charge
    % constriants
    % origValue = energyToBatteryNow;
    
    energyToBatteryNow = max([energyToBatteryNow, ...
        -stateOfCharge, -demandNow, -maximumChargeEnergy]);
    
    energyToBatteryNow = min([energyToBatteryNow,...
        (batteryCapacity-stateOfCharge), maximumChargeEnergy]);
    
    stateOfCharge = stateOfCharge + energyToBatteryNow;
    respVecs(1, idx) = energyToBatteryNow;
    
    if MPC.SPrecourse
        respVecs(2, idx) = peakForecastEnergy;
    end
    
    % Update current peak power
    % Reset if we are at start of day (and NOT first interval)
    if hourNow == 1 &&  idx ~= 1
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
    
    % Compute outputs for saving
    runningPeak(idx) = peakSoFar;
    
    % Shift demand delays (and add current demand)
    demandDelays = [demandDelays(2:end); demandNow];
end

end
