function [ runningPeak, exitFlag, forecastUsed, responseVecs, featureVecs ] = ...
    mpcController( pars, ...
    godCast, demand, batteryCapacity, maximumChargeRate, demandDelays, ...
    Sim, runControl)

% mpcController: Simulate time series behaviour of MPC controller with
        % given forecast

% Set default MPC values if not given:
runControl = setDefaultValues(runControl, {'MPC', 'default',...
    'forecastModels', 'RF'});
runControl.MPC = setDefaultValues(runControl.MPC,...
    {'SPrecourse', false, 'resetPeakToMean', false,...
    'billingPeriodDays', 1});

% Select forecasting function handle
switch runControl.forecastModels
    
    case 'FFNN'
        forecastHandle = @forecastFfnn;
        
    case 'SARMA'
        forecastHandle = @forecastSarma;
        
    case 'RF'
        forecastHandle = @forecastRandomForest;

    otherwise
        error('Selected runControl.forecastModels not implemented');
end

%% Initializations
stateOfCharge = 0.5*batteryCapacity;
hourNum = Sim.hourNumberTest;
stepsPerHour = Sim.stepsPerHour;
maximumChargeEnergy = maximumChargeRate/stepsPerHour; % kW -> kWh/interval

if runControl.MPC.resetPeakToMean
    peakSoFar = mean(demandDelays);
else
    peakSoFar = 0;
end

daysPassed = 0;
nIdxs = size(godCast, 1); % length(demand);

%% Pre-Allocations
runningPeak = zeros(1, nIdxs);
exitFlag = zeros(1, nIdxs);
forecastUsed = zeros(Sim.k, nIdxs);
if runControl.MPC.SPrecourse
    responseVecs = zeros(2, nIdxs);         % [b0; peakPower]
else
    responseVecs = zeros(1, nIdxs);         % [b0]
end

% featureVector = [demandDelay; stateOfCharges; (demandNow); peakSoFars];
if runControl.MPC.knowDemandNow
    nFeatures = Sim.trainControl.nLags + 3;
else
    nFeatures = Sim.trainControl.nLags + 2;
end
featureVecs = zeros(nFeatures, nIdxs);

%% Run through time series
for idx = 1:nIdxs;
    demandNow = demand(idx);
    hourNow = hourNum(idx);

    if runControl.godCast
        forecast = godCast(idx, :)';
        
    elseif isfield(runControl, 'modelCast') && runControl.modelCast
        forecast = godCast(idx, :)';
               
    elseif runControl.naivePeriodic
        forecast = demandDelays((end-Sim.trainControl.horizon+1):end);
        
    elseif runControl.MPC.setPoint
        forecast = ones(Sim.trainControl.horizon, 1).*demandNow;
        
    else
        % Produce forecast from input net
        forecast = forecastHandle( pars, demandDelays, ...
            runControl.MPC.trainControl);
    end
    
    % DEBUGGING: work out what's going on with godCast:
    if ~isequal(forecast, demand(idx:(idx+Sim.k-1))) && runControl.godCast
        error('FORECAST DOESNT MATCH?');
    end
    
    forecastUsed(:, idx) = forecast;
    
    if runControl.MPC.UPknowFuture
        % featureVectors = [forecasts; stateOfCharges; (demandNows); peakSoFars];
        if runControl.godCast
            if runControl.MPC.knowDemandNow
                featureVecs(:, idx) = ...
                    [forecast; stateOfCharge; demandNow; peakSoFar];
            else
                featureVecs(:, idx) = ...
                    [forecast; stateOfCharge; peakSoFar];
            end                
        end
    else
        % featureVectors = [demandDelays; stateOfCharges; (demandNows); peakSoFars];
        if runControl.godCast
            if runControl.MPC.knowDemandNow
                featureVecs(:, idx) = ...
                    [demandDelays; stateOfCharge; demandNow; peakSoFar];
            else
                featureVecs(:, idx) = ...
                    [demandDelays; stateOfCharge; peakSoFar];
            end
        end
    end
    
    [energyToBattery, exitFlag(idx)] = controllerOptimizer(forecast, ...
        stateOfCharge, demandNow, batteryCapacity, maximumChargeRate, ...
        stepsPerHour, peakSoFar, runControl.MPC);
    
    % ===== DEBUGGING ===== :
%     figure(1);
%     plot([forecast./stepsPerHour, godCast(idx, :)'./stepsPerHour, ...
%         powerToBattery./stepsPerHour, ...
%         cumsum(powerToBattery./stepsPerHour) + stateOfCharge, ...
%         (forecast + powerToBattery)./stepsPerHour]);
%     hline = refline(0, peakSoFar./stepsPerHour); hline.LineWidth = 2;
%     hline.Color = 'k';
%     grid on;
%     legend('Forecast [kWh/interval]', 'GodCast [kWh/interval]', ...
%         'Power to Batt [kWh/interval]', 'SoC [kWh]', ...
%         'Demand from Grid [kWh/interval]');
    % ===== ======

    % Implement set point recourse, if selected
    if runControl.MPC.SPrecourse
        
        % Peak power based on current forecast and decisions
        peakForecastEnergy = max([energyToBattery(:) + forecast(:); peakSoFar]);
        
        % Check if optimal control action combined with actual demand
        % will exceed this peak; rectify charging action if so:
        if (demandNow + energyToBattery(1)) > peakForecastEnergy
            energyToBatteryNow = peakForecastEnergy - demandNow;
        else
            energyToBatteryNow = energyToBattery(1);
        end
        
    else
        energyToBatteryNow = energyToBattery(1);
    end
    
    % Apply control action to plant (subject to rate and state of charnge
    % constraints)
    origValue = energyToBatteryNow;
    
    energyToBatteryNow = max([energyToBatteryNow, ...
        -stateOfCharge, -demandNow, -maximumChargeEnergy]);
    
    energyToBatteryNow = min([energyToBatteryNow, ...
        (batteryCapacity-stateOfCharge), maximumChargeEnergy]);
    
    % Debugging: Only works for godCast case
    if abs(energyToBatteryNow - origValue) > 1e-6 && runControl.godCast
        error(['Simulation constraint active; something wrong with', ...
            'optimization constraint?']);
    end
    
    stateOfCharge = stateOfCharge + energyToBatteryNow;
    
    responseVecs(1, idx) = energyToBatteryNow;
    
    if runControl.MPC.SPrecourse
        responseVecs(2, idx) = peakForecastEnergy;
    end

    % Update current peak power
    % Reset if we are at start of day(and NOT first time-step!)
    if hourNow == 0
        daysPassed = daysPassed + 1;
    end
    
    if daysPassed == runControl.MPC.billingPeriodDays
        daysPassed = 0;
        
        if runControl.MPC.resetPeakToMean
            peakSoFar = mean(demandDelays);
        else
            peakSoFar = 0;
        end
    else
        peakSoFar = max(peakSoFar, demandNow + energyToBatteryNow);
    end
    
    % Compute outputs for saving
    runningPeak(idx) = peakSoFar;
    
    % Shift demandDelays (and add current demand)
    demandDelays = [demandDelays(2:end); demandNow];
end

end
