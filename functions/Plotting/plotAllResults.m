function plotAllResults( cfg, results)

% plotAllResultsMetricSelect: Plot outputs from 'trainAllForecasts' and
% 'testAllFcasts' functions.

% Expand fields (of data structures)
meanKWhs = results.meanKWhs;
peakReductionsTrialFlattened = results.peakReductionsTrialFlattened;
smallestExitFlag = results.smallestExitFlag;
peakReductions = results.peakReductions;
lossTestResults = results.lossTestResults;

nDaysTrain = cfg.fc.nDaysTrain;
nDaysTest = cfg.sim.nDaysTest;

methodList = cfg.sim.methodList;
nMethods = cfg.sim.nMethods;
nInstances = cfg.sim.nInstances;

%% 1) Plot all individual peak reduction ratios VS Aggregation Size
% With subplots for absolute and relative performance

fig_1 = figure();

% Absolute Peak Reduction Ratios
subplot(1, 2, 1);
plot(meanKWhs(:), peakReductionsTrialFlattened', '.', 'markers', 20);
hold on;
% Plot warning circles about optimality
warnPeakReductions = peakReductionsTrialFlattened(smallestExitFlag < 1);
extendedKWhs = repmat(meanKWhs(:)', [nMethods, 1]);
warnkWhs = extendedKWhs(smallestExitFlag < 1);
if (isempty(warnkWhs))
    warnkWhs = -1;
    warnPeakReductions = -1;
end
plot(warnkWhs, warnPeakReductions, 'ro', 'markers', 20);
xlabel('Mean Load [kWh/interval]');
ylabel(['Mean PRR, ' num2str(nDaysTrain) '-day train, '...
    num2str(nDaysTest) '-day test']);

legend([methodList, {'Some intervals not solved to optimality'}],...
    'Location', 'best','Interpreter', 'none');
hold off;

% Relative peak reduction ratios
subplot(1, 2, 2);

% Reference method godCast
refMethodIdx = ismember(methodList,'PFFC');
peakReductionsRelative = peakReductions./repmat(...
    peakReductions(refMethodIdx, :, :), [nMethods, 1, 1]);

peakReductionsRelativeTrialFlattened = reshape(peakReductionsRelative,...
    [nMethods, nInstances]);

plot(meanKWhs(:), peakReductionsRelativeTrialFlattened', '.','markers', 20);
hold on;
% Plot warning circles about optimality
warnPeakReductions = peakReductionsRelativeTrialFlattened(...
    smallestExitFlag < 1);
if (isempty(warnPeakReductions))
    warnkWhs = -1;
    warnPeakReductions = -1;
end
plot(warnkWhs, warnPeakReductions, 'ro', 'markers', 20);
xlabel('Mean Load [kWh/interval]');
ylabel(['Mean PRR relative to Perfect Forecast, ' num2str(nDaysTrain)...
    '-day train, ' num2str(nDaysTest) '-day test']);

legend([methodList, {'Some intervals not solved to optimality'}],...
    'Location', 'best', 'Orientation', 'vertical', 'Interpreter', 'none');

hold off;
print(fig_1, '-dpdf', [cfg.sav.resultsDir filesep ...
    'allPrrResults.pdf']);


%% 2) Plot Absolute PRR against aggregation size (as means +/- error bars)

fig_2 = figure();

selectedForecasts = 1:nMethods;
selectedForecastLabels = methodList(selectedForecasts);
meanPeakReductions = ...    % nCustomers X forecastTypes
    squeeze(mean(peakReductions(selectedForecasts, :, :), 2));
stdPeakReductions = ...
    squeeze(std(peakReductions(selectedForecasts, :, :),[], 2));
meanKWhs = mean(meanKWhs, 1); % nCustomers X 1
errorbar(repmat(meanKWhs, [length(selectedForecasts), 1])', ...
    meanPeakReductions',stdPeakReductions','.-', 'markers', 20);
xlabel('Mean Load [kWh/interval]');
ylabel('Mean PRR, with +/- 1.0 std. dev.');
legend(selectedForecastLabels, 'Interpreter', 'none',...
    'Location', 'best', 'Orientation', 'vertical');
grid on;
hold off;

print(fig_2, '-dpdf', [cfg.sav.resultsDir filesep ...
    'absolutePrrVsAggregationSize.pdf']);


%% 3) Plot Relative PRR against aggregation size (as means +/- error bars)
fig_3 = figure();

meanPeakReductionsRelative = ...    % nCustomers X forecastTypes
    squeeze(mean(peakReductionsRelative(selectedForecasts, :, :), 2));
stdPeakReductionsRelative = ...
    squeeze(std(peakReductionsRelative(selectedForecasts, :, :),[], 2));
errorbar(repmat(meanKWhs, [length(selectedForecasts), 1])', ...
    meanPeakReductionsRelative',stdPeakReductionsRelative','.-',...
    'markers', 20);
xlabel('Mean Load [kWh/interval]');
ylabel('Mean relative PRR, with +/- 1.0 std. dev.');
legend(selectedForecastLabels, 'Interpreter', 'none',...
    'Location', 'best', 'Orientation', 'vertical');
grid on;
hold off;

print(fig_3, '-dpdf', [cfg.sav.resultsDir filesep ...
    'relativePrrVsAggregationSize.pdf']);

%% 4) BoxPlots of Rel/Abs PRR for each Method (across all instances)

