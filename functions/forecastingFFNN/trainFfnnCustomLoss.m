% file: trainFfnn.m
% auth: Khalid Abdulla
% date: 21/10/2015
% brief: Train a single FFNN forecast model, to a given loss function

function modelOut = trainFfnnCustomLoss(cfg, featVecs, respVecs,...
    modelIn, lossType)

% INPUTS:
% cfg:      running options
% featVecs: matrix of training inputs [nFeatures x nObservations]
% respVecs: matrix of targets [nResponses x nObservations]
% modelIn:  input network (already trained to minimise MSE)
% lossType: handle to the loss function

% OUTPUTS:
% modelOut: MATLAB trained neural network object

% Parse the trainControl structure

%% De-parameterize the loss function
if strcmp('lossExact', func2str(lossType))
    runSettings.battery = getBatteryObject(cfg, [], data);   
    runSettings.cfg = cfg;
    lossType = @(t, y) lossExact(t, y, runSettings);
end

%% Model training according to chosen lossType
% Set the loss function
modelIn.performFcn = 'lossGeneral';

if ~suppressOutput
    modelIn.performParam.lossGeneral = ...
        @(t, x)lossType(t(1:cfg.fc.minimizeOverFirst, :), ...
        x(1:cfg.fc.minimizeOverFirst, :));
else
    evalc(['modelIn.performParam.lossGeneral = '...
        '@(t, x)lossType(t(1:cfg.fc.minimizeOverFirst, :),' ...
        'x(1:cfg.fc.minimizeOverFirst, :));']);
end

modelIn.userdata.lossType = func2str(lossType);
modelIn.userdata.minimiseOverFirst = trainControl.minimiseOverFirst;

%% Train Network (further)
nObservations = size(featVecs, 2);

if isfield(trainControl, 'batchSize')
    nBatch = ceil(nObservations/cfg.fc.batchSize);
    batchIdxs = cell(nBatch, 1);
    for iBatch = 1:nBatch
        batchIdxs{iBatch} = ...
            (((iBatch-1)*cfg.fc.batchSize)+1):...
            min(((iBatch*cfg.fc.batchSize)), nObservations);
    end
else
    nBatch = 1;
    batchIdxs = cell(1, 1);
    batchIdxs{1} = 1:nObservations;
end

% TODO: Limiting training time overall (NB: will get sub-optimal networks)
modelIn.trainParam.time = (trainControl.maxTime*60)/nBatch;
modelIn.trainParam.epochs = trainControl.maxEpochs;

for iBatch = 1:nBatch
    batchFeature = featVecs(:, batchIdxs{iBatch});
    batchResponse = respVecs(:, batchIdxs{iBatch});
    
    if(~suppressOutput)
        [modelOut,tr] = train(modelIn,batchFeature,...
            batchResponse, nn7);
    else
        evalc(['[modelIn,tr] = train(modelIn, batchFeature,' ...
            'batchResponse, nn7);']);
    end
end

% Store various parameters along with the neural network
modelOut.userdata.nObs = size(featureVectorTrain,2);
modelOut.userdata.finalPerf_ts = tr.best_tperf;
modelOut.userdata.trainIndL = length(tr.trainInd(:));
modelOut.userdata.trainStop = tr.stop;

if strcmp(tr.stop, 'Maximum time elapsed.')
    disp(['Warning: FFNN Training halted due to maximum time. '...
        'Loss type: ' func2str(lossType)]);
end

end
