%%  ==== Forecast-free controller for minimizing peak Demand ====
%% Global Config File

%% Save all configuration options in 'cfg' structure, divided into
% cfg.fc:   for forecast settings
% cfg.opt:  for optimisation settings
% cfg.sim:  for simulation settings
% cfg.plt:  for plotting settings
% cfg.sav:  for saving settings

function cfg = Config(pwd)

cfg.type = 'oso';   % minMaxDemand

rng(42);        % For repeatability

% Could use "getenv('NUMBER_OF_PROCESSORS')" but wouldn't work in *nix
nProcAvail = 4;

% Location of input data files
[parentFold, ~, ~] = fileparts(pwd);

if isequal(cfg.type, 'minMaxDemand')
    cfg.dataFileWithPath = [parentFold filesep 'data' filesep 'dataMmd'...
        filesep 'demand_3639.mat'];
else
    cfg.osoDataFolder = [parentFold filesep 'data' filesep 'dataOso'];
end

%% cfg.sav: Settings for Saving Results
timeStart = clock;
disp('Time started: '); disp(timeStart);

% Create timeString for folder in which to save data:
timeString = [num2str(timeStart(1)), '_',...
    num2str(timeStart(2),'%0.2d'), '_', ...
    num2str(timeStart(3),'%0.2d'), '_', num2str(timeStart(4),'%0.2d'), ...
    num2str(timeStart(5),'%0.2d')];

if isequal(cfg.type, 'minMaxDemand')
    cfg.sav.resultsDir = [parentFold filesep 'resultsMmd' filesep timeString];
else
    cfg.sav.resultsDir = [parentFold filesep 'resultsOso' filesep timeString];
end
mkdir(cfg.sav.resultsDir);


%% cfg.sim: Simulation Settings
if isequal(cfg.type, 'minMaxDemand')
    cfg.sim.batteryCapacityRatio = 0.10;% fraction of daily mean demand
    cfg.sim.nCustomers = [1, 5]; %, 25];
    cfg.sim.nAggregates = 2;
    cfg.sim.nInstances = length(cfg.sim.nCustomers)*cfg.sim.nAggregates;
else
    cfg.sim.nInstances = 4;
    % Battery properties for Oso study only
    cfg.sim.batteryCapacity = 2.0;
    cfg.sim.batteryEtaC = 0.94;
    cfg.sim.batteryEtaD = 0.94;
    cfg.sim.batteryCostPerKwhUsed = 0;
end
cfg.sim.batteryChargingFactor = 4;  % ratio of charge rate to capacity
cfg.sim.nDaysTest = 1*7; %38*7;           % days to run simulation for
cfg.sim.stepsPerHour = 2;           % Half-hourly data
cfg.sim.hoursPerDay = 24;
cfg.sim.billingPeriodDays = 7;      % No. of days in billing period

% Horizon length, in intervals:
cfg.sim.horizon = cfg.sim.hoursPerDay*cfg.sim.stepsPerHour;

% List of methods to run:
cfg.sim.methodList = {'NB', 'SP', 'NPFC', 'MFFC', 'IMFC', 'PFFC'};

%% cfg.fc: Forecast, and forecast training Settings
cfg.fc.nDaysTrain = 1*7; %38*7;           % days of historic demand to train on
cfg.fc.modelType = 'FFNN';          % {'RNN', 'MLR', 'RNN', '...'}

% Seasonal period for NP forecast, in intervals
cfg.fc.seasonalPeriod = cfg.sim.hoursPerDay*cfg.sim.stepsPerHour;

% Forecast training options
cfg.fc.nNodes = 50;                 % No. of nodes for NN, forests for RF
cfg.fc.nStart = 2;                  % No. initializations
cfg.fc.minimizeOverFirst = cfg.sim.horizon;
cfg.fc.suppressOutput = false;
cfg.fc.mseEpochs = 4000;
cfg.fc.maxTime = 1*60; %30*60;             % Max seconds to train one NN
cfg.fc.nRecursive = 1;              % No. of recursive feedbacks for RNN
cfg.fc.clipNegative = true;         % Prevent output fcasts from being -ve

cfg.fc.perfDiffThresh = 0.05;           % Init. performance differences
cfg.fc.nLags = cfg.fc.seasonalPeriod;   % No. of lags to train models on
cfg.fc.trainRatio = 0.8;

% Forecast-free options
cfg.fc.nTrainShuffles = 1; %15;                    % # of shuffles to consider
cfg.fc.nDaysSwap = floor(cfg.fc.nDaysTrain/4); % pairs days to swap/shuffle
cfg.fc.nNodesFF = 50;                          % No. of nodes in FF ctrlr
cfg.fc.knowFutureFF = false;                   % FF ctrlr sees future?


%% cfg.opt: Optimization settings
if isequal(cfg.type, 'minMaxDemand')
    cfg.opt.secondWeight = 0;         % Of secondary objective (chargeWhenCan)
    cfg.opt.iterationFactor = 1.0;    % To apply to default max. No. iters
    cfg.opt.rewardMargin = true;      % Reward margin from creating new peak?
    cfg.opt.resetPeakToMean = true;   % Reset tracked pk to mean? (otherwise 0)
    cfg.opt.chargeWhenCan = false;
else
    cfg.opt.statesPerKwh = 8;         % For dynamic program
end
cfg.opt.knowDemandNow = false;    % Current demand known to optimizer?
cfg.opt.setPointRecourse = true;  % Apply set point recourse?
cfg.opt.suppressOutput = cfg.fc.suppressOutput;


%% cfg.plt: Plotting Settings
cfg.plt.visible = 'on';             % Whether to plot vizible output


%% Produce Derived values (no new inputs below)
cfg.sim.nProc = min(cfg.sim.nInstances, nProcAvail);
cfg.sim.nMethods = length(cfg.sim.methodList);

cfg.sim.stepsPerDay = cfg.sim.stepsPerHour*cfg.sim.hoursPerDay;
cfg.fc.nHoursTrain = cfg.sim.hoursPerDay*cfg.fc.nDaysTrain;
cfg.sim.nHoursTest = cfg.sim.hoursPerDay*cfg.sim.nDaysTest;

% Generate filename for saving:
if cfg.opt.knowDemandNow
    CDstring = '_withCD';
else
    CDstring = '_noCD';
end

if isequal(cfg.type, 'minMaxDemand')
    nCustString = '';
    for ii = 1:length(cfg.sim.nCustomers);
        nCustString = [nCustString num2str(cfg.sim.nCustomers(ii)) '_'];
        %#ok<*AGROW>
    end
    
    cfg.sav.intermedFileName = [cfg.sav.resultsDir filesep 'nCust_' ...
        nCustString '_batt_' num2str(100*cfg.sim.batteryCapacityRatio) ...
        'pc__nAg_' num2str(cfg.sim.nAggregates) CDstring '_intermed.mat'];
    
    cfg.sav.finalFileName = [cfg.sav.resultsDir filesep 'nCust_'...
        nCustString '_batt_' num2str(100*cfg.sim.batteryCapacityRatio) ...
        'pc__nAgg_' num2str(cfg.sim.nAggregates) CDstring '.mat'];
else
    cfg.sav.finalFileName = [cfg.sav.resultsDir filesep 'batt_' ...
        num2str(cfg.sim.batteryCapacity) 'kWh_' ...
        num2str(cfg.opt.statesPerKwh) 'spk.mat'];
end

% Save a copy of this Config file to results directory
copyfile([pwd filesep 'Config.m'], [cfg.sav.resultsDir filesep ...
    'thisConfig.m']);

end
