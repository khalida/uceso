% file: forecastRnn.m
% auth: Khalid Abdulla
% date: 4/4/2016
% brief: Given a neural network and some new inputs for a fcast origin,
%       create a new forecast.

function [ forecast, net ] = forecastRnn(cfg, net, demand)

% INPUT:
% cfg: structure of train controlling parameters etc.
% net: MATLAB trained recursive neural network object
% demand: input data [nInputs x nObservations]

% OUPUT:
% forecast: output forecast [nResponses x nObservations]
% net: updated rnn model (with updated states)

cfg; %#ok<VUNUS>

nLags = net.inputs{1}.size;
x = demand((end - nLags + 1):end, :);

[forecast, net.userdata.Xi, net.userdata.Ai] = ...
    net(x, net.userdata.Xi, net.userdata.Ai);

end
