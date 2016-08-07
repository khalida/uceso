function [ labelVector ] = targetsToLabels( targets, labels )
% targetsToLabels: Convert a matrix of target vectors into a vector of
                    % label values

%% INPUTS:
% targets: [nObservations x nLabels] matrix of target vectors
% labels:  [nLabels x 1] vector of label values


%% OUTPUTS:
% labelVector: [nObservatins x 1] vector of labels
[~, maxIdxs] = max(targets, [], 2);
labelVector = labels(maxIdxs);

end
