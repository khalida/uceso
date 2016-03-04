function model = generateForecastFreeController(featureVector, ...
    decisionVector, Sim)

% INPUTS:
%   featureVector:  Input data [nFeatures x nObservations]
%   decisionVector: Output data [nDecisions x nObservations]
%   Sim:            Structure containing simulation settings

% OUTPUTS:
%   model:          Trained data-driven model.

trainControl = Sim.trainControl;

nObservations = size(featureVector, 2);
if size(decisionVector, 2) ~= nObservations;
    error('nObservations must be same in feature and decision vectors');
end;

switch Sim.forecastModels
    
    case 'RF'
        
        model.decisionModel = TreeBagger(trainControl.nNodesFF,...
            featureVector', decisionVector(1, :)', 'method',...
            'regression', 'OOBPred', 'On').compact;
        
    case 'FFNN'
        % Separate training and test data:
        nObservationsTrain = floor(nObservations*trainControl.trainRatio);
        nObservationsTest = nObservations - nObservationsTrain;
        
        idxs = randperm(nObservations);
        idxsTrain = idxs(1:nObservationsTrain);
        idxsTest = idxs(nObservationsTrain+(1:nObservationsTest));
        
        featureVectorTrain = featureVector(:,idxsTrain);
        decisionVectorTrain = decisionVector(:,idxsTrain);
        featureVectorTest = featureVector(:,idxsTest);
        decisionVectorTest = decisionVector(:,idxsTest);
        
        % Training Function
        trainingFunction = 'trainscg';  % Scaled Conjugate Gradient
        
        performances = zeros(1, trainControl.nStart);
        allNets = cell(1, trainControl.nStart);
        
        for iStart = 1:trainControl.nStart
            thisNet = fitnet(trainControl.nNodesFF,trainingFunction);
            
            % Choose Input and Output Pre/Post-Processing Functions
            % For a list of all processing functions type: help nnprocess
            thisNet.input.processFcns = {'removeconstantrows','mapminmax'};
            thisNet.output.processFcns = {'removeconstantrows','mapminmax'};
            
            % Setup Division of Data for Training, Validation, Testing
            % For a list of all data division functions type: help nndivide
            thisNet.divideFcn = 'dividerand';  % Divide data randomly
            thisNet.divideMode = 'sample';  % Divide up every sample
            thisNet.divideParam.trainRatio = 70/100;
            thisNet.divideParam.valRatio = 15/100;
            thisNet.divideParam.testRatio = 15/100;
            
            % Choose a Performance Function
            % For a list of all performance functions type: help nnperformance
            thisNet.performFcn = 'mse';  % Mean squared error
            
            % Choose Plot Functions
            % For a list of all plot functions type: help nnplot
            thisNet.plotFcns = {'plotperform','plottrainstate','ploterrhist', ...
                'plotregression', 'plotfit'};
            
            % Suppress CMD line and GUI outputs
            thisNet.trainParam.showWindow = false;
            thisNet.trainParam.showCommandLine = false;
            
            % Train the Network
            [allNets{1, iStart}, ~] = train(thisNet,featureVectorTrain,...
                decisionVectorTrain);
            
            performances(1, iStart) = mse(decisionVectorTest, ...
                allNets{1, iStart}(featureVectorTest));
        end
        
        [~, idx_best] = min(performances);
        model = allNets{1, idx_best};
        
        %% DEBUGGING: Plot the actual VS forecast values:
        actualResponseTest = decisionVectorTest(:);
        predictResponseTest = model(featureVectorTest);
        figure();
        plot(actualResponseTest, predictResponseTest(:), '.');
        axis equal;
        grid on;
        refline(1, 0);
        xlabel('Actual Values');
        ylabel('Predicted Values');
        title('FFNN Forecast-Free results');
        
    otherwise
        error('Model not yet implemented');
end

end
