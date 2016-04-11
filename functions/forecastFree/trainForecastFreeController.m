function [ model ] = trainForecastFreeController( cfg,  demandDataTrain )

% trainForecastFreeController: Train a FF controller, given the simulation
%           properties, and time-series of historic demand data.

%% INPUTS:
% cfg:      Structure of configuration parameters (including train options)
% demandDataTrain: Vector of historic demand values [nObs x 1]

%% OUPTPUTS:
% model:    MATLAB NN network model of FF controller


%% Seperate data into initialization (nLags) and training
initIdxs = 1:cfg.fc.nLags;
demandDelays = demandDataTrain(initIdxs);
demandDataTrainOnly = demandDataTrain((max(initIdxs)+1):end);


%% Create the godCast (perfect foresight forecast) for training data
demandGodCast = createGodCast(demandDataTrainOnly, cfg.sim.horizon);
nTrainIdxs = size(demandGodCast, 1);
demandDataTrainOnly = demandDataTrainOnly(1:nTrainIdxs);

%% Set-up parameters for on-line simulation
meanDemand = mean(demandDataTrainOnly);

battery = makeBattery(meanDemand, cfg);

%% Simulate Model to create training examples
[ featVecs, respVecs] = mpcGenerateForecastFreeExamples(cfg, ...
    demandGodCast, demandDataTrainOnly, demandDelays, battery);

allFeatVecs = zeros(size(featVecs, 1), length(demandDataTrainOnly)*...
    (cfg.fc.nTrainShuffles + 1));

allRespVecs = zeros(size(respVecs, 1), length(demandDataTrainOnly)*...
    (cfg.fc.nTrainShuffles + 1));

allFeatVecs(:, 1:nTrainIdxs) = featVecs;
allRespVecs(:, 1:nTrainIdxs) = respVecs;

offset = nTrainIdxs;

%% Continue generating examples with suffled versions of training data:
for eachShuffle = 1:cfg.fc.nTrainShuffles
    
    newDemandDataTrain = demandDataTrain;
    for eachSwap = 1:cfg.fc.nDaysSwap
        swapStart = randi(length(demandDataTrain) - 2*cfg.sim.horizon);
        tmpDem = newDemandDataTrain(swapStart + (1:cfg.sim.horizon));
        newDemandDataTrain(swapStart + (1:cfg.sim.horizon)) = ...
            newDemandDataTrain(swapStart + (1:cfg.sim.horizon) + ...
            cfg.sim.horizon);
        
        newDemandDataTrain(swapStart + (1:cfg.sim.horizon) + ...
            cfg.sim.horizon) = tmpDem;
    end
    
    % Recompute the demand delays, godCast, and training data only
    demandDelays = newDemandDataTrain(initIdxs);
    demandDataTrainOnly = newDemandDataTrain((max(initIdxs)+1):end);
    demandGodCast = createGodCast(demandDataTrainOnly, cfg.sim.horizon);
    demandDataTrainOnly = demandDataTrainOnly(1:nTrainIdxs);
    if nTrainIdxs ~= size(demandGodCast, 1);
        error('Gotc inconsistent No. of training intervals from godCast');
    end
    
    [ featVecs, respVecs] = mpcGenerateForecastFreeExamples(cfg, ...
        demandGodCast, demandDataTrainOnly, demandDelays, battery);
    
    allFeatVecs(:, offset + (1:nTrainIdxs)) = featVecs;
    allRespVecs(:, offset + (1:nTrainIdxs)) = respVecs;
    offset = offset + nTrainIdxs;
    
    % Print output (to confirm progress):
    disp(['Shuffle done, of: ' num2str(cfg.fc.nTrainShuffles)]);
    disp(eachShuffle);
end

%% Train forecast-free RF model based on examples generated
model = generateForecastFreeController(cfg, allFeatVecs, allRespVecs);

end
