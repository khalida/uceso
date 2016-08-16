function model = generateForecastFreeController(cfg, featVecs, respVecs)

%% INPUTS:
% cfg:      Structure containing forecast/optimization/simulation options
% featVecs: Feature vectors in matrix [nFeat x nObs]
% respVecs: Response vectors in matrix [nResp x nObs]

%% OUTPUTS:
% model:    Trained data-driven model.

nObs = size(featVecs, 2);
if size(respVecs, 2) ~= nObs;
    error('nObservations must be same in feature and response vectors');
end;

switch cfg.fc.modelType

    case 'RF'
        % Produce one model for the charge decision
        model.decisionModel = TreeBagger(cfg.fc.nNodesFF, featVecs',...
            respVecs(1, :)', 'method', 'regression',...
            'OOBPred', 'On').compact;
        
        % And a second for the peakEnergyEstimation (to allow SP recourse)
        if cfg.opt.setPointRecourse
            model.peakEnergy = TreeBagger(cfg.fc.nNodesFF, featVecs',...
                respVecs(2, :)', 'method', 'regression',...
                'OOBPred', 'On').compact;
        end
        
    case 'FFNN'
        % Train NN to output both charge decision and peak energy
        % using multiple initialisations
        model = trainFfnnMultiInit(cfg, featVecs, respVecs);
        
        if ~cfg.fc.suppressOutput
            % DEBUGGING: Plot actual VS modelled responses:
            predictResp = model(featVecs);
            figure();
            plot(respVecs(:), predictResp(:), '.');
            axis equal;
            grid on;
            refline(1, 0);
            xlabel('Actual Responses');
            ylabel('Modelled Responses');
            title('FFNN Forecast-Free results');
        end
        
    otherwise
        error('Model not yet implemented');
end

end
