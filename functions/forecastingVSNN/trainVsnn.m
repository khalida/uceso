% file: trainVsnn.m
% auth: Khalid Abdulla
% date: 25/02/2016
% brief: create neural network by sequentially selecting which lags to
% include (for a single initialisation)

function bestNet = trainVsnn(cfg, demand)

% INPUTS
% cfg:          structure of parameters
% demand:       time-history of demands on which to train [nObs x 1]

% OUTPUTS
% bestNet:      best NN found

%% Parse trainControl object:
trainRatio = cfg.fc.trainRatio;
minimizeOverFirst = cfg.fc.minimizeOverFirst;
nLags = cfg.fc.nLags;
horizon = cfg.sim.horizon;

%% Cycle through all possible lags, deciding which to include
bestPerf = inf;
bestLags = [];

for eachLag = 1:nLags
    disp(['Lag ' num2str(eachLag) ' of ' num2str(nLags)]);
    theseLags = [eachLag bestLags];
    
    %% Produce data formated for NN training
    [ featVecs, respVecs ] = ...
        computeFeatureResponseVectors( demand, theseLags, horizon);
        
    %% Divide data for training and validation (variable selection)
    nObs = size(featVecs,2);
    nObsTrain = floor(nObs*trainRatio);
    nObsVal = nObs - nObsTrain;
    idxs = randperm(nObs);
    idxsTrain = idxs(1:nObsTrain);
    idxsTest = idxs(nObsTrain+(1:nObsVal));
    featVecsTrain = featVecs(:,idxsTrain);
    respVecsTrain = respVecs(:,idxsTrain);
    featVecsVal = featVecs(:,idxsTest);
    respVecsVal = respVecs(:,idxsTest);
        
    %% Train NN with these lags, and evaluate performance
    thisNet = trainFfnn(cfg, featVecsTrain, respVecsTrain);
    testResp = forecastFfnn(cfg, thisNet, featVecsVal);
    
    thisPerf = mse(respVecsVal(1:minimizeOverFirst, :), ....
        testResp(1:minimizeOverFirst, :), 2);
    
    if thisPerf < bestPerf
        bestPerf = thisPerf;
        bestLags = theseLags;
        bestNet = thisNet;
        bestNet.userdata.bestLags = bestLags;
    end
end

end
