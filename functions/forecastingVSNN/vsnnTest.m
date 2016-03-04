function tests = ffnnTest
%ffnnTest Test suite for FFNN forecasting functions
rng(666);
tests = functiontests(localfunctions);
end

function testTrainFfnn(testCase)
% Test trainFfnn

% Test against a simple (XOR) logical function, and confirm adequate
% performance:

trainControl.suppressOutput = false;
trainControl.nNodes = 2;
trainControl.minimiseOverFirst = 1;
trainControl.maxTime = 5;
trainControl.maxEpochs = 200;

% Produce example feature vector and response vectors:
featureVectorTrain = randi([0,1], [10000, 2])';
responseVectorTrain = xor(featureVectorTrain(1, :), ...
    featureVectorTrain(2, :));

outputNet = trainFfnn( featureVectorTrain, responseVectorTrain,...
    trainControl);

testInput = [0 0 1 1;
    0 1 0 1];

expSolution = [0 1 1 0];
actSolution = outputNet(testInput);

verifyEqual(testCase,actSolution,expSolution, 'AbsTol', 1e-2);
end

function testForecastFfnn(testCase)
% Test forecastFfnn
% Check that it works for a simple forecasting problem

% Running options:
samplingInterval = (2*pi)/20;
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

[trainFeatureVectors, trainResponseVectors] = ...
    computeFeatureResponseVectors(trainValues,periodLength,periodLength);

trainControl.suppressOutput = false;
trainControl.nNodes = 10;
trainControl.mseEpochs = 1000;
trainControl.minimiseOverFirst = 1;
trainControl.maxTime = 5;
trainControl.maxEpochs = 200;

net = trainFfnn( trainFeatureVectors, trainResponseVectors, ...
    trainControl);

actSolution = forecastFfnn(net, trainValues, trainControl);
expSolution = sin(timeSamples(testIdxs(1:periodLength))); % testValues(1:periodLength, :);

figure();
plot([testValues(1:periodLength,:), actSolution, ...
    sin(timeSamples(testIdxs(1:periodLength)))]);
legend('test values', 'test prediction', 'test without noise');

verifyEqual(testCase,actSolution,expSolution, 'AbsTol', noiseMultiplier);
end

function testTrainFfnnMultipleStarts(testCase)
% Test using a simple sinusoidal prediction problem, and confirm
% performance is improved by running multiple models

trainControl.suppressOutput = false;
trainControl.nNodes = 10;
trainControl.mseEpochs = 100;
trainControl.minimiseOverFirst = 10;
trainControl.maxTime = 10;
trainControl.maxEpochs = 10;

trainControl.horizon = 10;
trainControl.nLags = 10;
trainControl.trainRatio = 0.75;
trainControl.performanceDifferenceThreshold = 0.01;

testMultiplier = 5;

% Produce sinusoidal series to learn from:
timeIndexesTrain = linspace(0, 2*pi*testMultiplier,...
    trainControl.horizon*testMultiplier);
exampleTimeSeries = sin(timeIndexesTrain);

trainControl.nStart = 1;
outputNetSingle = trainFfnnMultipleStarts( exampleTimeSeries,...
    trainControl);

trainControl.nStart = 10;
outputNetMultiple = trainFfnnMultipleStarts( exampleTimeSeries,...
    trainControl );

testInput = exampleTimeSeries((end-trainControl.nLags+1):end)';
testOutput = testInput;

netSingleResponse = outputNetSingle(testInput);
netMultipleResponse = outputNetMultiple(testInput);

errorMultiple= max(abs(netMultipleResponse-testOutput));
errorSingle = max(abs(netSingleResponse-testOutput));

verifyGreaterThan(testCase, errorSingle, errorMultiple);

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