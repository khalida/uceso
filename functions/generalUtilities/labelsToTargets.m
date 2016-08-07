function [ targetVectors, labels ] = labelsToTargets( vectorOfLabels )
% labelsToTargets: Convert a vector of labels into a matrix of target vecs

%% INPUTS:
% vectorOfLabels: [nObservatins x 1] vector of labels

%% OUTPUTS:
% targetVectors:  [nObservations x nLabels] matrix of target vectors
% labels:         [nLabels x 1] vector of label values

labels = unique(vectorOfLabels);
nLabels = length(labels);
nObservations = size(vectorOfLabels, 1);
targetVectors = zeros(nObservations, nLabels);

for ii = 1:nLabels
    targetVectors(:, ii) = (vectorOfLabels == labels(ii));
end

end

