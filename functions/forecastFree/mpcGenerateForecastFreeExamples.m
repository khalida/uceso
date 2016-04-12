function [ featVecs, respVecs ] = mpcGenerateForecastFreeExamples(cfg, ...
    demandGodCast, demandData, demandDelays, battery)

% mpcGenerateForecastFreeExamples: Simulate t-series behaviour of MPC
% controller with perfect foresight forecast to generate
% forecast-free training examples.

%% INPUTS:
% cfg:              Structure containing all running options
% demandGodCast:    Matrix of perfect forecasts [nIntervals x horizon]
% demandData:       Vector of demand values over sim [nIntervals x 1]
% demandDelays:     Lags of demand for building feature vectors [nLags x 1]
% battery:          Structure with properties of battery

%% OUTPUTS:
% featVecs:         Matrix of feature vectors [nFeat x nObs]
% respVecs:         Matrix of response vectros [nResp x nObs]


%% Initializations
battery.reset();
nIdxs = size(demandGodCast, 1);
% kW -> kWh/interval:

if cfg.opt.resetPeakToMean
    peakSoFar = mean(demandDelays);
else
    peakSoFar = 0;
end

daysPassed = 0;


%% Pre-Allocations
% featVec = [nLags prev demands; stateOfCharge; (demandNow); peakSoFar];
if cfg.opt.knowDemandNow
    featVecs = zeros(cfg.fc.nLags + 3, nIdxs);
else
    featVecs = zeros(cfg.fc.nLags + 2, nIdxs);
end

% respVec = [b0, (peakForecastPower)]
if cfg.opt.setPointRecourse
    respVecs = zeros(2, nIdxs);
else
    respVecs = zeros(1, nIdxs);
end


%% Run through time series

for idx = 1:nIdxs
    demandNow = demandData(idx);
    
    % Use godCast as we want FF controller to be as good as possible
    forecast = demandGodCast(idx, :)';
    
    % We're not using setPoint:
    cfg.opt.setPoint = false;
    
    % Find optimal battery charging action
    [energyToBattery, ~] = controllerOptimizer(cfg, forecast, ...
        demandNow, battery, peakSoFar);
    
    % Save feature and response vectors:
    % featVec = [nLags prev demand; stateOfCharge; (demandNow); peakSoFar];
    if cfg.opt.knowDemandNow
        featVecs(:, idx) = [demandDelays; battery.SoC; ...
            demandNow; peakSoFar];
    else
        featVecs(:, idx) = [demandDelays; battery.SoC; peakSoFar];
    end
    
    % Save data for set-point recourse if required
    if cfg.opt.setPointRecourse
        % Peak power over horizon if forecasts correct and actions taken
        peakForecastPower = max([energyToBattery(:) + forecast(:); peakSoFar]);
        respVecs(2, idx) = peakForecastPower;
    end
    
    energyToBatteryNow = energyToBattery(1);
    respVecs(1, idx) =  energyToBatteryNow;
    
    % Apply control action to plant, subject to rate and state of charge
    battery.chargeBy(energyToBatteryNow);
    
    % Update current peak energy reset if we are at start of
    % billing period
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
    
    % Shift demand delays and add current demand
    demandDelays = [demandDelays(2:end); demandNow];
end

end
