% file: trainMlrForecast.m
% auth: Khalid Abdulla
% date: 19/02/2016
% brief: Train Multiple Linear Regression Forecast Model

function model = trainMlrForecast(cfg, demand)

% INPUTS
% cfg:          structure of parameters
% demand:       is the time-history of demands on which to train the model
%                divided into training and CV as required

% OUTPUTS
% model:           trained random forest object

% Produce data formated for MLR training
[ featureVectors, responseVectors ] = ...
    computeFeatureResponseVectors( demand, cfg.fc.nLags,cfg.sim.horizon );

% Use normal equations to solve for model coefficients (Beta)
model = featureVectors' \ responseVectors';

end