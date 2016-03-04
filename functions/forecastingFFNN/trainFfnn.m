% file: trainFfnn.m
% auth: Khalid Abdulla
% date: 25/02/2016
% brief: Train a single FFNN forecast model.

function outputNet = trainFfnn( featureVectors, responseVectors, ...
    trainControl)

% INPUTS:
% featureVectors: matrix of training inputs [nFeatures x nObservations]
% responseVectors: matrix of targets [nResponses x nObservations]
% trainControl: structure of training control parameters

% OUTPUTS:
% outputNet: MATLAB trained neural network object

%% Set default values for optional train control pars
trainControl = setDefaultValues(trainControl, {'maxTime', 60*10});

% Parse the trainControl structure
hiddenLayerSize = trainControl.nNodes;
suppressOutput = trainControl.suppressOutput;
maxTime = trainControl.maxTime;

% Create the network (using all defaults)
outputNet = fitnet(hiddenLayerSize, 'trainscg');
% outputNet = fitnet(hiddenLayerSize);

% Silence the usual training guis/output
outputNet.trainParam.showWindow = false;
if suppressOutput
    outputNet.trainParam.showCommandLine = false;
end
outputNet.trainParam.time = maxTime;

%% Train network
[outputNet, tr] = train(outputNet,featureVectors,responseVectors);

% Store various parameters along with the neural network object
outputNet.userdata.nObs = size(featureVectors,2);
outputNet.userdata.finalPerf_ts = tr.best_tperf;
outputNet.userdata.trainIndL = length(tr.trainInd(:));
outputNet.userdata.trainStop = tr.stop;

if strcmp(tr.stop, 'Maximum time elapsed.')
    disp('Warning: FFNN Training halted due to maximum time.');
end

end
