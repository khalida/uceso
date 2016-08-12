% file: trainFfnnMultipleStarts.m
% auth: Khalid Abdulla
% date: 06/04/2016
% brief: run trainFfnn multiple times and return best performing model
% based on held-out set

function model = trainFfnnMultipleStarts( cfg, demand, varargin )

%% INPUTS
% cfg:      Configuration structure including train control parameters
% demand:   Time-history of demands on which to train [nObsTrain x 1]
% varargin: stateValues if we are to train model to be further trained for
% decision-driven forecasting approach

%% OUTPUTS
% model:    Best NN found


%% Get Data formated for NN training
[ featVecs, respVecs ] = computeFeatureResponseVectors( demand, ...
    cfg.fc.nLags, cfg.sim.horizon);
% featVecs: [nLags x nObs]
% respVecs: [horizon x nObs]

% If we are training model to be used further trained into decision-driven
% forecast expand data to include appropriately randomized state vectors
if ~isempty(varargin)
    if length(varargin) ~= 1
        error('Wrong number of input arguments')
    else
        stateValues = varargin{1};
        
        % Extend no. of examples as required (to accomodate state samples)
        featVecs = repmat(featVecs, [1, cfg.fc.ddForecastDraws]);
        respVecs = repmat(respVecs, [1, cfg.fc.ddForecastDraws]);
        
        % Add randomly samples states to the feature vectors:
        if isequal(cfg.type, 'oso')
            % For OSO case, just assume uniform distribution across
            % allowable (discrete) states (initalise battery to find
            % states)
            if ~isfield(cfg.sim, 'batteryCapacityTotal')
                % Battery size fixed by number of customers:
                battery = Battery(getCfgForController(cfg),...
                    cfg.sim.batteryCapacityPerCustomer*nCustomer);
            else
                % Constant overall battery size
                battery = Battery(getCfgForController(cfg),...
                    cfg.sim.batteryCapacityTotal);
            end
            randIdxs = randsample(length(battery.statesKwh), ...
                size(featVecs, 2), true);
            
            featVecs(end+1, :) = battery.statesKwh(randIdxs)';
        else
            % mvnrnd(mu, sigma, cases) returns a cases-by-d matrix of random
            % vectors chosen from the multivariate normal distribution with
            % common 1-by-d mean vector MU, and common d-by-d covariance matrix SIGMA.
            mus = mean(stateValues, 1);
            stds = std(stateValues, [], 1);
            featVecs(end+(1:2), :) = ...
                mvnrnd(mus, diag(stds), size(featVecs, 2));
        end
    end
end

%% Divide Data into training and testing sets
nObs = size(featVecs,2);
nObsTrain = floor(nObs*cfg.fc.trainRatio);
nObsVal = nObs - nObsTrain;
if cfg.fc.randTrainIdx
    idxs = randperm(nObs);
else
    idxs = 1:nObs;
end
idxsTrain = idxs(1:nObsTrain);
idxsVal = idxs(nObsTrain+(1:nObsVal));
featVecsTrain = featVecs(:,idxsTrain);
respVecsTrain = respVecs(:,idxsTrain);
featVecsVal = featVecs(:,idxsVal);
respVecsVal = respVecs(:,idxsVal);


%% Train multiple networks and evaluate performances
performance = zeros(cfg.fc.nStart, 1);
allModels = cell(cfg.fc.nStart, 1);
allResponses = cell(cfg.fc.nStart, 1);

for iStart = 1:cfg.fc.nStart
    allModels{iStart} = trainFfnn(cfg, featVecsTrain, respVecsTrain);
    allResponses{iStart} = allModels{iStart}(featVecsVal);
    
    performance(iStart) = mean(mse(respVecsVal(...
        1:cfg.fc.minimizeOverFirst, :), allResponses{iStart}(...
        1:cfg.fc.minimizeOverFirst, :)), 2);
end

[~, idxBest] = min(performance);


%% Output performance of each model if difference is > threshold
percentageDiff = (max(performance) - min(performance)) / min(performance);

if percentageDiff > cfg.fc.perfDiffThresh
    
    disp(['Percentage Difference: ' num2str(100*percentageDiff)...
        '. Performances: ' num2str(performance')]);
end

model = allModels{idxBest};

%% Complete decision-driven fine-tunning as required
% Re-uses code from FEMC project:
if ~isempty(varargin)
    model = trainFfnnCustomLoss(cfg, featVecTrain, respVecTrain, ...
        model, lossExact);
end

end
