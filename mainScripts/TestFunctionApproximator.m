%% TestFunctionApproximator.m
% This script provides a frame-work for seeing how well arbitrary
% matlab functions can be approximated using MATLAB NN implementation.

%% Fcn to be replaced has the form:
% [response] = functionXX(featVec);

% INPUTS:
% featVec:      [nObs x nFeat]

% OUTPUTS:
% response:     [nObs x nResp]

%% 0) Tidy up & Load functions
clearvars; close all; clc;
tic;
rng(42);
LoadFunctions;

%% 1) Running options (set locally)
functionName = @function02;
nObservations = 100000;
trainRatio = 0.8;
nFeat = 98;

% Options for the neural network:
cfg.fc.suppressOutput = false;
cfg.fc.maxTime = 20*60;
cfg.fc.nNodes = [nFeat nFeat];

%% 2) Generate feature vectors and responses
featVecs = randn(nObservations, nFeat);
respVecs = functionName(featVecs);

%% 3) Train and evaluate NN mapping approximator
% Separate data into train/test sets
nTrain = floor(trainRatio*nObservations);
trainIdxs = 1:nTrain;
testIdxs = (nTrain + 1):nObservations;

trainFeatVecs = featVecs(trainIdxs, :);
trainRespVecs = respVecs(trainIdxs, :);

testFeatVecs = featVecs(testIdxs, :);
testRespVecs = respVecs(testIdxs, :);

% Try regression network:
modelReg = trainFfnn(cfg,  trainFeatVecs', trainRespVecs');
figure();
scatter(testRespVecs, modelReg(testFeatVecs'));
xlabel('Target Response');
ylabel('NN Response');
grid on; refline(1, 0);
title('Performance of Regression Network');

disp(['Total time taken: ' num2str(toc)]);
