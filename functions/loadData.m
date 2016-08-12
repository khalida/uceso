function [ dataTrain, dataTest, cfg ] = loadData( cfg )
% loadData: Load the demand data for the customers, and divide into
%               training and test sets

nIntervalsTrain = cfg.fc.nHoursTrain*cfg.sim.stepsPerHour;
nIntervalsTest = cfg.sim.nHoursTest*cfg.sim.stepsPerHour;

if isequal(cfg.type, 'oso')
    % Indexes to use for oso instances:
    [unixTime, allValues] = importFilesFromFolder(cfg);
    
    aggregationFactor = 2/cfg.sim.stepsPerHour;
    if aggregationFactor < 1 || ~isWholeNumber(aggregationFactor)
        error('Aggregation factor needs to be whole integer >= 1');
    elseif aggregationFactor > 1
        [unixTime, allValues] = temporallyAggregateData(unixTime, ...
            allValues, aggregationFactor);
        
        cfg.fc.nHoursTrain = floor(cfg.fc.nHoursTrain/aggregationFactor);
        cfg.sim.nHoursTest = floor(cfg.sim.nHoursTest/aggregationFactor);
    end
    
    % Drop any unneeded data & package data into single structure
    dataLengthRequired = nIntervalsTrain + nIntervalsTest + ...
        2*cfg.sim.stepsPerDay;
    
    serialTime = datetime(unixTime, 'ConvertFrom', 'posixtime', ...
        'TimeZone', 'Australia/Sydney');
    
    serialTime = serialTime(1:dataLengthRequired);
    allValues.pv = allValues.pv(1:dataLengthRequired,:);
    allValues.demand = allValues.demand(1:dataLengthRequired,:);
    
    % Find offset required to start train, and test period at midnight
    listOfTimes = zeros(cfg.sim.stepsPerDay, 1);
    for idx = 1:length(listOfTimes)
        listOfTimes(idx) = hour(serialTime(idx)) + ...
            minute(serialTime(idx))/60;
    end
    [~, minTimeIdx] = min(listOfTimes);
    trainIdxs = (1:nIntervalsTrain) + minTimeIdx - 1;
    dataTrain.demand = allValues.demand(trainIdxs, :);
    dataTrain.pv = allValues.pv(trainIdxs, :);
    dataTrain.time = serialTime(trainIdxs);
    
    firstTrIdx = max(trainIdxs) + 1;
    
    for idx = 1:length(listOfTimes)
        listOfTimes(idx) = hour(serialTime(firstTrIdx + idx - 1)) + ...
            minute(serialTime(firstTrIdx + idx - 1))/60;
    end
    [~, minTimeIdx] = min(listOfTimes);
    testIdxs = (1:nIntervalsTest) + firstTrIdx + minTimeIdx - 2;
    dataTest.demand = allValues.demand(testIdxs, :);
    dataTest.pv = allValues.pv(testIdxs, :);
    dataTest.time = serialTime(testIdxs);
    
    % Test that we have 1st interval (of 48)
%     train1stInt = 2*hour(dataTrain.time(1)) + minute(dataTrain.time(1))/30;
%     test1stInt = 2*hour(dataTest.time(1)) + minute(dataTest.time(1))/30;
%     if train1stInt ~= 1 || test1stInt ~= 1
%         error('Either train on test data doesnt start at start of day');
%     end
    
else
    
    % Load pre-saved MATLAB file
    load(cfg.dataFileWithPath);
    
    % puts 'demandData' matrix in function workspace
    % [nIntervalsRead x nMeters]
    
    % don't allow use of anything other than half-hourly data for the
    % peak-minimization problem:
    if cfg.sim.stepsPerHour ~= 2
        errro('minMaxDemand must be run with half-hourly interval');
    end
    
    dataTrain.demand = zeros(nIntervalsTrain, cfg.sim.nInstances);
    dataTest.demand = zeros(nIntervalsTest, cfg.sim.nInstances);
    dataTest.meanTrainKwhs = zeros(1, cfg.sim.nInstances);
    
    instance = 0;
    for nCustomerIdx = 1:length(cfg.sim.nCustomers)
        for trial = 1:cfg.sim.nAggregates
            instance = instance + 1;
            customers = cfg.sim.nCustomers(nCustomerIdx);
            customerIdxs = randsample(size(demandData, 2), customers);
            
            dataTrain.demand(:, instance) = ...
                sum(demandData(1:nIntervalsTrain, customerIdxs), 2);
            
            dataTest.demand(:, instance) = ...
                sum(demandData(nIntervalsTrain+(1:nIntervalsTest), ...
                customerIdxs), 2);
            
            dataTest.meanTrainKwhs(instance) = ...
                mean(dataTrain.demand(:, instance));
        end
    end
end

end
