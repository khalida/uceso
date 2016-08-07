function [ outputVec ] = function01( inputVec )
%function01: Mapping to test MLP against

% INPUTS:
% inputVec; [nObs x nFeat]

% OUTPUTS:
% outputVec; [nObs x nResp]


nObs = size(inputVec, 1);
nFeat = size(inputVec, 2);

nResp = 1;
outputVec = zeros(nObs, nResp);

outputVec(:, 1) = sum(inputVec, 2);

end

