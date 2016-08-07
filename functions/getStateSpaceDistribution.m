function [ stateSpaceVals ] = getStateSpaceDistribution(cfg, dataTrain,...
    nCustomer)

% getStateSpaceDistribution: Run controller over training data-set with PF
% forecast, and get multivariate distribution of states.

%% INPUTS:
% cfg:              Structure containing all of the running options
% dataTrain:        Structure with demand (and PV) data [nIntervalsTrain]

%% OUTPUTS:
% stateSpaceVals:   Vector t-series vectors of state values [nStates, nIdxs]

tic;

%% Run t-series models to extract state-space
% Delete parrallel pool if it exists

% Seperate data into initialization (nLags) and training
cfg.sim.initIdxs = 1:cfg.fc.nLags;
cfg.sim.trainOnlyIdxs = (max(cfg.sim.initIdxs)+1):...
    (size(dataTrain.demand, 1));

% Set-up runControl structure for running options:
runControl.godCast = true;
runControl.modelCast = false;
runControl.naivePeriodic = false;
runControl.setPoint = false;
% run WITHOUT randomizing:
runControl.randomizeInterval = 9e9;


% clear variables to avoid parfor warnings:
pvDelays = []; pvDataTrainOnly = []; pvGodCast = [];

demandDelays = dataTrain.demand(cfg.sim.initIdxs);
demandDataTrainOnly = dataTrain.demand(cfg.sim.trainOnlyIdxs);

if isequal(cfg.type, 'oso')
    pvDelays = dataTrain.pv(cfg.sim.initIdxs);
    pvDataTrainOnly = dataTrain.pv((max(cfg.sim.initIdxs)+1):end);
end

% Create the godCast (perfect foresight forecast) for training data
demGodCast = createGodCast(demandDataTrainOnly, cfg.sim.horizon);
nTrainIdxs = size(demGodCast, 1);

if isequal(cfg.type, 'oso')
    pvGodCast = createGodCast(pvDataTrainOnly, cfg.sim.horizon);
    if size(pvGodCast, 1) ~= nTrainIdxs
        error('PV and demand lengths dont match');
    end
end

battery = getBatteryObject(cfg, nCustomer, data);

%% Simulate Model to create training examples
if isequal(cfg.type, 'oso') %#ok<*PFBNS>
    [ ~, ~, ~, ~, ~, ~, featVecs, ~, ~, ~] = mpcControllerDp(...
        cfg, [], demGodCast, demandDataTrainOnly, pvGodCast,...
        pvDataTrainOnly, demandDelays, pvDelays, battery, runControl);
    
    % featVec = [nLag prev dem, (demandNow), nLag prev pv, (pvNow), SoC,...
    % hourNum]
    
    % Extract SoC 'state' values:
    stateSpaceVals = featVecs(end-1, :);
else
    [ ~, ~, ~, ~, featVecs, ~] = mpcController(cfg, [], ...
        demGodCast, demandDataTrainOnly, demandDelays, battery,...
        runControl);
    
    % featVec = [demandDelay; stateOfCharge; (demandNow); peakSoFar];
    % Extract SoC, peakPower 'state' values:
    stateSpaceVals = featVecs([cfg.fc.nLags+1, end], :);
end

disp('Time to extract state-space: '); disp(toc);

end


%%%%%% Do some plotting: %%%%%%%
% for ii = 1:cfg.sim.nInstances
%     figure(); title(['Instance: ' num2str(ii)]);
%     nStateVar = size(stateValues{ii}, 1);
%     
%     Plot time-series results
%     for jj = 1:nStateVar
%         subplot(nStateVar, 1, jj);
%         plot(stateValues{ii}(jj, :));
%         xlabel('Interval');
%         ylabel('State');
%     end
%     
%     Plot N-D histogram, where n is No. of state variables
%     figure(); title(['Instance: ' num2str(ii)]);
%     if isequal(cfg.type, 'oso')
%         histogram(stateValues{ii});
%         xlabel('SoC');
%         ylabel('Count');
%     else
%         histogram2(stateValues{ii}(1, :), stateValues{ii}(2, :));
%         xlabel('SoC');
%         ylabel('Peak so Far');
%         zlabel('Count');
%     end
% end