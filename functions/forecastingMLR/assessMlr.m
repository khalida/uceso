% file: assessMlr.m
% auth: Khalid Abdulla
% date: 26/02/2016
% brief: Given a trained MLR forcast and new time-series output the mean
        % test MSE

function [ mseTest ] = assessMlr( model, demand, ~)

% INPUT:
% model: Coefficients of MLR model
% demand: input data (time-series)

% OUPUT:
% testMse: Mean MSE on the test data-set

nLags = size(model, 1);
horizon = size(model, 2);

[featureVectors, responseVectors] = computeFeatureResponseVectors(...
    demand, nLags, horizon);

mseTest = mse(responseVectors, (featureVectors'*model)');

end