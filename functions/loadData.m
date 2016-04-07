function [ demandDataTrain, demandDataTest ] = loadData( cfg )
% loadData: Load the demand data for the customers, and divide into
%               training and test sets

% Load pre-saved MATLAB file
load(cfg.dataFileWithPath);

% puts 'demandData' matrix in funciton workspace
% [nIntervalsRead x nMeters]

nIntervalsTrain = cfg.fc.nHoursTrain*cfg.sim.stepsPerHour;
nIntervalsTest = cfg.sim.nHoursTest*cfg.sim.stepsPerHour;

demandDataTrain = zeros(nIntervalsTrain, cfg.sim.nInstances);
demandDataTest = zeros(nIntervalsTest, cfg.sim.nInstances);

instance = 0;
for nCustomerIdx = 1:length(cfg.sim.nCustomers)
    for trial = 1:cfg.sim.nAggregates
        instance = instance + 1;
        customers = cfg.sim.nCustomers(nCustomerIdx);
        customerIdxs = randsample(size(demandData, 2), customers);
        
        demandDataTrain(:, instance) = ...
            sum(demandData(1:nIntervalsTrain, customerIdxs), 2);

        demandDataTest(:, instance) = ...
            sum(demandData(nIntervalsTrain+(1:nIntervalsTest), ...
            customerIdxs), 2);
    end
end

end
