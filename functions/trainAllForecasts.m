function [ trainedModels, trainTime ] = trainAllForecasts(cfg, dataTrain)

% trainAllForecasts: Train forecast models and forecast-free controller.
%   Run through each instance and each method and output trained models.

%% INPUTS:
% cfg:              Structure containing all of the running options
% dataTrain:        Structure with demand (and PV) data [nIntervalsTrain x nInstances]

%% OUTPUTS:
% trainedModels:    Trained forecast and forecast-free controller models
%                           in cell array.
% trainTime:        Time taken for training

tic;

%% Pre-Allocation:
timeTaken = zeros(cfg.sim.nInstances, cfg.sim.nMethods);
trainedModels = cell(cfg.sim.nInstances, cfg.sim.nMethods);

% Choose the appropriate forecast training function
switch cfg.fc.modelType
    case 'FFNN'
        trainHandle = @trainFfnnMultipleStarts;
        disp('== USING FFNN MODELS ===');
        
    case 'RF'
        trainHandle = @trainRandomForestForecast;
        disp('== USING RANDOM FOREST MODELS ===');
        
    otherwise
        error('Selected cfg.fc.modelType not implemented');
end


%% Train Models
% Delete parrallel pool if it exists
poolobj = gcp('nocreate');
delete(poolobj);
% Set-up cluster job with own dir (to avoid error messages):
myCluster = parcluster('local');
tmpDirName = tempname;
mkdir(tmpDirName);
myCluster.JobStorageLocation = tmpDirName;
poolobj = parpool(myCluster);

parfor instance = 1:cfg.sim.nInstances
% for instance = 1:cfg.sim.nInstances
    
    tempModels = cell(1, cfg.sim.nMethods);     % prevent parfor issues
    tempTimeTaken = zeros(1, cfg.sim.nMethods);
    
    for methodTypeIdx = 1:cfg.sim.nMethods
        
        switch cfg.sim.methodList{methodTypeIdx} %#ok<*PFBNS>
            
            % Train forecast-free controller
            case 'IMFC'
                tempTic = tic;
                
                if isequal(cfg.type, 'oso')
                    tempModels{1, methodTypeIdx} = ...
                        trainForecastFreeController(cfg, ...
                        dataTrain.demand(:, instance), ...
                        dataTrain.pv(:, instance), ...
                        cfg.sim.nCustomersByInstance(instance));
                else
                    tempModels{1, methodTypeIdx} = ...
                        trainForecastFreeController(cfg, ...
                        dataTrain.demand(:, instance));
                end
                
                tempTimeTaken(1, methodTypeIdx) = toc(tempTic);
                
                % Skip if method doesn't need training
            case 'NPFC'
                continue;
                
            case 'PFFC'
                continue;
                
            case 'SP'
                continue;
                
            case 'NB'
                continue;
                
                % Train forecast model
            case 'MFFC'
                tempTic = tic;
                
                tempModels{1, methodTypeIdx}.demand = trainHandle(...
                    cfg, dataTrain.demand(:, instance));
                
                if isequal(cfg.type, 'oso')
                    tempModels{1, methodTypeIdx}.pv = trainHandle(...
                        cfg, dataTrain.pv(:, instance));
                end
                
                tempTimeTaken(1, methodTypeIdx) = toc(tempTic);
                
            otherwise
                error('Selected method has not been implemented');
                
        end
        disp([cfg.sim.methodList{methodTypeIdx} ' training done!']);
    end
    
    % save temporary cellArray of models to the full array
    % (avoid parfor complaints).
    trainedModels(instance, :) = tempModels;
    timeTaken(instance, :) = tempTimeTaken;
    
end

% Kill the parrallel pool (errors tend to occur if pool kept open too long)
delete(poolobj);

trainTime = timeTaken;

disp('Time to train models: '); disp(toc);

end
