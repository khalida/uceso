% file: forecastRandomForest.m
% auth: Khalid Abdulla
% date: 16/01/2016
% brief: Given a trained random forest, and new inputs for a fcast origin,
%       create a new forecast (recusrively).

function [ forecast ] = forecastRandomForest(cfg, trainedModel, featVecs)

% INPUT:
% cfg:          Structure of running options
% trainedModel: Trained forecasting model
% featVecs:     Input data [nFeat x nObs]

% OUPUT:
% forecast:     Output forecast [horizon x nObs]

nLags = cfg.fc.nLags;
nObs = size(featVecs, 2);
X = featVecs((end - nLags + 1):end, :);
forecast = zeros(cfg.sim.horizon, nObs);

%% Produce forecasts one-step at a time
for idx = 1:cfg.sim.horizon
    % Produce a 1-step forecast
    forecast(idx, :) = trainedModel.predict(X');
    
    % Roll the data on one time-step
    X(1:(nLags-1), :) = X(2:nLags, :);
    
    % And place the newly forecasted value one time-step into the future
    X(nLags, :) = forecast(idx, :);
end

end