function [ Sim, pars ] = trainAllForecasts( MPC, Sim, allDemandValues)

% trainAllForecasts: Train parameters for all trained forecasts. Run
%   through each instance and each method and output parameters
%   of trained forecasts.

% INPUTS:
% MPC; Structure containing optimization options
% Sim; Structure containing simulation and general options (including
% training options)
% allDemandValues; Cellarray, each cell containing array of demand values
                    % for an instance

% OUTPUTS:
% Sim; Updated simulation options structure
% pars; cellarray {nInstances x nMethods} to hold model parameters (models)

tic;

%% Pre-Allocation
timeTaken = cell(Sim.nInstances, 1);
k = Sim.k;

% Parameters for the trained forecasts, and the forecast-free controllers
pars = cell(Sim.nInstances, Sim.nMethods);

for instance = 1:Sim.nInstances
    timeTaken{instance} = zeros(Sim.nMethods,1);
end

Sim.trainIdxs = 1:(Sim.stepsPerHour*Sim.nHoursTrain);
Sim.hourNumber = mod((1:size(allDemandValues{1}, 1))', k);
Sim.hourNumberTrain = Sim.hourNumber(Sim.trainIdxs, :);

% Set default model type if not set already:
Sim = setDefaultValues(Sim, {'forecastModels', 'FFNN'});

switch Sim.forecastModels
    case 'FFNN'
        trainHandle = @trainFfnnMultipleStarts;
        disp('== USING FFNN MODELS ===');
        
    case 'SARMA'
        trainHandle = @trainSarma;
        disp('== USING SARMA MODELS ===');
        
    case 'RF'
        trainHandle = @trainRandomForestForecast;
        disp('== USING RANDOM FOREST MODELS ===');
    
    otherwise
        error('Selected Sim.forecastModels not implemented');
end

% Extract local data from structures for efficiency in parFor loop
% communication
nInstances = Sim.nInstances;
nMethods = Sim.nMethods;
trainIdxs = Sim.trainIdxs;
methodList = Sim.methodList;

%% Train Models
poolobj = gcp('nocreate');
delete(poolobj);

parfor instance = 1:nInstances

    % for instance = 1:nInstances
    % Extract aggregated demand
    demandValuesTrain = allDemandValues{instance}(trainIdxs);
    
    for methodTypeIdx = 1:nMethods
        switch methodList{methodTypeIdx} %#ok<PFBNS>
            
            % Train forecast-free controller
            case 'IMFC'
                tempTic = tic;
                pars{instance, methodTypeIdx} = ...
                    trainForecastFreeController( demandValuesTrain, Sim,...
                    MPC);
                
                timeTaken{instance}(methodTypeIdx) = toc(tempTic);
                
            % Skip if method doesn't need training
            case 'NPFC'
                continue;
                
            case 'PFFC'
                continue;
                
            case 'SP'
                continue;
                
            % Train forecast:
            case 'MFFC'
                tempTic = tic;
                pars{instance, methodTypeIdx} = trainHandle(...
                    demandValuesTrain, Sim.trainControl);
                
                timeTaken{instance}(methodTypeIdx) = toc(tempTic);
                
            otherwise
                error('Selected method has not been implemented');
                
        end
        disp([methodList{methodTypeIdx} ' training done!']);
    end
end

poolobj = gcp('nocreate');
delete(poolobj);

Sim.timeTaken = timeTaken;
Sim.timeForecastTrain = toc;

disp('Time to end forecast training:'); disp(Sim.timeForecastTrain);

end
