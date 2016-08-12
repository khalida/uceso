function [decision, peakForecastEnergy, b0_raw] = ...
    forecastFreeControl(cfg, featVec, battery, model, peakSoFar)
% forecastFreeControl: Apply forecast-free control model:

%% INPUTS:
% cfg:          Structure containing all running options
% featVec:      A vector of features to input to FF model
% battery:      Battery object

%% OUTPUTS:
% decision:     minMaxDemand: kWh to charge battery with in interval, 
              % oso: bestDischargeStep for interval
              
% peakForecastEnergy: peak energy expected over interval(minMaxDemand only)

% b0_raw:      output of frecast-free model before batt constraints applied

switch cfg.fc.modelType
    
    case 'RF'
        % Make decision using output of random forest model
        respVec = model.decisionModel.predict(featVec');
        
        % Apply set point recourse if selected
        if cfg.opt.setPointRecourse && ~isequal(cfg.type, 'oso')
            peakEnergy = model.peakEnergy.predict(featVec');
        end
        
    case 'FFNN'
        % Make decision using FF controller:
        respVec = forecastFfnn(cfg, model, featVec);
        
        % Apply set point recourse if selected
        if cfg.opt.setPointRecourse && ~isequal(cfg.type, 'oso')
            peakEnergy = respVec(2);
        end
        
    otherwise
        error('Model not yet implemented');
        
end

decision = respVec(1);
b0_raw = decision;
if cfg.opt.setPointRecourse && isequal(cfg.type, 'minMaxDemand')
    peakForecastEnergy = max([peakEnergy; peakSoFar]);
else
    peakForecastEnergy = [];
end

%% Apply feasibility constraints on charge decision
if isequal(cfg.type, 'oso')
    % NB: for oso; decision is bestDischargeStep
    decision = fix(decision);
    decision = -battery.limitChargeStep(-decision);
else
    decision = battery.limitCharge(decision);
end

end
