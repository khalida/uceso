% file: trainRandomForestForecast.m
% auth: Khalid Abdulla
% date: 16/01/2016
% brief: Train Random Forest Forecast Model

function rf = trainRandomForestForecast( demand, trainControl )

% INPUTS
% demand:       is the time-history of demands on which to train the model
%                divided into training and CV as required
% trainControl: structure of train control parameters

% OUTPUTS
% rf:           trained random forest object

% trainRatio = trainControl.trainRatio;

% Produce data formated for NN training
[ featureVectors, responseVectors ] = ...
    computeFeatureResponseVectors( demand, trainControl.nLags, ...
    trainControl.horizon);

responseVectors = responseVectors(1, :);

rf = TreeBagger(trainControl.nNodes, featureVectors', responseVectors', ...
    'method', 'regression', 'OOBPred', 'On').compact;

end