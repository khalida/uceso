function [ runningPeak ] = mpcControllerForecastFree( model, demand, ...
    batteryCapacity, maximumChargeRate, demandDelays, MPC, Sim)

% mpcControllerForecastFree: Time series simulation of a forecast free
% controller

%% Initialisations
stateOfCharge = 0.5*batteryCapacity;
nIdxs = length(demand);
hourNum = Sim.hourNumberTest;
stepsPerHour = Sim.stepsPerHour;
maximumChargeEnergy = maximumChargeRate/stepsPerHour; % kW -> kWh/interval

%% Pre-Allocations
runningPeak = zeros(1, nIdxs);

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

%% Run through time series
for idx = 1:(nIdxs-MPC.horizon+1)
    demandNow = demand(idx);
    hourNow = hourNum(idx);
    
    if MPC.knowDemandNow
        featureVector = [demandDelays; demandNow; stateOfCharge;...
            peakSoFar; hourNow];
    else
        featureVector = [demandDelays; stateOfCharge; peakSoFar; hourNow];
    end
    
    if MPC.knowFuture
        featureVector = [demand(idx:(idx+MPC.horizon-1)); stateOfCharge;...
            demandNow; peakSoFar];
    end
    
    switch Sim.forecastModels
        
        case 'RF'
            % Make forecasts using decision vector random forest model
            decisionVector = model.decisionModel.predict(featureVector');
            
            % Apply set point recourse if selected
            if MPC.SPrecourse
                peakPower = model.decisionModel.predict(featureVector');
                
                energyToBatteryNow = decisionVector(1);
                peakForecastEnergy = max([peakPower; peakSoFar]);
                
                if (demandNow + energyToBatteryNow) > peakForecastEnergy
                    energyToBatteryNow = peakForecastEnergy - demandNow;
                end
            else
                energyToBatteryNow = decisionVector(1);
            end
            
        case 'FFNN'
            forecastFreeControllerOutput = model( featureVector );
            
            % Apply set point recourse if selected
            if MPC.SPrecourse
                energyToBatteryNow = forecastFreeControllerOutput(1);
                peakForecastEnergy = ...
                    max([forecastFreeControllerOutput(2); peakSoFar]);
                
                if (demandNow + energyToBatteryNow) > peakForecastEnergy
                    energyToBatteryNow = peakForecastEnergy - demandNow;
                end
            else
                energyToBatteryNow = forecastFreeControllerOutput;
            end
            
        otherwise
            error('Model not yet implemented');
            
    end
    
    % Apply control decision, subject to rate and state of charge
    % constriants
    energyToBatteryNow = max([energyToBatteryNow, ...
        -stateOfCharge, -demandNow, -maximumChargeEnergy]);
    
    energyToBatteryNow = min([energyToBatteryNow,...
        (batteryCapacity-stateOfCharge), maximumChargeEnergy]);
    
    stateOfCharge = stateOfCharge + energyToBatteryNow;
    
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
