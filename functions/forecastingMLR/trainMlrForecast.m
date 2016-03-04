% file: trainMlrForecast.m
% auth: Khalid Abdulla
% date: 19/02/2016
% brief: Train Multiple Linear Regression Forecast Model

function model = trainMlrForecast( demand, trainControl )

% INPUTS
% demand:       is the time-history of demands on which to train the model
%                divided into training and CV as required
% trainControl: structure of train control parameters

% OUTPUTS
% model:           trained random forest object

% Produce data formated for MLR training
[ featureVectors, responseVectors ] = ...
    computeFeatureResponseVectors( demand, trainControl.nLags, ...
    trainControl.horizon);

% Use normal equations to solve for model coefficients (Beta)
model = featureVectors' \ responseVectors';

end