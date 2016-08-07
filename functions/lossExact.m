function [ loss ] = lossExact( t, y, runSettings)  %#codegen
% lossExact: Compute loss metric for [k x nObservations] matrices of
% target, t, and forecast values, y.

% INPUTS:
% t:            matrix of target (actual) values; [horizon x nObservations]
% y:            matrix of forecast values; [horizon x nObservations]
% runSettings:  structure containing simulation parameters

% OUTPUTS:
% loss:         row vector of loss values [ 1 x nObservations]

% Extract running options from passed in parameters
battery = runSettings.battery;
cfg = runSettings.cfg;
cfg.opt.setPoint = false;

% Pre-allocate:
nObs = size(t, 2);
loss = NaN(1, nObs);

% Remove any NaN values in t:
colsWithNan = sum(isnan(t), 1) > 0;
y_noNaN = y(:, ~colsWithNan);
t_noNaN = t(:, ~colsWithNan);
nObsNoNaN = size(y_noNaN, 2);

for obs = 1:nObsRun
    if strcmp(cfg.type, 'oso')
        % Set states
        battery.resetTo();

        % And run model
                
    else
        battery.SoC = ;
        [energyToBatteryPF, ~] = controllerOptimizer(cfg, t_noNaN(:, obs), ...
            t_noNaN(1,obs), battery, peakSoFarAll(obs));
        
        [energyToBatteryFC, ~] = controllerOptimizer(cfg, y_noNaN(:, obs), ...
            t_noNaN(1,obs), battery, peakSoFarAll(obs));
        
        loss(obs) = (energyToBatteryPF(1) - energyToBatteryFC(1)).^2;
        
    end
end

end
