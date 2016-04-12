%% Load Running Configuration
clearvars; close all; clc;
tic;
cfg = Config(pwd);

%% Load Functions into Environment (script)
LoadFunctions;

%% Load Data
disp('======= LOADING DATA =======');
[ demandDataTrain, demandDataTest ] = loadData( cfg );

forecastMethods = {'NP', 'MLR', 'FFNN'};
forecastMses = cell(cfg.sim.nInstances, 1);
forecastRms = cell(cfg.sim.nInstances, 1);
for instance = 1:cfg.sim.nInstances
    forecastMses{instance} = zeros(length(forecastMethods), 1);
    forecastRms{instance} = zeros(length(forecastMethods), 1);
end


%% Train and compare multiple forecast methods:

parfor instance = 1:(cfg.sim.nInstances)
    demand_train = demandDataTrain(:, instance);
    demand_test = demandDataTest(:, instance);
    
    for fcIdx = 1:length(forecastMethods)
        
        thisMse = []; %#ok<NASGU> (prevent parfor warnings)
        thisRms = []; %#ok<NASGU> (prevent parfor warnings)
        
        switch forecastMethods{fcIdx}
            
            case 'NP'
                [thisMse, thisRms] = assessNp(cfg, demand_test);
                
            case 'MLR'
                model = trainMlrForecast(cfg, demand_train);
                [thisMse, thisRms] = assessMlr(cfg, model, demand_test);
                
            case 'FFNN'
                model = trainFfnnMultipleStarts(cfg, demand_train);
                [thisMse, thisRms] = assessFfnn(cfg, model, demand_test);
                
            case 'VSNN'
                model = trainVsnn(cfg, demand_train);
                [thisMse, thisRms] = assessVsnn(model, demand_test);
                
            case 'RNN'
                model = trainRnn(cfg, demand_train);
                [thisMse, thisRms] = assessRnn(cfg, model, demand_test);
                
            otherwise
                error('Model not implemented');
        end
        
        forecastMses{instance}(fcIdx) = thisMse;
        forecastRms{instance}(fcIdx) = thisRms;
    end
end

%% Plot the resulting forecast errors
instance = 0;
figure();
for nCustomerIdx = 1:length(cfg.sim.nCustomers)
    subplot(1, length(cfg.sim.nCustomers), nCustomerIdx);
    theseForecastMses = zeros(cfg.sim.nAggregates, ...
        length(forecastMethods));
    
    for trial = 1:cfg.sim.nAggregates
        instance = instance + 1;
        theseForecastMses(trial, :) = forecastMses{instance};
    end
    boxplot(theseForecastMses, forecastMethods);
    xlabel('Method');
    ylabel(['Forecast MSE, ' num2str(cfg.sim.nCustomers(nCustomerIdx))...
        ' customers']);
    grid on;
end

%% Plot the noise-to-signal ratio suggested by each of the models:
instance = 0;
figure();
for nCustomerIdx = 1:length(cfg.sim.nCustomers)
    subplot(1, length(cfg.sim.nCustomers), nCustomerIdx);
    
    noiseToSignalRatio = zeros(cfg.sim.nAggregates, ...
        length(forecastMethods));
    
    for trial = 1:cfg.sim.nAggregates
        instance = instance + 1;
        noiseToSignalRatio(trial, :) = sqrt(forecastMses{instance})./...
            forecastRms{instance};
    end
    
    boxplot(noiseToSignalRatio, forecastMethods);
    xlabel('Method');
    ylabel(['Noise-to-signal Ratio, ' num2str(cfg.sim.nCustomers(nCustomerIdx))...
        ' customers']);
    grid on;
end

toc;