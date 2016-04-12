function [energyToBatteryNow, peakForecastEnergy, b0_raw] = ...
    forecastFreeControl(cfg, featVec, battery, model, peakSoFar)
% forecastFreeControl: Apply forecast-free control model:

%% INPUTS:
% cfg:          Structure containing all running options
% featVec:      A vector of features to input to FF model
% battery:      Battery object

%% OUTPUTS:
% energyToBatteryNow: energy to send to battery during present interval
% peakForecastEnergy: peak energy expected over interval

switch cfg.fc.modelType
    
    case 'RF'
        % Make decision using output of random forest model
        respVec = model.decisionModel.predict(featVec');
        
        % Apply set point recourse if selected
        if cfg.opt.setPointRecourse
            peakEnergy = model.peakEnergy.predict(featVec');
        end
        
    case 'FFNN'
        respVec = model( featVec );
        
        % Apply set point recourse if selected
        if cfg.opt.setPointRecourse
            peakEnergy = respVec(2);
        end
        
    otherwise
        error('Model not yet implemented');
        
end

energyToBatteryNow = respVec(1);
b0_raw = energyToBatteryNow;
peakForecastEnergy = max([peakEnergy; peakSoFar]);

%% Apply feasibility constraints on charge decision
energyToBatteryNow = battery.limitCharge(energyToBatteryNow);

end