fig_4 = figure();
% Absolute PRRs
subplot(1, 2, 1);
peakReductionsFlattened = ...
    squeeze(peakReductionsTrialFlattened(selectedForecasts, :));
boxplot(peakReductionsFlattened', 'labels', selectedForecastLabels,...
    'plotstyle', 'compact');
ylabel('Mean PRR []');
grid on;

% Relative PRRs
subplot(1, 2, 2);
peakReductionsRelativeFlattened = ...
    squeeze(peakReductionsRelativeTrialFlattened(selectedForecasts, :));
boxplot(peakReductionsRelativeFlattened', 'labels', ...
    selectedForecastLabels, 'plotstyle', 'compact');
ylabel('Mean PRR relative to perfect forecast');
grid on;

print(fig_4, '-dpdf', [cfg.sav.resultsDir filesep ...
    'allPrrResultsBoxPlot.pdf']);

%% 5) Box Plots of forecast errors for forecast-based methods

% lossTestResultsArray(iMethod, trial, nCustomerIdx)
fig_5 = figure();
forecastDrivenMethods = {'NPFC', 'MFFC', 'PFFC'};
forecastDrivenIdxs = [];
for ii = 1:length(methodList);
    if ismember(methodList{ii}, forecastDrivenMethods)
        forecastDrivenIdxs = [forecastDrivenIdxs ii]; %#ok<AGROW>
    end
end
boxplot(lossTestResults(forecastDrivenIdxs, :)', 'labels', ...
    methodList(forecastDrivenIdxs), 'plotstyle', 'compact');
ylabel('Forecast MSE [kWh^2]');
grid on;

print(fig_5, '-dpdf', [cfg.sav.resultsDir filesep ...
    'forecastMseResultsBoxPlot.pdf']);

%% 6) Version of forecasting performance split out by aggregation size:
fig_6 = figure();
nCustomerGroupSizes = length(cfg.sim.nCustomers);
for customerGroupSize = 1:nCustomerGroupSizes
    subplot(nCustomerGroupSizes, 1, customerGroupSize);
    boxplot(lossTestResults(forecastDrivenIdxs, :, customerGroupSize)',...
        'labels', methodList(forecastDrivenIdxs), 'plotstyle', 'compact');
    
    ylabel('Forecast MSE [kWh^2]')
    title([num2str(cfg.sim.nCustomers(customerGroupSize)), ' customer(s)']);
    
    grid on;
end

print(fig_6, '-dpdf', [cfg.sav.resultsDir filesep ...
    'forecastMseResultsBoxPlot_splitByAggregationSize.pdf']);