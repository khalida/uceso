function [bestDischargeStep, bestCTG] = controllerDp(cfg, demForecast, ...
    pvForecast, battery, hourNow)

% controllerDp: Solve dynamic program for the curent horizon, to
% minimise costs

% Positive b is DISCHARGING the battery!

% persistent doneHorizonPlot;

%% Initialise Values
nStates = length(battery.statesInt);
nStages = cfg.sim.horizon;

% Initialise array of costs to go (NB: cost from last stage is zero in
% all possible states)
CTG = zeros(nStates, nStages+1);
ST_b = zeros(nStates, nStages);

% Limits on battery rate-of-charge:
b_min = -battery.maxChargeRate/cfg.sim.stepsPerHour; % kWh/interval
b_max = battery.maxChargeRate/cfg.sim.stepsPerHour;  % kWh/interval
b_min_int = floor(b_min/battery.increment);       % No. charge increments
b_max_int = ceil(b_max/battery.increment);        % No. charge increments

% Get the grid prices:
importPrices = zeros(nStages,1);
exportPrices = zeros(nStages,1);
for t = 1:nStages
    [importPrices(t), exportPrices(t)] = ...
        getGridPrices(mod(hourNow+t-1, cfg.sim.horizon));
end

% Work back through previous stages and find minimum cost to go
% store the chosen charge decision in ST_b
for t = nStages:-1:1
    
    % For all possible starting states
    for q = 1:nStates
        
        % Initialise bestCTG to large value 
        % and best discharge to infeasible value
        bestCTG = inf;
        bestB = inf;
        
        % Further constrain minimum and maximum b (charging energy)
        this_b_min_int = max(b_min_int, q-nStates);
        this_b_max_int = min(b_max_int, q-1);
        
        % For each feasible discharging decision check the resulting CTG
        for thisB = this_b_min_int:this_b_max_int
            
            % Find net power from battery (account for losses)
            if thisB > 0
                b_hat = thisB*battery.increment*cfg.sim.batteryEtaD;
            else
                b_hat = thisB*battery.increment/cfg.sim.batteryEtaC;
            end
            
            % Find energy from grid during interval
            g_t = demForecast(t)- b_hat - pvForecast(t);
            
            % Find battery damage cost
            %fracDegradation = calcFracDegradation(cfg, battery, q, ...
            %    thisB);
            
            %damageCost = fracDegradation*battery.Value();
            
            % Battery degradation cost (fixed per kWh-through-put):
            damageCost = abs(thisB)*battery.increment*0.5*...
                cfg.bat.costPerKwhUsed;
            
            % Total state transition cost for this decision from here
            thisSTC = importPrices(t)*max(0,g_t) - ...
                exportPrices(t)*max(0,-g_t) + damageCost;
            
            % Total cost-to-got for this decision from here to end
            thisCTG = thisSTC + CTG(q-thisB, t+1);
            
            % Store decision if it's the best found so far
            if (thisCTG < bestCTG - cfg.sim.minCostDiff)
                bestB = thisB;
                bestCTG = thisCTG;
            end
            
        end
        
        % Store the best discharging decision found
        ST_b(q, t) = bestB;
        CTG(q, t) = bestCTG;
        
    end
end

% Create time-series of charge decisions, and SoC
q_t_state = zeros(nStages+1, 1);
gridImport = zeros(nStages, 1);
q_t_state(1) = battery.state;

for t=2:nStages
    % DEBUGGING:
    % disp('t-1: ');disp(t-1);
    % disp('q_t_state(t-1): ');disp(q_t_state(t-1));
    q_t_state(t) = q_t_state(t-1) - ST_b(q_t_state(t-1), t-1);
    
    if ST_b(q_t_state(t-1), t-1) > 0
        b_hat = ST_b(q_t_state(t-1), t-1)*battery.increment*...
            cfg.sim.batteryEtaD;
    else
        b_hat = ST_b(q_t_state(t-1), t-1)*battery.increment/...
            cfg.sim.batteryEtaC;
    end
    gridImport(t) = demForecast(t)- b_hat - pvForecast(t);
    
    if(q_t_state(t) < 1 || q_t_state(t)>nStates)
        error('Battery state out of bounds');
    end
end

% Check ending SoC of battery
q_t_state(nStages+1) = q_t_state(nStages) - ST_b(q_t_state(nStages), ...
    nStages);
if(q_t_state(nStages) < 1 || q_t_state(nStages)>nStates)
    error('Battery state out of bounds');
end

% Compute the best integer state change of battery
bestDischargeStep =  ST_b(battery.state, 1);
bestCTG = CTG(battery.state, 1);

% DEBUG: Produce plot of optimal horizon decisions for 1st interval:
% if isempty(doneHorizonPlot)
%     plotHorizon(demForecast, pvForecast, q_t_state, hourNow, ...
%         gridImport);
%     
%     doneHorizonPlot = true;
% end

end
