function [ dataTrain, dataTest ] = loadData( cfg )
% loadData: Load the demand data for the customers, and divide into
%               training and test sets

nIntervalsTrain = cfg.fc.nHoursTrain*cfg.sim.stepsPerHour;
nIntervalsTest = cfg.sim.nHoursTest*cfg.sim.stepsPerHour;

if isequal(cfg.type, 'oso')
    [unixTime1, allDemandValues] = importFilesFromFolder(...
        [cfg.osoDataFolder filesep 'demand' filesep], cfg.sim.nInstances);
    
    [unixTime2, allPvValues] = importFilesFromFolder(...
        [cfg.osoDataFolder filesep 'PV' filesep], cfg.sim.nInstances);
    
    if ~isequal(unixTime1, unixTime2); error('Timestamps dont match'); end;
    
    % Drop any unneeded data & package data into single structure
    dataLengthRequired = nIntervalsTrain + nIntervalsTest + ...
        2*cfg.sim.stepsPerDay;
    
    serialTime = datetime(unixTime1, 'ConvertFrom', 'posixtime', ...
        'TimeZone', 'Australia/Sydney');
    serialTime = serialTime(1:dataLengthRequired);
    allDemandValues = allDemandValues(1:dataLengthRequired,:);
    allPvValues = allPvValues(1:dataLengthRequired,:);
    
    % Find offset required to start train, and test period at midnight
    zeroTestIdx = 49 - 2*hour(serialTime(1)) - (minute(serialTime(1))/30);
    trainIdxs = zeroTestIdx + (1:nIntervalsTrain);
    dataTrain.demand = allDemandValues(trainIdxs, :);
    dataTrain.pv = allPvValues(trainIdxs, :);
    dataTrain.time = serialTime(trainIdxs);
    
    firstTrIdx = max(trainIdxs) + 1;
    zeroTrIdx = 48 - 2*hour(serialTime(firstTrIdx)) - ...
        minute(serialTime(firstTrIdx))/30;
    
    % Second alignment step should not be necessary, if whole No. days
    % training and testing selected?
    testIdxs = firstTrIdx + zeroTrIdx + (1:nIntervalsTest);
    dataTest.demand = allDemandValues(testIdxs, :);
    dataTest.pv = allPvValues(testIdxs, :);
    dataTest.time = serialTime(testIdxs);
    
    % Test that we have 1st interval (of 48)
    train1stInt = 2*hour(dataTrain.time(1)) + minute(dataTrain.time(1))/30;
    test1stInt = 2*hour(dataTest.time(1)) + minute(dataTest.time(1))/30;
    if train1stInt ~= 1 || test1stInt ~= 1
        error('Either train on test data doesnt start at start of day');
    end
    
else
    
    % Load pre-saved MATLAB file
    load(cfg.dataFileWithPath);
    
    % puts 'demandData' matrix in funciton workspace
    % [nIntervalsRead x nMeters]
    
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
