function [ runningPeak, respVecs, featVecs, b0_raw ] = ...
    mpcControllerForecastFree(cfg, model, demand, demandDelays, battery)

% mpcControllerForecastFree: Time series simulation of a forecast free
            % controller

%% INPUT:
% cfg:          Structure holding running options
% model:        Trained FF controller object
% demand:       Vector of demand values [nObs x 1]
% demandDelays: Vector of demand lags [nLags x 1]
% battery:      Structure describing the battery

%% OUTPUT:
% runningPeak:  Vector of current running peak [nIdxs x 1]
% respVecs:     Matrix of response vectors output by model [nResp x nIdxs]
% featVecs:     Matrix of feature vectors fed into model [nFeat x nIdxs]
% b0_raw:       Unconstrained charge decisions from model [nIdxs x 1]


%% Initializations
stateOfCharge = 0.5*battery.capacity;
nIdxs = length(demand);

if cfg.opt.resetPeakToMean
    peakSoFar = mean(demandDelays);
else
    peakSoFar = 0;
end

daysPassed = 0;
lastIdx = nIdxs - cfg.sim.horizon + 1;

if cfg.opt.setPointRecourse
    respVecs = zeros(2, lastIdx);           % [b0, peakEst]
else
    respVecs = zeros(1, lastIdx);           % [b0]
end

b0_raw = zeros(lastIdx, 1);

% featureVector = [demandDelay; stateOfCharges; (demandNow); peakSoFars];
if cfg.opt.knowDemandNow
    nFeat = cfg.fc.nLags + 3;
else
    nFeat = cfg.fc.nLags + 2;
end
featVecs = zeros(nFeat, lastIdx);

%% Pre-Allocations
runningPeak = zeros(lastIdx, 1);

%% Run through time series
for idx = 1:lastIdx
    
    demandNow = demand(idx);
        
    if cfg.fc.knowFutureFF
        % featVec = [futureDemand; stateOfCharge; (demandNow); peakSoFar];
        if cfg.opt.knowDemandNow
            featVec = [demand(idx:(idx + cfg.sim.horizon - 1));...
                stateOfCharge; demandNow; peakSoFar];
        else
            featVec = [demand(idx:(idx + cfg.sim.horizon - 1));...
                stateOfCharge; peakSoFar];
        end
    else
        % featVec = [demandDelays; stateOfCharge; (demandNow); peakSoFars];
        if cfg.opt.knowDemandNow
            featVec = [demandDelays; stateOfCharge; demandNow;...
                peakSoFar];
        else
            featVec = [demandDelays; stateOfCharge; peakSoFar];
        end
    end
    
    featVecs(:, idx) = featVec;
    
    switch cfg.fc.modelType
        
        case 'RF'
            % Make decision using output of random forest model
            respVec = model.decisionModel.predict(featVec');
            
            % Apply set point recourse if selected
            if cfg.opt.setPointRecourse
                peakEnergy = model.peakEnergy.predict(featVec');
                
                energyToBatteryNow = respVec(1);
                b0_raw(idx) = energyToBatteryNow;
                peakForecastEnergy = max([peakEnergy; peakSoFar]);
                
                if (demandNow + energyToBatteryNow) > peakForecastEnergy
                    energyToBatteryNow = peakForecastEnergy - demandNow;
                end
            else
                energyToBatteryNow = respVec(1);
                b0_raw(idx) = energyToBatteryNow;
            end
            
        case 'FFNN'
            respVec = model( featVec );
            
            % Apply set point recourse if selected
            if cfg.opt.setPointRecourse
                energyToBatteryNow = respVec(1);
                b0_raw(idx) = energyToBatteryNow;
                peakForecastEnergy = max([respVec(2); peakSoFar]);
                if (demandNow + energyToBatteryNow) > peakForecastEnergy
                    energyToBatteryNow = peakForecastEnergy - demandNow;
                end
            else
                energyToBatteryNow = respVec;
                b0_raw(idx) = energyToBatteryNow;
            end
            
        otherwise
            error('Model not yet implemented');
            
    end
    
    % Apply decision, subject to rate and state of charge constraints
    energyToBatteryNow = max([energyToBatteryNow, ...
        -stateOfCharge, -demandNow, -battery.maximumChargeEnergy]);
    
    energyToBatteryNow = min([energyToBatteryNow,...
        (battery.capacity-stateOfCharge), battery.maximumChargeEnergy]);
    
    stateOfCharge = stateOfCharge + energyToBatteryNow;
    respVecs(1, idx) = energyToBatteryNow;
    
    if cfg.opt.setPointRecourse
        respVecs(2, idx) = peakForecastEnergy;
    end
    
    % Update peak power, reset if we are in new billing period
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
    
    % Shift demand delays (and add current demand)
    demandDelays = [demandDelays(2:end); demandNow];
end

end
