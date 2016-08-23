function plotAllResults( cfg, results)

% plotAllResultsMetricSelect: Plot outputs from 'trainAllForecasts' and
% 'testAllFcasts' functions.

% Expand fields of data structures
meanKWhs = results.meanKWhs;
peakReductionsTrialFlattened = results.peakReductionsTrialFlattened;
smallestExitFlag = results.smallestExitFlag;
peakReductions = results.peakReductions;
lossTestResults = results.lossTestResults;
noiseSglRatioDem = results.noiseSglRatioDem;

nDaysTrain = cfg.fc.nDaysTrain;
nDaysTest = cfg.sim.nDaysTest;

methodList = cfg.sim.methodList;
nMethods = cfg.sim.nMethods;
nInstances = cfg.sim.nInstances;

%% Plotting flags to control which plots are produced
plotAllIndividualPRRs = false;
plotRelativePRR = false;
plotPRRboxPlots = false;
plotForecastErrorBoxPlots = false;
plotForecastPerfSplitByAggSize = false;
includeErrorBars = false;

xOffPlot = NaN;
yOffPlot = NaN;

methodsToIncludePrr = {'SP', 'NPFC', 'MFFC', 'IMFC', 'PFFC'};
methodsToIncludeSglNoise = {'NPFC', 'MFFC'};

methodsToIncludePrrIdxs = [];
methodsToIncludeSglNoiseIdxs = [];
for ii = 1:length(methodList);
    if ismember(methodList{ii}, methodsToIncludePrr)
        methodsToIncludePrrIdxs = [methodsToIncludePrrIdxs ii]; %#ok<AGROW>
    end
    if ismember(methodList{ii}, methodsToIncludeSglNoise)
        methodsToIncludeSglNoiseIdxs = [methodsToIncludeSglNoiseIdxs ii]; %#ok<AGROW>
    end
end

%% 1) Plot all individual peak reduction ratios VS Aggregation Size
% With subplots for absolute and relative performance
if plotAllIndividualPRRs
    
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
end

%% 2) Plot Absolute PRR against aggregation size (publication plot)
fig_2 = figure();
ax1 = subtightplot(3,1,1:2);
selectedForecasts = methodsToIncludePrrIdxs;
selectedForecastLabels = methodList(selectedForecasts);
meanPeakReductions = ...    % nCustomers X forecastTypes
    squeeze(mean(peakReductions(selectedForecasts, :, :), 2));

stdPeakReductions = ...
    squeeze(std(peakReductions(selectedForecasts, :, :),[], 2)); %#ok<NASGU>

meanKWhs = mean(meanKWhs, 1); % nCustomers X 1
if includeErrorBars
    errorbar(repmat(meanKWhs, [length(selectedForecasts), 1])', ...
        meanPeakReductions',stdPeakReductions','.-', 'markers', 20);
else
    plot(repmat(meanKWhs, [length(selectedForecasts), 1])', ...
        meanPeakReductions','.-', 'markers', 20);
end

ylabel({'Mean Peak Reduction','Ratio []'});
legend(selectedForecastLabels, 'Location', 'North',...
    'Orientation', 'Horizontal');

grid on;
% set(gca, 'XTickLabel', '');

ax2 = subtightplot(3,1,3);
hold on;
% noiseSglaRatioDem has dimension:
% [nMethods, nAggregates, length(cfg.sim.nCustomers)]
meanSignalNoiseRatio = squeeze(mean(noiseSglRatioDem, 2));

for idx = 1:nMethods
    if ismember(idx, methodsToIncludePrrIdxs)
        if ismember(idx, methodsToIncludeSglNoiseIdxs)        
            plot(meanKWhs, meanSignalNoiseRatio(idx, :), '.-');
        else
            plot(xOffPlot, yOffPlot, '.-');
        end
    end
end

grid on;
xlabel('Mean Demand of Aggregation [kWh/interval]');
ylabel({'Noise:Signal', 'Demand []'});
linkaxes([ax1 ax2], 'x');
set([ax1 ax2], 'xscale', 'log');
xlim([0.4, 50]);

print(fig_2, '-dpdf', [cfg.sav.resultsDir filesep ...
    'absolutePrrVsAggregationSize.pdf']);

plotAsTixz([cfg.sav.resultsDir filesep ...
    'absolutePrrVsAggregationSize.tikz']);


%% 3) Plot Relative PRR against aggregation size (as means +/- error bars)
if plotRelativePRR
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
end


%% 4) BoxPlots of Rel/Abs PRR for each Method (across all instances)
if plotPRRboxPlots
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
end

%% 5) Box Plots of forecast errors for forecast-based methods

if plotForecastErrorBoxPlots
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
end

%% 6) Version of forecasting performance split out by aggregation size:
% Also include noiseToSignalRatios
if plotForecastPerfSplitByAggSize
fig_6 = figure();
nCustomerGroupSizes = length(cfg.sim.nCustomers);
for customerGroupSize = 1:nCustomerGroupSizes
    subplot(nCustomerGroupSizes, 2, 2*customerGroupSize-1);
    boxplot(lossTestResults(forecastDrivenIdxs, :, customerGroupSize)',...
        'labels', methodList(forecastDrivenIdxs), 'plotstyle', 'compact');
    
    ylabel('Forecast MSE [kWh^2]');
    title([num2str(cfg.sim.nCustomers(customerGroupSize)),...
        ' customer(s)']);
    
    subplot(nCustomerGroupSizes, 2, 2*customerGroupSize);
    boxplot(noiseSglRatioDem(forecastDrivenIdxs, :, customerGroupSize)',...
        'labels', methodList(forecastDrivenIdxs), 'plotstyle', 'compact');
    ylabel('Noise to Signal Ratio []');
    title([num2str(cfg.sim.nCustomers(customerGroupSize)),...
        ' customer(s)']);
    
    grid on;
end

print(fig_6, '-dpdf', [cfg.sav.resultsDir filesep ...
    'forecastMseResultsBoxPlot_splitByAggregationSize.pdf']);
end

end
