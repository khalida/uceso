function [ runningPeak, exitFlag, forecastUsed, respVecs, featVecs ] = ...
    mpcController(cfg, trainedModel, godCast, demand, demandDelays, ...
    battery, runControl)

% mpcController: Simulate time series behaviour of MPC controller with a
% given forecast model

%% INPUTS:
% cfg:          Structure with all the running parameters
% trainedModel: Trained forecast model
% godCast:      Matrix of perfect foresight forecasts [nIdxs x horizon]
% demand:       Vector of demand values [nIdxs x 1]
% demandDelays: Vector of previous demand  values [nLags x 1]
% battery:      Structure of battery properties
% runControl:   Structure with speicific running options

%% OUTPUTS:
% runningPeak:  Vector of peakSoFar values [nIdxs x 1]
% exitFlag:     Vector of status flags (from linear program) [nIdxs x 1]
% forecastUsed: Matrix of forecasts used [horizon x nIdxs]
% respVecs:     Matrix of possible response vectors [nResp x nIdxs]
% featVecs:     Matrix of possible feature vectors [nFeat x nIdxs]

% Select forecast function handle
switch cfg.fc.modelType
    
    case 'FFNN'
        forecastHandle = @forecastFfnn;
        
    case 'RF'
        forecastHandle = @forecastRandomForest;
        
    otherwise
        error('Selected cfg.fc.modelType not implemented');
end


%% Initializations
stateOfCharge = 0.5*battery.capacity;

if cfg.opt.resetPeakToMean
    peakSoFar = mean(demandDelays);
else
    peakSoFar = 0;
end

daysPassed = 0;
nIdxs = size(godCast, 1);


%% Pre-Allocations
runningPeak = zeros(nIdxs, 1);
exitFlag = zeros(nIdxs, 1);
forecastUsed = zeros(cfg.sim.horizon, nIdxs);
if cfg.opt.setPointRecourse
    respVecs = zeros(2, nIdxs);         % [b0; peakPower]
else
    respVecs = zeros(1, nIdxs);         % [b0]
end

% featVec = [demandDelay; stateOfCharge; (demandNow); peakSoFar];
if cfg.opt.knowDemandNow
    nFeatures = cfg.fc.nLags + 3;
else
    nFeatures = cfg.fc.nLags + 2;
end
featVecs = zeros(nFeatures, nIdxs);


%% Run through time series
for idx = 1:nIdxs;
    demandNow = demand(idx);
    
    if runControl.godCast
        forecast = godCast(idx, :)';
        
    elseif isfield(runControl, 'modelCast') && runControl.modelCast
        forecast = godCast(idx, :)';
        
    elseif runControl.naivePeriodic
        forecast = demandDelays((end - cfg.sim.horizon + 1):end);
        
    elseif runControl.setPoint
        forecast = ones(cfg.sim.horizon, 1).*demandNow;
        
    else
        % Produce forecast from input model
        forecast = forecastHandle(cfg, trainedModel, demandDelays);
    end
    
    % Error-checking:
    if ~isequal(forecast, demand(idx:(idx + cfg.sim.horizon - 1))) && ...
            runControl.godCast
        
        error('godCast Forecast doesnt match?');
    end
    
    forecastUsed(:, idx) = forecast;
    
    if cfg.fc.knowFutureFF
        % featVec = [forecasts; stateOfCharge; (demandNow); peakSoFar];
        if runControl.godCast
            if cfg.opt.knowDemandNow
                featVecs(:, idx) = ...
                    [forecast; stateOfCharge; demandNow; peakSoFar];
            else
                featVecs(:, idx) = ...
                    [forecast; stateOfCharge; peakSoFar];
            end
        end
    else
        % featVec = [demandDelays; stateOfCharge; (demandNows); peakSoFar];
        if runControl.godCast
            if cfg.opt.knowDemandNow
                featVecs(:, idx) = ...
                    [demandDelays; stateOfCharge; demandNow; peakSoFar];
            else
                featVecs(:, idx) = ...
                    [demandDelays; stateOfCharge; peakSoFar];
            end
        end
    end
    
    cfg.opt.setPoint = runControl.setPoint;
    
    [energyToBattery, exitFlag(idx)] = controllerOptimizer(cfg, ...
        forecast, stateOfCharge, demandNow, battery, peakSoFar);
    
    if ~cfg.opt.suppressOutput && idx == 1
        figure();
        plot([forecast, godCast(idx, :)', ...
            cumsum(energyToBattery(:)) + stateOfCharge, ...
            energyToBattery(:), forecast + energyToBattery(:)]);
        
        hline = refline(0, peakSoFar); hline.LineWidth = 2;
        hline.Color = 'k';
        grid on;
        legend('Forecast [kWh/interval]', 'GodCast [kWh/interval]', ...
            'SoC [kWh]', 'Energy to Batt [kWh/interval]', ...
            'Expected Demand from Grid [kWh/interval]');
    end
    
    % Implement set point recourse, if selected
    if cfg.opt.setPointRecourse
        
        % Peak power based on current forecast and decisions
        peakForecastEnergy = max([energyToBattery(:) + forecast(:); peakSoFar]);
        
        % Check if opt action combined with actual demand exceeds thi;
        % rectify charging action if so:
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
    
    energyToBatteryNow = max([energyToBatteryNow, -stateOfCharge,...
        -demandNow, -battery.maximumChargeEnergy]);
    
    energyToBatteryNow = min([energyToBatteryNow, ...
        (battery.capacity - stateOfCharge), battery.maximumChargeEnergy]);
    
    % Error-checking for godCast case
    if abs(energyToBatteryNow - origValue) > 1e-6 && runControl.godCast
        error(['Simulation constraint active; something wrong with', ...
            'optimization constraint?']);
    end
    
    stateOfCharge = stateOfCharge + energyToBatteryNow;
    
    respVecs(1, idx) = energyToBatteryNow;
    
    if cfg.opt.setPointRecourse
        respVecs(2, idx) = peakForecastEnergy;
    end
    
    % Update current peak power, reset if we are at start of billing prd
    if mod(idx, cfg.sim.stepsPerDay) == 0
        daysPassed = daysPassed + 1;
    end
    
    if daysPassed == cfg.sim.billingPeriodDays
        daysPassed = 0;
        
        if cfg.opt.resetPeakToMean
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
