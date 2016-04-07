% file: trainRandomForestForecast.m
% auth: Khalid Abdulla
% date: 06/04/2016
% brief: Train Random Forest Forecast Model

function model = trainRandomForestForecast( cfg, demand )

%% INPUTS
% cfg:      Structure containing all config options (including training)
% demand:   Time-history of demand on which to train the model

%% OUTPUTS
% model:    Trained random forest object

% Produce data formated for RF training
[ featVecs, respVecs ] = computeFeatureResponseVectors( demand,...
    cfg.fc.nLags, cfg.sim.horizon);

% For random forest we can only regress a single output at a time
respVecs = respVecs(1, :);

model = TreeBagger(cfg.fc.nNodes, featVecs', respVecs', ...
    'method', 'regression', 'OOBPred', 'On').compact;

end