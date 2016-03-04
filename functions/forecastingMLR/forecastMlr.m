% file: forecastMlr.m
% auth: Khalid Abdulla
% date: 19/02/2016
% brief: Given a trained random forest and new inputs for a fcast origin
    % create a new forecast.


function [ forecast ] = forecastMlr( model, demand, ~)

% INPUT:
% model: Coefficients of MLR model
% demand: input data [nInputs x nObservations]
% trainControl: structure of train control parameters

% OUPUT:
% forecast: output forecast [nResponses x nObservations]

nFeatures = size(model, 1);
if nFeatures ~= size(demand, 1)
    error ('MLR forecast error: wrong number of features');
end

forecast = demand'*model;

end