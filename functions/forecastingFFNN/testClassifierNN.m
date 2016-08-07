function [ testRespVecs_hat, performance, percentErrors ] = ...
    testClassifierNN( model, testFeatures, testTargets)

% testClassifierNN: Test the performance of a trained classifier NN

%% INPUTS:
% model:            A trained NN object
% testFeatures:     [nObservations x nFeatures] test data features
% testTargets:      [nObservations x nClasses] target class label vectors

x = testFeatures';
t = testTargets';
% y = model(x);

%% NB: I'm reduced to using the matrix-only generated function
% as something not working with NN class for classification?
y = myNeuralNetworkFunction(x);
testRespVecs_hat = y';

performance = perform(model,t,y);

tind = vec2ind(t);
yind = vec2ind(y);
percentErrors = sum(tind ~= yind)/numel(tind);

end
