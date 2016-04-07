% file: forecastFfnn.m
% auth: Khalid Abdulla
% date: 21/10/2015
% brief: Given a neural network and some new inputs for a fcast origin,
%       create a new forecast.

function [ forecast ] = forecastFfnn(cfg, trainedModel, featVecs)

%% INPUT:
% cfg:          Structure of running options
% trainedModel: Trained forecasting model
% featVecs:     Input Data [nFeat x nObs]

%% OUPUT:
% forecast:     Output forecast [nResponses x nObs]

nLags = trainedModel.inputs{1}.size;
if nLags ~= cfg.fc.nLags
    error('Model with incorrect No. of lags found');
end
x = featVecs((end - nLags + 1):end, :);
forecast = trainedModel(x);

end
