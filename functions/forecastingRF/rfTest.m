function tests = rfTest
%ffnnTest Test suite for FFNN forecasting functions
rng(42);
tests = functiontests(localfunctions);
end

function testTrainRandomForestForecast(testCase)
% Test trainRandomForestForecast

% Use simple sinusoidal prediction problem, rf to predict one-step ahead
trainControl.suppressOutput = false;
trainControl.nNodes = 1000;
trainControl.horizon = 10;
trainControl.nLags = 10;
trainControl.trainRatio = 0.9;
trainControl.performanceDifferenceThreshold = 0.01;

testMultiplier = 5;

% Produce sinusoidal series:
timeIndexesTrain = linspace(0, 2*pi*testMultiplier,...
    trainControl.horizon*testMultiplier+1);

exampleTimeSeries = sin(timeIndexesTrain);

outputRf = trainRandomForestForecast( exampleTimeSeries, ...
    trainControl);

testInput = exampleTimeSeries((end-2*trainControl.nLags+1):...
    (end-1*trainControl.nLags));
testOutput = exampleTimeSeries((end-1*trainControl.nLags+1):end);

actSolution = outputRf.predict(testInput);
expSolution = testOutput(1);

verifyEqual(testCase,actSolution,expSolution, 'AbsTol', 2e-2);

end

function testForecastRandomForest(testCase)
% Test forecastRandomForest

% Check that it works for a simple forecasting problem

% Running options:
trainControl.nLags = 20;
trainControl.horizon = trainControl.nLags;
samplingInterval = (2*pi)/trainControl.nLags;
nPeriods = 100;
trainRatio = 0.75;
noiseMultiplier = 0.25;

% Prepare data:
timeSamples = (0:samplingInterval:(2*pi*nPeriods))';
periodLength = (2*pi)/samplingInterval;
nSamples = length(timeSamples);
nTrainIdxs = floor(trainRatio*nSamples);
trainIdxs = 1:nTrainIdxs;
testIdxs = (nTrainIdxs+1):nSamples;

dataValues = sin(timeSamples) + randn(size(timeSamples)).*noiseMultiplier;
trainValues = dataValues(trainIdxs);
testValues = dataValues(testIdxs);

trainControl.suppressOutput = false;
trainControl.nNodes = 100;
trainControl.mseEpochs = 1000;

rf = trainRandomForestForecast( trainValues, trainControl);

actSolution = forecastRandomForest(rf, trainValues, trainControl);
expSolution = sin(timeSamples(testIdxs(1:periodLength)));
figure();
plot([testValues(1:periodLength,:), actSolution, expSolution]);
legend('test values', 'test prediction', 'test without noise');

verifyEqual(testCase,actSolution,expSolution, 'AbsTol', noiseMultiplier);

end

% function setupOnce(testCase)  % do not change function name
% % set a new path, for example
% end
%
% function teardownOnce(testCase)  % do not change function name
% % change back to original path, for example
% end
%
% function setup(testCase)  % do not change function name
% % open a figure, for example
% end
%
% function teardown(testCase)  % do not change function name
% % close figure, for example
% end