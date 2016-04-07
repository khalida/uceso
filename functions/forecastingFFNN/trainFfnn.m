% file: trainFfnn.m
% auth: Khalid Abdulla
% date: 06/04/2016
% brief: Train a single FFNN forecast model (based on features/responses)

function model = trainFfnn(cfg,  featVecs, respVecs)

%% INPUTS:
% cfg:      structure of parameters (including training control)
% featVecs: matrix of training inputs [nFeats x nObs]
% respVecs: matrix of targets [nResp x nObs]

%% OUTPUTS:
% model:    MATLAB trained neural network object


%% Create the network (using all defaults, and scaled conj grad desc.)
model = fitnet(cfg.fc.nNodes, 'trainscg');

% Silence training GUIs/output
model.trainParam.showWindow = false;
if cfg.fc.suppressOutput
    model.trainParam.showCommandLine = false;
end

% Set maximum running time (sec)
model.trainParam.time = cfg.fc.maxTime;


%% Train network
[model, tr] = train(model,featVecs,respVecs);

% Save various parameters along with the neural network model object
model.userdata.nObs = size(featVecs,2);
model.userdata.finalPerf_ts = tr.best_tperf;
model.userdata.trainIndL = length(tr.trainInd(:));
model.userdata.trainStop = tr.stop;

if strcmp(tr.stop, 'Maximum time elapsed.')
    disp('Warning: FFNN Training halted due to maximum time.');
end

end
