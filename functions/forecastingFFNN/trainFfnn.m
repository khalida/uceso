% file: trainFfnn.m
% auth: Khalid Abdulla
% date: 06/04/2016
% brief: Train a single FFNN forecast model (based on features/responses)

function thisNet = trainFfnn(cfg,  featVecs, respVecs)

%% INPUTS:
% cfg:              structure of parameters (including training control)
% featVecs:         matrix of training inputs [nFeats x nObs]
% respVecs:         matrix of targets [nResp x nObs]
% optionalFeats:    [nFeat x 1] array of features which are optional to
% include.

%% OUTPUTS:
% model:    MATLAB trained neural network object

%% Divide data for training and variable selection
thisNet = fitnet(cfg.fc.nNodes, 'trainscg');

% Silence training GUIs/output
thisNet.trainParam.showWindow = false;
if cfg.fc.suppressOutput
    thisNet.trainParam.showCommandLine = false;
end

% Set maximum running time (sec)
thisNet.trainParam.time = cfg.fc.maxTime;

%% Train network
[thisNet, tr] = train(thisNet,featVecs,respVecs);

% Save various parameters along with the neural network model object
thisNet.userdata.nObs = size(featVecs,2);
thisNet.userdata.finalPerf_ts = tr.best_tperf;
thisNet.userdata.trainIndL = length(tr.trainInd(:));
thisNet.userdata.trainStop = tr.stop;

if strcmp(tr.stop, 'Maximum time elapsed.')
    disp('Warning: FFNN Training halted due to maximum time.');
end

end
