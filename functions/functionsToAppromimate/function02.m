function [ outputVec ] = function02( inputVec )
%function01: Mapping to test MLP against

% INPUTS:
% inputVec; [nObs x nFeat]

% OUTPUTS:
% outputVec; [nObs x nResp]


nObs = size(inputVec, 1);
nFeat = size(inputVec, 2);

nResp = 1;
outputVec = zeros(nObs, nResp);

firstVarPos = (inputVec(:, 1) > 0);
outputVec(firstVarPos, 1) = sum(inputVec(firstVarPos, :), 2);

end

