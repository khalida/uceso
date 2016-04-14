function plotAllResultsDp( cfg, results, dataTrain)

% plotAllResultsDp: Plot outputs from 'trainAllForecasts' and
% 'testAllFcasts' functions.

%% Expand fields (of data structures)
totalCost = results.totalCost;
totalDamageCost = results.totalDamageCost;
demandTestResults = results.demandTestResults;
pvTestResults = results.pvTestResults;
storageProfile = results.storageProfile;

nDaysTrain = cfg.fc.nDaysTrain;
nInstances = cfg.sim.nInstances;

methodList = cfg.sim.methodList;
nMethods = cfg.sim.nMethods;

serialTime = dataTrain.time;

%% 1) Plot the performance of the overall methods

fig_1 = figure();

% Absolute Total Costs
subplot(3, 2, 1);
boxplot(totalCost, methodList);
grid on;
xlabel('Method');
ylabel('Total Cost [$]');
hold off;

% Relative Cost Ratios
subplot(3,2, 2);

% Reference method godCast
refMethodIdx = ismember(methodList,'PFFC');
relativeCost = totalCost./repmat(...
    totalCost(:, refMethodIdx), [1, nMethods]);
boxplot(relativeCost, methodList);
grid on;
xlabel('Method');
ylabel('Relative Cost []');

% Absolute cost savings
subplot(3, 2, 3);
noBatteryIdx = ismember(methodList, 'NB');
batteryValue = repmat(totalCost(:,noBatteryIdx),[1, nMethods]) - totalCost; 
boxplot(batteryValue, methodList);
grid on;
xlabel('Method');
ylabel('Cost Saved [$]');

% Relative cost savings
subplot(3, 2, 4);
relativeBatteryValue = batteryValue./repmat(...
    batteryValue(:, refMethodIdx), [1, nMethods]);

boxplot(relativeBatteryValue, methodList);
grid on;
xlabel('Method');
ylabel('Rel. Cost Saved []');

% Absolute battery damage cost
subplot(3, 2, 5);
boxplot(totalDamageCost, methodList);
grid on;
xlabel('Method');
ylabel('Damage Cost [$]');

% Relative battery damage cost
subplot(3, 2, 6);
relativeDamageCost = totalDamageCost./repmat(...
    totalDamageCost(:, refMethodIdx), [1, nMethods]);

boxplot(relativeDamageCost, methodList);
grid on;
xlabel('Method');
ylabel('Rel. Dmg. Cost []');

print(fig_1, '-dpdf', [cfg.sav.resultsDir filesep ...
    'allCostResults.pdf']);

%% 2. For forecast-driven methods plot the MSEs of Demand forecasts

fig_2 = figure();

forecastDrivenMethods = {'NPFC', 'MFFC', 'PFFC'};
forecastDrivenIdxs = [];
for ii = 1:length(cfg.sim.methodList);
    if ismember(cfg.sim.methodList{ii}, forecastDrivenMethods)
        forecastDrivenIdxs = [forecastDrivenIdxs ii]; %#ok<AGROW>
    end
end
boxplot(demandTestResults(:, forecastDrivenIdxs),...
    methodList(forecastDrivenIdxs));
xlabel('Method');
ylabel(['Demand Forecast MSE [kWh^2], ' num2str(nDaysTrain) '-day train']);
grid on;
hold off;

print(fig_2, '-dpdf', [cfg.sav.resultsDir filesep ...
    'demandForecastLossResults.pdf']);


%% 3. As above, but for PV forecasts

fig_3 = figure();

boxplot(pvTestResults(:, forecastDrivenIdxs),...
    methodList(forecastDrivenIdxs));
xlabel('Method');
ylabel(['PV Forecast MSE [kWh^2], ' num2str(nDaysTrain) '-day train']);
grid on;
hold off;

print(fig_3, '-dpdf', [cfg.sav.resultsDir filesep ...
    'pvForecastLossResults.pdf']);

%% 4. Plot the various charge profiles
fig_4 = figure();
for ii = 1:nInstances
    subplot(nInstances, 1, ii);
    plot(squeeze(storageProfile(ii, :, :))');
    legend(methodList);
    grid on;
end

print(fig_4, '-dpdf', [cfg.sav.resultsDir filesep ...
    'storageProfiles.pdf']);


%% 5. Look at time-series forecasts (first index for each customer)
fig_5 = figure();
nForecastDrivenMethods = length(forecastDrivenIdxs);
% results.allDemFcs{instance}{method}(tStepAhead, Index)
for ii = 1:nInstances
    theseDemandForecasts = zeros(cfg.sim.horizon, nForecastDrivenMethods);
    thesePvForecasts = zeros(cfg.sim.horizon, nForecastDrivenMethods);
    
    for idx = 1:nForecastDrivenMethods
        methodIdx = forecastDrivenIdxs(idx);
        theseDemandForecasts(:, idx) = ...
            results.allDemFcs{ii}{methodIdx}(:, 1);
        
        thesePvForecasts(:, idx) = ...
            results.allPvFcs{ii}{methodIdx}(:, 1);
    end
    subplot(nInstances, 2, 2*ii-1);
    plot(theseDemandForecasts);
    legend(methodList(forecastDrivenIdxs));
    xlabel('Intervals Ahead');
    ylabel('Demand Forecast [kWh/interval]');
    
    subplot(nInstances, 2, 2*ii);
    plot(thesePvForecasts);
    legend(methodList(forecastDrivenIdxs));
    xlabel('Intervals Ahead');
    ylabel('PV Forecast [kWh/interval]');
end

print(fig_5, '-dpdf', [cfg.sav.resultsDir filesep ...
    'timeSeriesForecasts.pdf']);

%% 6. Look at raw data (help with fault-finding)
fig_6 = figure();
ax1 = subplot(2,1,1);
plot(serialTime, dataTrain.demand);
ylabel('Demand kWh/interval');
datetickzoom('x');
ax2 = subplot(2,1,2);
plot(serialTime, dataTrain.pv);
ylabel('PV kWh/interval');
xlabel('Date n Time');
xlim(datenum([mean(serialTime), mean(serialTime) + 7]));
datetickzoom('x')
linkaxes([ax1, ax2], 'x');

print(fig_6, '-dpdf', [cfg.sav.resultsDir filesep ...
    'timeSeriesInputData.pdf']);


end