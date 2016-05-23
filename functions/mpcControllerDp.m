function [ totalCost, chargeProfile, totalDamageCost, demForecastUsed,...
    pvForecastUsed, respVecs, featVecs, bestCTG, imp, exp] = mpcControllerDp(cfg, ...
    trainedModel, demGodCast, demand, pvGodCast, pv, demandDelays,...
    pvDelays, battery, runControl)

% mpcController: Simulate time series behaviour of MPC controller with
% given forecast, using DP to solve horizon

% Select forecasting function handle
switch cfg.fc.modelType
    case 'FFNN'
        forecastHandle = @forecastFfnn;
    case 'RF'
        forecastHandle = @forecastRandomForest;
    case 'MLR'
        forecastHandle = @forecastMlr;
    otherwise
        error('Selected cfg.fc.modelType not implemented');
end


%% Initializations
if isfield(runControl, 'initialState')
    battery.randomReset();
else
    battery.reset();
end
nIdxs = size(demGodCast, 1);
if nIdxs ~= size(pvGodCast, 1)
    error('pv and demand godcast not of same length');
end


%% Pre-Allocations
totalCost = 0;
totalDamageCost = 0;
chargeProfile = zeros(1, nIdxs);
bestCTG = zeros(1, nIdxs);
demForecastUsed = zeros(cfg.sim.horizon, nIdxs);
pvForecastUsed = zeros(cfg.sim.horizon, nIdxs);
respVecs = zeros(1, nIdxs);
imp = zeros(1, nIdxs);
exp = zeros(1, nIdxs);

% DEBUGGING:
cumulativeValue = zeros(1, nIdxs);
valueOverNBs = zeros(1, nIdxs);
b_hats = zeros(1,nIdxs);
batteryValues = zeros(1, nIdxs);

% featVec = [nLag prev dem, (demandNow), nLag prev pv, (pvNow), SoC,...
% hourNum]
if cfg.opt.knowDemandNow
    nFeat = 2*cfg.fc.nLags + 4;
else
    nFeat = 2*cfg.fc.nLags + 2;
end
featVecs = zeros(nFeat, nIdxs);

%% Run through time series
clear controllerDp; % Clear function so first horizon is plotted

