% file: assessFfnn.m
% auth: Khalid Abdulla
% date: 26/02/2016
% brief: Given a neural network test time-series, assess the test MSE


function [ mseTest, rmsTest ] = assessFfnn(~, net, demand)

% INPUT:
% net: MATLAB trained neural network object
% demand: input data time-series

% OUPUT:
% mse: Average MSE over test data set
nLags = net.input.size;
horizon = net.output.size;
[featureVectors, responseVectors] = computeFeatureResponseVectors( ...
    demand, nLags, horizon);

testFc = net(featureVectors);
mseTest = mse(responseVectors, testFc);
rmsTest = rms(testFc(:));

end
