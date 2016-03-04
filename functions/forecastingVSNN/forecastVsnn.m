% file: forecastVsnn.m
% auth: Khalid Abdulla
% date: 26/02/2016
% brief: Given a variable-selected NN and some new inputs, 
%       create a new forecast.

function [ forecast ] = forecastVsnn( net, demand, ~ )

% INPUT:
% net: MATLAB trained neural network object
% demand: input data time-series of demand
% trainControl: structure of train controller parameters

% OUPUT:
% forecast: output forecast (time-series of demand)

% Extract best (selected) lags, NB; this will be a vector of lags, starting
% from the largest (most distant past).
nLags = net.userdata.bestLags;
if max(nLags) > length(demand)
    error('Insufficient data provided');
end

featureVector = demand(end+1-nLags);
forecast = net(featureVector);

end