for idx = 1:nIdxs;
    demandNow = demand(idx);
    pvNow = pv(idx);
    
    if isfield(runControl, 'randomizeInterval')
        if mod(idx, runControl.randomizeInterval) == 0
            battery.randomReset();
        end
    end
    
    % Have enforced elsewhere that training and testing data-set start at
    % t=0, TODO: need to check No. of idxs dropped for godCast doesnt
    % affect this
    hourNow = mod(idx, cfg.sim.stepsPerDay);
    
    [importPrice, exportPrice] = getGridPrices(hourNow);
    imp(idx) = importPrice;
    exp(idx) = exportPrice;
    
    % Create Feature/Response Vec for FF controller training!
    % featVec = [nLag prev dem, (demandNow), nLag prev pv, (pvNow), SoC,...
    % hourNum]
    if cfg.opt.knowDemandNow
        featVecs(:, idx) = [demandDelays; demandNow; pvDelays; ...
            pvNow; battery.SoC; hourNow];
    else
        featVecs(:, idx) = [demandDelays; pvDelays; battery.SoC; ...
            hourNow];
    end
    
    if isfield(runControl, 'NB') && runControl.NB
        bestDischargeStep = 0;
        b_hat = 0;
        
    elseif isfield(runControl, 'forecastFree') && runControl.forecastFree
        [bestDischargeStep, ~, ~] = forecastFreeControl(cfg, ...
            featVecs(:, idx), battery, trainedModel, []);
        
        if bestDischargeStep < 0
            b_hat = bestDischargeStep*battery.increment/cfg.sim.batteryEtaC;
        else
            b_hat = bestDischargeStep*battery.increment*cfg.sim.batteryEtaD;
        end
        
    else
        
        if runControl.godCast
            demandForecast = demGodCast(idx, :)';
            pvForecast = pvGodCast(idx, :)';
            
        elseif isfield(runControl, 'modelCast') && runControl.modelCast
            demandForecast = demGodCast(idx, :)';
            pvForecast = pvGodCast(idx, :)';
            
        elseif runControl.naivePeriodic
            demandForecast = demandDelays(end-cfg.sim.horizon+1:end);
            pvForecast = pvDelays(end-cfg.sim.horizon+1:end);
            
        elseif runControl.setPoint
            demandForecast = ones(cfg.sim.horizon, 1).*demandNow;
            pvForecast = ones(cfg.sim.horizon, 1).*pvNow;
            
        elseif isfield(runControl, 'forecastFree') && runControl.forecastFree
            % No need for a forecast
            demandForecast = zeros(cfg.sim.horizon, 1);
            pvForecast = zeros(cfg.sim.horizon, 1);
            
        else
            % Produce forecast from input model (& asosciated method)
            demandForecast = forecastHandle( cfg, trainedModel.demand,...
                demandDelays );
            
            pvForecast = forecastHandle( cfg, trainedModel.pv, pvDelays);
        end
        
        demForecastUsed(:, idx) = demandForecast;
        pvForecastUsed(:, idx) = pvForecast;
        
        if ~runControl.setPoint
            [bestDischargeStep, bestCTG(idx)] = controllerDp(cfg, ...
                demandForecast, pvForecast, battery, hourNow);
        else
            % Do set-point control:
            bestDischargeValue = demandNow - pvNow;
            bestDischargeStep = round(bestDischargeValue./...
                battery.increment);
            
            % Limit SP decision to feasible range
            bestDischargeStep = ...
                -battery.limitChargeStep(-bestDischargeStep);
        end
        
        % Implement set point recourse, if selected
        % don't increase exports by discharging
        if cfg.opt.setPointRecourse
            while bestDischargeStep > 0 && (pvNow - demandNow + ...
                    bestDischargeStep*battery.increment*...
                    cfg.sim.batteryEtaD) > 0
                
                bestDischargeStep = bestDischargeStep - 1;
            end
            
            % Limit SPR decision to feasible range
            bestDischargeStep = ...
                -battery.limitChargeStep(-bestDischargeStep);
        end
        
        % Store best discharge step decision
        respVecs(:, idx) = bestDischargeStep;
        
        if bestDischargeStep < 0
            b_hat = (bestDischargeStep*battery.increment)...
                /cfg.sim.batteryEtaC;
        else
            b_hat = (bestDischargeStep*battery.increment)...
                *cfg.sim.batteryEtaD;
        end
    end
    
    % Apply control decision, subject to rate and state of charge
    % constriants
    chargeProfile(idx) = battery.SoC;
    
    % Energy from grid during interval
    g_t = demandNow - pvNow - b_hat;
    costWithBattery = importPrice*max(0,g_t) - exportPrice*max(0,-g_t);
    
    g_t_noBatt = demandNow - pvNow;
    costWithoutBattery = importPrice*max(0,g_t_noBatt) - ...
        exportPrice*max(0,-g_t_noBatt);
    
    valueOverNB = costWithoutBattery - costWithBattery;
    if idx == 1
        cumulativeValue(idx) = valueOverNB;
    else
        cumulativeValue(idx) = cumulativeValue(idx-1) + valueOverNB;
    end
    
    battery.chargeStep(-bestDischargeStep, valueOverNB);
    
    valueOverNBs(idx) = valueOverNB;
    b_hats(idx) = b_hat;
    batteryValues(idx) = battery.Value();

    
    fracDegradation = calcFracDegradation(cfg, battery, battery.state,...
        bestDischargeStep);
    
    damageCost = battery.Value()*fracDegradation;
    totalDamageCost = totalDamageCost + damageCost;
    
    totalCost = totalCost + costWithBattery + damageCost;
    
    % Shift demand delays (and add current demand)
    demandDelays = [demandDelays(2:end); demandNow];
    pvDelays = [pvDelays(2:end); pvNow];
    
    % DEBUGGING:
    if mod(idx, 1000) == 0
        disp('idx done: ');
        disp(idx);
    end
end

figure;
plot(cumulativeValue);
disp('Ending Battery Value: ');
disp(battery.Value());

end
