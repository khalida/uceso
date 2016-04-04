function [ model ] = trainRnn(ts, trainControl)

%trainRnn Produce recursive neural network model based on:

%% INPUT
% ts:           time series to be forecast
% trainControl: structure of training options

%% OUTPUT
% model:        matlab layer recurrent neural network model

[featVecs, respVecs] = computeFeatureResponseVectors(ts, 1, ...
    trainControl.horizon);

t = con2seq(respVecs);
x = con2seq(featVecs);

model = layrecnet(1:trainControl.nRecursive,trainControl.nNodes);

% Prepare data for training:
[X,Xi,Ai,T] = preparets(model,x,t);

% Train network on teh data (NB: should split into train/test and do
% multi-start)
model = train(model,X,T,Xi,Ai);
model.userdata.Ai = Ai;
model.userdata.xi = xi;

end

