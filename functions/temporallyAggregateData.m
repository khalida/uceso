function [unixTime, allValues] = temporallyAggregateData(unixTime, ...
            allValues, aggregationFactor)
        
% INPUTS:
% unixTime:     [nObs x 1] array of unix time stamps
% allValues:    struct of .pv, and .demand [nObs x nAggregates] array of pv
                    % and demand values over-the-interval [kWh]
                    
% OUTPUTS:
% unixTime:     [nObs/aggregationFactor x 1] array of unix time stamps
% allValues:    struct of .pv, and .demand [nObs/aggregationFactor x...
                % nAggregates] array of pv and demand over interval [kWh]

% Replace unix time-stamp with mean over included intervals
unixTime = blkproc(unixTime, [aggregationFactor, 1], @mean); %#ok<*DBLKPRC>

nCols = size(allValues.pv, 2);

% Replace cumulative PV and demand with summed kWh over included intervals
allValues.pv = blkproc(allValues.pv, [aggregationFactor, nCols], @sum);
allValues.demand = blkproc(allValues.demand, [aggregationFactor, nCols],...
    @sum);

end
