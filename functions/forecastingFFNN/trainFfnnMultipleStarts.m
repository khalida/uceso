% file: trainFfnnMultipleStarts.m
% auth: Khalid Abdulla
% date: 06/04/2016
% brief: run trainFfnn multiple times and return best performing model
% based on held-out set

function model = trainFfnnMultipleStarts( cfg, demand )

%% INPUTS
% cfg:      Configuration structure including train control parameters
% demand:   Time-history of demands on which to train [nObsTrain x 1]


%% OUTPUTS
% model:    Best NN found


%% Get Data formated for NN training
[ featVecs, respVecs ] = computeFeatureResponseVectors( demand, ...
    cfg.fc.nLags, cfg.sim.horizon);
% featVecs: [nLags x nObs]
% respVecs: [horizon x nObs]


%% Divide Data into training and testing sets
nObs = size(featVecs,2);
nObsTrain = floor(nObs*cfg.fc.trainRatio);
nObsVal = nObs - nObsTrain;
if cfg.fc.randTrainIdx
    idxs = randperm(nObs);
else
    idxs = 1:nObs;
end
idxsTrain = idxs(1:nObsTrain);
idxsVal = idxs(nObsTrain+(1:nObsVal));
featVecsTrain = featVecs(:,idxsTrain);
respVecsTrain = respVecs(:,idxsTrain);
featVecsVal = featVecs(:,idxsVal);
respVecsVal = respVecs(:,idxsVal);


%% Train multiple networks and evaluate performances
performance = zeros(cfg.fc.nStart, 1);
allModels = cell(cfg.fc.nStart, 1);
allResponses = cell(cfg.fc.nStart, 1);

for iStart = 1:cfg.fc.nStart
    allModels{iStart} = trainFfnn(cfg, featVecsTrain, respVecsTrain);
    allResponses{iStart} = allModels{iStart}(featVecsVal);
    
    performance(iStart) = mean(mse(respVecsVal(...
        1:cfg.fc.minimizeOverFirst, :), allResponses{iStart}(...
        1:cfg.fc.minimizeOverFirst, :)), 2);
end

[~, idxBest] = min(performance);


%% Output performance of each model if difference is > threshold
percentageDiff = (max(performance) - min(performance)) / min(performance);

if percentageDiff > cfg.fc.perfDiffThresh
    
    disp(['Percentage Difference: ' num2str(100*percentageDiff)...
        '. Performances: ' num2str(performance')]);
end

model = allModels{idxBest};

end
