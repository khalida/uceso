function [ model ] = trainForecastFreeController( cfg,  demandDataTrain,...
    varargin)

% trainForecastFreeController: Train a FF controller, given the simulation
%           properties, and time-series of historic demand (& pv) data.

%% INPUTS:
% cfg:              Structure of configuration parameters (including train options)
% demandDataTrain:  Vector of historic demand values [nObs x 1]
% varargin:         If 'oso' problem solved, pvDataTrain will also be
% passed in

%% OUPTPUTS:
% model:    MATLAB NN network model of FF controller

if ~isempty(varargin)
    if ~isequal(cfg.type, 'oso') || length(varargin) > 1
        error('Wrong number of input arguments')
    else
        pvDataTrain = varargin{1};
    end
end


%% Seperate data into initialization (nLags) and training
initIdxs = 1:cfg.fc.nLags;
demandDelays = demandDataTrain(initIdxs);
demandDataTrainOnly = demandDataTrain((max(initIdxs)+1):end);
if isequal(cfg.type, 'oso')
    pvDelays = pvDataTrain(initIdxs);
    pvDataTrainOnly = pvDataTrain((max(initIdxs)+1):end);
end


%% Create the godCast (perfect foresight forecast) for training data
demGodCast = createGodCast(demandDataTrainOnly, cfg.sim.horizon);
nTrainIdxs = size(demGodCast, 1);
if isequal(cfg.type, 'oso')
    pvGodCast = createGodCast(pvDataTrainOnly, cfg.sim.horizon);
    if size(pvGodCast, 1) ~= nTrainIdxs
        error('PV and demand lengths dont match');
    end
end

%% Set-up parameters for on-line simulation
if isequal(cfg.type, 'oso')
    battery = Battery(cfg, cfg.sim.batteryCapacity);
else
    meanDemand = mean(demandDataTrainOnly);
    battery = Battery(cfg, meanDemand*cfg.sim.batteryCapacityRatio*...
        cfg.sim.stepsPerDay);
end

%% Simulate Model to create training examples
runControl.godCast = true;
runControl.modelCast = false;
runControl.naivePeriodic = false;
runControl.setPoint = false;

if isequal(cfg.type, 'oso')
    [ ~, ~, ~, ~, ~, respVecs, featVecs, ~] = mpcControllerDp(cfg, ...
        [], demGodCast, demandDataTrainOnly, pvGodCast, pvDataTrainOnly,...
        demandDelays, pvDelays, battery, runControl);
else
    [ ~, ~, ~, respVecs, featVecs, ~] = mpcController(cfg, [], ...
        demGodCast, demandDataTrainOnly, demandDelays, battery,...
        runControl);
end

allFeatVecs = zeros(size(featVecs, 1), size(featVecs, 2)*...
    (cfg.fc.nTrainShuffles + 1));

allRespVecs = zeros(size(respVecs, 1), size(respVecs, 2)*...
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
    demGodCast = createGodCast(demandDataTrainOnly, cfg.sim.horizon);
    
    % demandDataTrainOnly = demandDataTrainOnly(1:nTrainIdxs);
    if nTrainIdxs ~= size(demGodCast, 1);
        error('Gotc inconsistent No. of training intervals from godCast');
    end
    
    if isequal(cfg.type, 'oso')
        
        newPvDataTrain = pvDataTrain;
        for eachSwap = 1:cfg.fc.nDaysSwap
            swapStart = randi(length(pvDataTrain) - 2*cfg.sim.horizon);
            tmpPv = newPvDataTrain(swapStart + (1:cfg.sim.horizon));
            newPvDataTrain(swapStart + (1:cfg.sim.horizon)) = ...
                newPvDataTrain(swapStart + (1:cfg.sim.horizon) + ...
                cfg.sim.horizon);
            
            newPvDataTrain(swapStart + (1:cfg.sim.horizon) + ...
                cfg.sim.horizon) = tmpPv;
        end
        
        % Recompute the demand delays, godCast, and training data only
        pvDelays = newPvDataTrain(initIdxs);
        pvDataTrainOnly = newPvDataTrain((max(initIdxs)+1):end);
        pvGodCast = createGodCast(pvDataTrainOnly, cfg.sim.horizon);
        
        [ ~, ~, ~, ~, ~, respVecs, featVecs, ~] = mpcControllerDp(cfg, ...
            [], demGodCast, demandDataTrainOnly, pvGodCast, ...
            pvDataTrainOnly, demandDelays, pvDelays, battery, runControl);
    else
        [ ~, ~, ~, respVecs, featVecs, ~] = mpcController(cfg, [], ...
            demGodCast, demandDataTrainOnly, demandDelays, battery,...
            runControl);
    end
    
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
