function model = generateForecastFreeController(featureVector, ...
    decisionVector, Sim)

% INPUTS:
%   featureVector:  Input data [nFeatures x nObservations]
%   decisionVector: Output data [nDecisions x nObservations]
%   Sim:            Structure of running / training options

% OUTPUTS:
%   model:          Trained forecast-free model

nObservations = size(featureVector, 2);

if size(decisionVector, 2) ~= nObservations;
    error('nObservations must be same in feature and decision vectors');
end;

switch Sim.forecastModels
    
    case 'RF'
        
        model.decisionModel = TreeBagger(Sim.nTreesFF, featureVector', ...
            decisionVector(1, :)', 'method', 'regression', 'OOBPred',...
            'On').compact;
        
        if size(decisionVector, 1) == 2
            model.peakPowerModel = TreeBagger(Sim.nTreesFF, featureVector', ...
                decisionVector(2, :)', 'method', 'regression', 'OOBPred',...
                'On').compact;
        end
        
    case 'FFNN'
        
        % Training Function
        trainingFunction = 'trainscg';  % Scaled Conjugate Gradient
        
        performances = zeros(1, Sim.nStart);
        allNets = cell(1, Sim.nStart);
        
        for iStart = 1:Sim.nStart
            thisNet = fitnet(Sim.nTrees,trainingFunction);
            
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
            [allNets{1, iStart}, tr] = train(thisNet,featureVector,...
                decisionVector);
            performances(1, iStart) = tr.best_tperf;
        end
        
        [perf_best, idx_best] = min(performances);
        [perf_worst, ~] = max(performances);
        perfPercDiff = ((perf_worst - perf_best)/perf_best);
        if perfPercDiff > Sim.performanceDifferenceThreshold
            disp(['Forecast free percentage Difference: ', ...
                num2str(perfPercDiff), ' Performances: ', ...
                num2str(performances)]);
        end
        model = allNets{1, idx_best};
        
    otherwise
        error('Model not yet implemented');
end

end
