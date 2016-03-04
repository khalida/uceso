% file: forecastRandomForest.m
% auth: Khalid Abdulla
% date: 16/01/2016
% brief: Given a trained random forest, and new inputs for a fcast origin,
%       create a new forecast (recusrively).

function [ forecast ] = forecastRandomForest( rf, demand, trainControl )

% INPUT:
% rf: MATLAB CompactTreeBagger object
% demand: input data [nInputs x nObservations]
% trainControl: structure of train controller parameters

% OUPUT:
% forecast: output forecast [nResponses x nObservations]

nLags = trainControl.nLags;
nObservations = size(demand, 2);
X = demand((end - nLags + 1):end, :);
forecast = zeros(trainControl.horizon, nObservations);

for idx = 1:trainControl.horizon
    % Produce a 1-step forecast
    forecast(idx, :) = rf.predict(X');
    
    % Roll the data on one time-step
    X(1:(nLags-1), :) = X(2:nLags, :);
    
    % And place the newly forecasted value one time-step into the future
    X(nLags, :) = forecast(idx, :);
end

end