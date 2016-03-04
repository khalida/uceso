function [ featureVectors, responseVectors ] = ...
    computeFeatureResponseVectors( inputTimeSeries, nLags, horizon)

% computeFeatureResponseVectors: Produce arrays of feature and response
% vectors from a time-series of values

% INPUTS
% inputTimeSeries: [time series length x 1] of values
% nLags:           No. of lags to include in feature vector (or a vector of
% lag indices)

% horizon:         Legnth of horizon to include as output

% OUTPUTS
% featureVectors: [nLags x nObservations], matrix of feature vectors
% responseVectors: [horizon x nObservations], matrix of response vectors

% nObserverations is determined from the length of the original time-series

% Convert to column vector
inputTimeSeries = inputTimeSeries(:);

% Check for invalid values:
if nLags <= 0, error('nLags must be postive'); end
if ~isWholeNumber(nLags), error('nLags must be an integer or vector'); end
if horizon <= 0, error('horizon must be postive'); end
if ~isWholeNumber(horizon), error('horizon must be an integer'); end

timeSeriesLength = length(inputTimeSeries);

%% Determine the appropriate indices
if length(nLags) == 1
    nObservations = timeSeriesLength - nLags - horizon + 1;
    maxLag = nLags;
else
    nObservations = timeSeriesLength - max(nLags) - horizon + 1;
    [maxLag, maxIdx] = max(nLags);
    if maxIdx ~= 1
        error('Put largest lags first (chronologically)');
    end
end

if nObservations <= 0, error('Insufficient Data'); end

lagIndices = repmat(1:maxLag, [nObservations, 1]) + ...
    repmat((0:(nObservations-1))', [1, maxLag]);

responseIndices = repmat(maxLag + (1:horizon), [nObservations, 1]) + ...
    repmat((0:(nObservations-1))', [1, horizon]);

if max(responseIndices(:)) ~= timeSeriesLength
    error('Problem with extracting indices');
end

% Down-select the desired lags if we have a vector of lag indices
if length(nLags) > 1
    lagIndices = lagIndices(:, end-nLags+1);
else
    %lagIndices = fliplr(lagIndices);
end

featureVectors = inputTimeSeries(lagIndices)';
responseVectors = inputTimeSeries(responseIndices)';

end
