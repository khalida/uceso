%% Load Running Configuration
clearvars; close all; clc;
tic;
timeStart = clock;
disp(timeStart);
Config;

LoadFunctions;

%% Read in DATA
load(dataFileWithPath);
customerIdxs = cell(Sim.nInstances, 1);
allDemandValues = cell(Sim.nInstances, 1);
dataLengthRequired = (Sim.nDaysTrain + Sim.nDaysTest)*...
    Sim.stepsPerDay;

instance = 0;
for nCustomerIdx = 1:length(Sim.nCustomers)
    for trial = 1:Sim.nAggregates
        instance = instance + 1;
        customers = Sim.nCustomers(nCustomerIdx);
        customerIdxs{instance} = ...
            randsample(size(demandData, 2), customers);
        allDemandValues{instance} = ...
            sum(demandData(1:dataLengthRequired,...
            customerIdxs{instance}), 2);
    end
end

% Delete the original demand data (no longer needed)
clearvars demandData;

forecastMethods = {'NP', 'MLR', 'FFNN', 'RNN'};
forecastMses = cell(Sim.nInstances, 1);
for instance = 1:Sim.nInstances
    forecastMses{instance} = zeros(length(forecastMethods), 1);
end


% Train and compare multiple forecast methods:

parfor instance = 1:(Sim.nInstances)
    demand_train = allDemandValues{instance}(...
        1:(Sim.nDaysTrain*Sim.stepsPerDay));
    
    demand_test = allDemandValues{instance}(...
        length(demand_train) + (1:(Sim.nDaysTest*Sim.stepsPerDay)));
    
    for fcIdx = 1:length(forecastMethods)
        
        thisMse = []; %#ok<NASGU> (prevent parfor warnings)
        
        switch forecastMethods{fcIdx}
            
            case 'NP'
                thisMse = assessNp(demand_test, Sim.trainControl);
                
            case 'MLR'
                model = trainMlrForecast(demand_train, Sim.trainControl);
                thisMse = assessMlr(model, demand_test);
                
            case 'FFNN'
                model = trainFfnnMultipleStarts(demand_train, ...
                    Sim.trainControl);
                
                thisMse = assessFfnn(model, demand_test);
                
            case 'VSNN'
                model = trainVsnn(demand_train, Sim.trainControl);
                thisMse = assessVsnn(model, demand_test);
                
            case 'RNN'
                model = trainRnn(demand_train, Sim.trainControl);
                thisMse = assessRnn(model, demand_test);
                
            otherwise
                error('Model not implemented');
        end
        
        forecastMses{instance}(fcIdx) = thisMse;
    end
end

%% Plot the resulting forecast errors
instance = 0;
for nCustomerIdx = 1:length(Sim.nCustomers)
    subplot(1, length(Sim.nCustomers), nCustomerIdx);
    theseForecastMses = zeros(Sim.nAggregates, length(forecastMethods));
    for trial = 1:Sim.nAggregates
        instance = instance + 1;
        theseForecastMses(trial, :) = forecastMses{instance};
    end
    boxplot(theseForecastMses, forecastMethods);
    xlabel('Method');
    ylabel(['Forecast MSE, ' num2str(Sim.nCustomers(nCustomerIdx))...
        ' customers']);
    grid on;
end

toc;