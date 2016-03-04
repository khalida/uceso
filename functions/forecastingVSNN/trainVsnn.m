% file: trainVsnn.m
% auth: Khalid Abdulla
% date: 25/02/2016
% brief: create neural network by sequentially selecting which lags to
% include (for a single initialisation)

function bestNet = trainVsnn( demand, trainControl )

% INPUTS
% demand:       time-history of demands on which to train [nObs x 1]
% trainControl: structure of train control parameters

% OUTPUTS
% bestNet:      best NN found

%% Set default values for optional train control pars
trainControl = setDefaultValues(trainControl,...
    {'nStart', 3, 'minimiseOverFirst', trainControl.horizon,...
    'suppressOutput', true, 'nNodes', 50, 'maxTime', 60*10});

%% Parse trainControl object:
trainRatio = trainControl.trainRatio;
minimiseOverFirst = trainControl.minimiseOverFirst;
nLags = trainControl.nLags;
horizon = trainControl.horizon;

%% Cycle through all possible lags, deciding which to include
bestPerf = inf;
bestLags = [];

for eachLag = 1:nLags
    disp(['Lag ' num2str(eachLag) ' of ' num2str(nLags)]);
    theseLags = [eachLag bestLags];
    
    %% Produce data formated for NN training
    [ featureVectors, responseVectors ] = ...
        computeFeatureResponseVectors( demand, theseLags, horizon);
        
    %% Divide data for training and validation (variable selection)
    nObservations = size(featureVectors,2);
    nObservationsTrain = floor(nObservations*trainRatio);
    nObservationsTest = nObservations - nObservationsTrain;
    idxs = randperm(nObservations);
    idxsTrain = idxs(1:nObservationsTrain);
    idxsTest = idxs(nObservationsTrain+(1:nObservationsTest));
    featureVectorsTrain = featureVectors(:,idxsTrain);
    responseVectorsTrain = responseVectors(:,idxsTrain);
    featureVectorsTest = featureVectors(:,idxsTest);
    responseVectorsTest = responseVectors(:,idxsTest);
        
    %% Train NN with these lags, and evaluate performance
    thisNet = trainFfnn( featureVectorsTrain, responseVectorsTrain, ...
        trainControl);
    
    testResp = forecastFfnn(thisNet, featureVectorsTest, trainControl);
    
    thisPerf = mse(responseVectorsTest(1:minimiseOverFirst, :), ....
        testResp(1:minimiseOverFirst, :), 2);
    
    if thisPerf < bestPerf
        bestPerf = thisPerf;
        bestLags = theseLags;
        bestNet = thisNet;
        bestNet.userdata.bestLags = bestLags;
    end
end

end
