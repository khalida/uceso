%% Simple case-based unit test of 'generateForecastFreeController'
% very much NOT exhaustive

% Instance data / config settings:
cfg.fc.modelType = 'FFNN';
cfg.fc.trainRatio = 0.8;
cfg.fc.nStart = 3;
cfg.fc.perfDiffThresh = 0.05;
cfg.fc.nNodes = 20;
cfg.fc.suppressOutput = true;
cfg.fc.maxTime = 10*60;
nObs = 10000;
thresh = 0.1;

exampleFunc = @(x) x(1,:).^2 - 3*x(2,:).^0.5 + 5*x(3,:).^3;
featVecsTrain = rand(3, nObs);
respVecsTrain = exampleFunc(featVecsTrain);

% Train model
model = generateForecastFreeController(cfg, featVecsTrain, respVecsTrain);

% Test performance
featVecsTest = rand(3, nObs);
respVecsTest = exampleFunc(featVecsTest);
modelRespVecsTest = model(featVecsTest);
pass = (rms(respVecsTest - modelRespVecsTest)/rms(respVecsTest)) < thresh;
if pass
    disp('test_generateForecastFreeController PASSED!');
else
    error('test_generateForecastFreeController FAILED');
end
