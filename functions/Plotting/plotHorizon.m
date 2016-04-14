function plotHorizon(demandForecast, pvForecast, q_t_state, hourNow, ...
    gridImport)
    
%plotHorizon: Plot a DP horizon solution:

figure();
ax(1) = subplot(5, 1, 1);
plot(demandForecast, '.-', 'MarkerSize', 20);
ylabel('demand forecast');
grid on;

ax(2) = subplot(5, 1, 2);
plot(pvForecast, '.-', 'MarkerSize', 20);
ylabel('pv forecast');
grid on;

% Generate time-series of prices:
ax(3) = subplot(5,1,3);
nStages = length(demandForecast);
importPrices = zeros(nStages,1);
exportPrices = zeros(nStages,1);
for t = 0:(nStages-1)
    [importPrices(t+1), exportPrices(t+1)] = ...
        getGridPrices(mod(hourNow+t, 48));
end
plot(importPrices, '.-', 'MarkerSize', 20);
hold on;
plot(exportPrices, '.-', 'MarkerSize', 20);
ylabel('Prices [$/kWh]');
legend({'Import Price', 'Export Price'});
grid on;
hold off;

ax(4) = subplot(5, 1, 4);
plot(q_t_state, '.-', 'MarkerSize', 20);
ylabel('q_t_state');
grid on;
title(['Battery State profile at Index: ' num2str(hourNow)]);

ax(5) = subplot(5, 1, 5);
plot(gridImport,'.-', 'MarkerSize', 20);
ylabel('Grid Import');
grid on;

linkaxes(ax, 'x');
xlim([1, length(q_t_state)]);

end
