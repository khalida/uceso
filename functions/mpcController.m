function [ runningPeak, exitFlag, forecastUsed, respVecs, featVecs, ...
    b0_raw ] = mpcController(cfg, trainedModel, godCast, demand, ...
    demandDelays, battery, runControl)

% mpcController: Simulate time series behaviour of MPC controller with a
% given forecast model (or FF controller).

%% INPUTS:
% cfg:          Structure with all the running parameters
% trainedModel: Trained forecast (or FF controller) model
% godCast:      Matrix of perfect foresight forecasts [nIdxs x horizon]
% demand:       Vector of demand values [nIdxs x 1]
% demandDelays: Vector of previous demand  values [nLags x 1]
% battery:      Battery object
% runControl:   Structure with speicific running options

%% OUTPUTS:
% runningPeak:  Vector of peakSoFar values [nIdxs x 1]
% exitFlag:     Vector of status flags (from linear program) [nIdxs x 1]
% forecastUsed: Matrix of forecasts used [horizon x nIdxs]
% respVecs:     Matrix of possible response vectors [nResp x nIdxs]
% featVecs:     Matrix of possible feature vectors [nFeat x nIdxs]
% b0_raw:       Unconstrained charge decisions from model [nIdxs x 1]


%% Initializations
battery.reset();
nIdxs = size(godCast, 1);
daysPassed = 0;

if cfg.opt.resetPeakToMean
    peakSoFar = mean(demandDelays);
else
    peakSoFar = 0;
end

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
h = waitbar(0, 'Running mpcController');

for idx = 1:nIdxs;
    waitbar(idx/nIdxs, h);
    demandNow = demand(idx);
    
    if runControl.godCast
        forecast = godCast(idx, :)';
        
    elseif isfield(runControl, 'modelCast') && runControl.modelCast
        forecast = godCast(idx, :)';
        
    elseif runControl.naivePeriodic
        forecast = demandDelays(1:cfg.sim.horizon);
        
    elseif runControl.setPoint
        forecast = ones(cfg.sim.horizon, 1).*demandNow;
        
    elseif isfield(runControl, 'forecastFree') && runControl.forecastFree
        % No need for a forecast
        forecast = zeros(cfg.sim.horizon, 1);
    else
        % Produce forecast from input model
        
        % Select forecast function handle
        switch cfg.fc.modelType
            case 'FFNN'
                forecastHandle = @forecastFfnn;
                
            case 'RF'
                forecastHandle = @forecastRandomForest;
                
            otherwise
                error('Selected cfg.fc.modelType not implemented');
        end
        
        forecast = forecastHandle(cfg, trainedModel, demandDelays);
    end
    
    % Error-checking:
    if ~isequal(forecast, demand(idx:(idx + cfg.sim.horizon - 1))) && ...
            runControl.godCast
        
        error('godCast Forecast doesnt match?');
    end
    
    forecastUsed(:, idx) = forecast;
    
    if cfg.fc.knowFutureFF
        % featVec = [futureDemand; stateOfCharge; (demandNow); peakSoFar];
        if cfg.opt.knowDemandNow
            featVecs(:, idx) = [demand(idx:(idx + cfg.sim.horizon - 1));...
                battery.SoC; demandNow; peakSoFar];
        else
            featVecs(:, idx) = [demand(idx:(idx + cfg.sim.horizon - 1));...
                battery.SoC; peakSoFar];
        end
    else
        % featVec = [demandDelays; stateOfCharge; (demandNow); peakSoFar];
        if cfg.opt.knowDemandNow
            featVecs(:, idx) = [demandDelays; battery.SoC; demandNow;...
                peakSoFar];
        else
            featVecs(:, idx) = [demandDelays; battery.SoC; peakSoFar];
        end
    end
    
    cfg.opt.setPoint = runControl.setPoint;
    
    if isfield(runControl, 'forecastFree') && runControl.forecastFree
        %% FORECAST FREE CONTROLLER:
        [energyToBatteryNow, peakForecastEnergy, b0_raw] = ...
            forecastFreeControl(cfg, featVecs(:, idx), battery, ...
            trainedModel, peakSoFar);
        
        exitFlag(idx) = 1;
        
        energyToBattery = ones(cfg.sim.horizon, 1).*energyToBatteryNow;
    else
        %% STD. FORECAST-BASED OR SP CONTROLLER:
        [energyToBattery, exitFlag(idx)] = controllerOptimizer(cfg, ...
            forecast, demandNow, battery, peakSoFar);
        
        peakForecastEnergy = max([energyToBattery(:) + forecast(:); ...
            peakSoFar]);
        
        energyToBatteryNow = energyToBattery(1);
        b0_raw = energyToBatteryNow;
    end
    
    
    % Implement set point recourse, if selected
    if cfg.opt.setPointRecourse
        
        % Check if opt action combined with actual demand exceeds expected
        % peak, & rectify if so:
        if (demandNow + energyToBatteryNow) > peakForecastEnergy
            energyToBatteryNow = peakForecastEnergy - demandNow;
        end
        
        % SP recourse has been applied; need to re-apply battery
        % constraints
        energyToBatteryNow = battery.limitCharge(energyToBatteryNow);
    end
    
    %% Plot first horizon to assis with debugging
    if ~cfg.opt.suppressOutput && idx == 1
        figure();
        plot([forecast, godCast(idx, :)', ...
            cumsum(energyToBattery(:)) + battery.SoC, ...
            energyToBattery(:), forecast + energyToBattery(:)]);
        
        hline = refline(0, peakSoFar); hline.LineWidth = 2;
        hline.Color = 'k';
        grid on;
        legend('Forecast [kWh/interval]', 'GodCast [kWh/interval]', ...
            'SoC [kWh]', 'Energy to Batt [kWh/interval]', ...
            'Expected Demand from Grid [kWh/interval]');
    end
    
    
    %% Apply control action to plant
    % (subject to rate and state of charnge constraints)
    battery.chargeBy(energyToBatteryNow);
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
delete(h);

end
