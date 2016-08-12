% file: trainFfnnMultipleStarts.m
% auth: Khalid Abdulla
% date: 25/02/2016
% brief: run trainFfnn multiple times and return best performing model
            % based on hold-out set

function bestModel = trainFfnnMultiInit(cfg, featVecs, respVecs)

%% INPUTS:
% cfg:      Structure of running options
% featVecs: Matrix of training inputs [nFeat x nObs]
% respVecs: Matrix of targets [nResp x nObs]

%% OUTPUTS:
% bestModel: MATLAB trained NN object (best from multiple initializations)

%% Divide data for training and testing
nObs = size(featVecs,2);
nObsTrain = floor(nObs*cfg.fc.trainRatio);
nObsVal = nObs - nObsTrain;
idxs = randperm(nObs);
idxsTrain = idxs(1:nObsTrain);
idxsVal = idxs(nObsTrain+(1:nObsVal));
featVecsTrain = featVecs(:,idxsTrain);
respVecsTrain = respVecs(:,idxsTrain);
featVecsVal = featVecs(:,idxsVal);
respVecsVal = respVecs(:,idxsVal);


%% Train multiple networks and evaluate performances
performance = zeros(cfg.fc.nStart, 1);
allNets = cell(cfg.fc.nStart, 1);
modelResponses = cell(cfg.fc.nStart, 1);

h = waitbar(0, 'Running trainFfnnMultiInit');
for iStart = 1:cfg.fc.nStart
    waitbar(iStart/cfg.fc.nStart, h);
    allNets{iStart} = trainFfnn(cfg, featVecsTrain, respVecsTrain);
    
    modelResponses{iStart} = forecastFfnn(cfg, allNets{iStart},...
        featVecsVal);
    
    performance(iStart) = mean(mse(respVecsVal, ...
        modelResponses{iStart}, 2));
end
delete(h);

[~, idxBest] = min(performance);

%% Output performance of each model if difference is > threshold
percentageDifference = (max(performance) - min(performance)) / ...
    min(performance);

if percentageDifference > cfg.fc.perfDiffThresh
    
    disp(['Percentage Difference: ' num2str(100*percentageDifference)...
        '. Performances: ' num2str(performance')]);
end

bestModel = allNets{idxBest};

end
