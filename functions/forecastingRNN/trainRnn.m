function [ model ] = trainRnn(cfg, ts)

%trainRnn Produce recursive neural network model based on:

%% INPUT
% cfg:      structure of parameters
% ts:       time series to be forecast

%% OUTPUT
% model:        matlab layer recurrent neural network model

[featVecs, respVecs] = computeFeatureResponseVectors(ts, 1, ...
    cfg.sim.horizon);

t = con2seq(respVecs);
x = con2seq(featVecs);

model = layrecnet(1:cfg.fc.nRecursive, cfg.fc.nNodes);

% Prepare data for training:
[X,Xi,Ai,T] = preparets(model,x,t);

% Train network on teh data (NB: should split into train/test and do
% multi-start)
model = train(model,X,T,Xi,Ai);
model.userdata.Ai = Ai;
model.userdata.xi = xi;

end

