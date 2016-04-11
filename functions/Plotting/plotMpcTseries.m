function [ axHandle ] = plotMpcTseries(tsFig, plotIdx, demand, peaks, ...
    avgLoad, SoCs, battery, titleString, nObsTrain)

%plotMpcTseries: Plot time-series output of mpcController function

figure(tsFig);
axHandle = subplot(5,1,plotIdx);
plot([demand, peaks]);
hold on;
hline1 = refline(0, avgLoad);
hline1.Color = 'k';
plot(SoCs);
hline2 = refline(0, battery.capacity);
hline2.Color = 'g';

legend('Local Demand [kWh/int]', 'Peak so Far [kWh/int]',...
    'Avg. Demand [kWh/int]', 'SoC [kWh]', 'Batt Cap [kWh]');

title([titleString,', with ' num2str(nObsTrain) ' data points']);

end
