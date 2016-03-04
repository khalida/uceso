% file: assessVsnn.m
% auth: Khalid Abdulla
% date: 26/02/2016
% brief: Given a variable-selected NN and a test demand time-series return
            % the MSE on the new test-set.

function [ mseTest ] = assessVsnn( net, demand, ~)

% INPUT:
% net: MATLAB trained neural network object
% demand: input data time-series of demand

% OUPUT:
% mse: average mse on the testing data-set

% Extract best (selected) lags, NB; this will be a vector of lags, starting
% from the largest (most distant past).
nLags = net.userdata.bestLags;
horizon = net.output.size;

% Find the feature vectors, and test response vectors
[featureVectors, responseVectors] = computeFeatureResponseVectors(...
    demand, nLags, horizon);

mseTest = mse(responseVectors, net(featureVectors));

end
