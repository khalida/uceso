function net = trainClassifierNN(cfg, featureVectors, responseVectors)
% trainClassifierNN: Train classifier Neural Net
% Script generated by Neural Pattern Recognition app

%% INPUTS:
% featureVectors;   [nObservations x nFeatures] input data
% responseVectors;  [nObservations x nClasses] matrix of boolean class lbls

% Solve a Pattern Recognition Problem with a Neural Network
% Script generated by Neural Pattern Recognition app
% Created 26-Jul-2016 21:22:50
%
% This script assumes these variables are defined:
%
%   trainFeatVecs - input data.
%   trainRespVecs - target data.

x = featureVectors';
t = responseVectors';

% Choose a Training Function
% For a list of all training functions type: help nntrain
% 'trainlm' is usually fastest.
% 'trainbr' takes longer but may be better for challenging problems.
% 'trainscg' uses less memory. Suitable in low memory situations.
trainFcn = 'trainscg'; % Scaled conjugate gradient backpropagation.

% Create a Pattern Recognition Network
hiddenLayerSize = cfg.fc.nNodes;
net = patternnet(hiddenLayerSize, trainFcn);

% Choose Input and Output Pre/Post-Processing Functions
% For a list of all processing functions type: help nnprocess
net.input.processFcns = {'removeconstantrows','mapminmax'};
net.output.processFcns = {'removeconstantrows','mapminmax'};

% Setup Division of Data for Training, Validation, Testing
% For a list of all data division functions type: help nndivide
net.divideFcn = 'dividerand';  % Divide data randomly
net.divideMode = 'sample';  % Divide up every sample
net.divideParam.trainRatio = 70/100;
net.divideParam.valRatio = 15/100;
net.divideParam.testRatio = 15/100;

% Choose a Performance Function
% For a list of all performance functions type: help nnperformance
net.performFcn = 'crossentropy';  % Cross-Entropy

% Choose Plot Functions
% For a list of all plot functions type: help nnplot
net.plotFcns = {'plotperform','plottrainstate','ploterrhist', ...
    'plotconfusion', 'plotroc'};

% Train the Network
[net,~] = train(net,x,t);

% Test the Network
y = net(x);
%e = gsubtract(t,y);
%performance = perform(net,t,y)
%tind = vec2ind(t);
%yind = vec2ind(y);
%trainPerformance = perform(net,trainTargets,y)
%valPerformance = perform(net,valTargets,y)
%testPerformance = perform(net,testTargets,y)

% View the Network
view(net)

% Plots
% Uncomment these lines to enable various plots.
%figure, plotperform(tr)
%figure, plottrainstate(tr)
%figure, ploterrhist(e)
%figure, plotconfusion(t,y)
figure, plotroc(t,y)

%% NB: I'm reduced to using the matrix-only generated function
% as something not working with NN class for classification?
genFunction(net,[pwd filesep '..' filesep 'functions' filesep ...
    'myNeuralNetworkFunction'], 'MatrixOnly','yes');

end
