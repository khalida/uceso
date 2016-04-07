%%  ==== Forecast-free controller for minimizing peak Demand ====
%% Global Config File

%% Save all configuration options in 'cfg' structure, divided into
% cfg.fc:   for forecast settings
% cfg.opt:  for optimisation settings
% cfg.sim:  for simulation settings
% cfg.plt:  for plotting settings
% cfg.sav:  for saving settings

function cfg = Config(pwd)

rng(42);        % For repeatability

% Could use "getenv('NUMBER_OF_PROCESSORS')" but wouldn't work in *nix
nProcAvail = 4; 

% Location of input data file
[parentFold, ~, ~] = fileparts(pwd);
cfg.dataFileWithPath = [parentFold filesep 'data'...
    filesep 'demand_3639.mat'];

%% cfg.sav: Settings for Saving Results
timeStart = clock;
disp('Time started: '); disp(timeStart);

% Create timeString for folder in which to save data:
timeString = [num2str(timeStart(1)), '_',...
    num2str(timeStart(2),'%0.2d'), '_', ...
    num2str(timeStart(3),'%0.2d'), '_', num2str(timeStart(4),'%0.2d'), ...
    num2str(timeStart(5),'%0.2d')];

cfg.sav.resultsDir = [parentFold filesep 'results' filesep timeString];
mkdir(cfg.sav.resultsDir);


%% cfg.sim: Simulation Settings
cfg.sim.nCustomers = [1, 5, 25];
cfg.sim.nAggregates = 3;
cfg.sim.batteryCapacityRatio = 0.05;% fraction of daily mean demand
cfg.sim.batteryChargingFactor = 2;  % ratio of charge rate to capacity
cfg.sim.nDaysTest = 38*7;           % days to run simulation for
cfg.sim.stepsPerHour = 2;           % Half-hourly data
cfg.sim.hoursPerDay = 24;
cfg.sim.billingPeriodDays = 7;      % No. of days in billing period

% Horizon length, in intervals:
cfg.sim.horizon = cfg.sim.hoursPerDay*cfg.sim.stepsPerHour;

% List of methods to run:
cfg.sim.methodList = {'SP', 'NPFC', 'MFFC', 'IMFC', 'PFFC'};

%% cfg.fc: Forecast, and forecast training Settings
cfg.fc.nDaysTrain = 38*7;           % days of historic demand to train on
cfg.fc.modelType = 'FFNN';          % {'RNN', 'MLR', 'RNN', '...'}

% Seasonal period for NP forecast, in intervals
cfg.fc.seasonalPeriod = cfg.sim.hoursPerDay*cfg.sim.stepsPerHour;

% Forecast training options
cfg.fc.nNodes = 50;                 % No. of nodes for NN, forests for RF
cfg.fc.nStart = 3;                  % No. initializations
cfg.fc.minimizeOverFirst = cfg.sim.horizon;
cfg.fc.suppressOutput = false;
cfg.fc.mseEpochs = 4000;
cfg.fc.maxTime = 30*60;             % Max seconds to train one NN
cfg.fc.nRecursive = 1;              % No. of recursive feedbacks for RNN
cfg.fc.clipNegative = true;         % Prevent output fcasts from being -ve

cfg.fc.perfDiffThresh = 0.05;           % Init. performance differences
cfg.fc.nLags = cfg.fc.seasonalPeriod;   % No. of lags to train models on
cfg.fc.trainRatio = 0.8;

% Forecast-free options
cfg.fc.nTrainShuffles = 15;                    % # of shuffles to consider
cfg.fc.nDaysSwap = floor(cfg.fc.nDaysTrain/4); % pairs days to swap/shuffle
cfg.fc.nNodesFF = 50;                          % No. of nodes in FF ctrlr 
cfg.fc.knowFutureFF = false;                   % FF ctrlr sees future?


%% cfg.opt: Optimization settings
cfg.opt.secondWeight = 0;         % Of secondary objective (chargeWhenCan)
cfg.opt.knowDemandNow = true;    % Current demand known to optimizer?
cfg.opt.iterationFactor = 1.0;    % To apply to default max. No. iters
cfg.opt.rewardMargin = true;      % Reward margin from creating new peak?
cfg.opt.setPointRecourse = false;  % Apply set point recourse?
cfg.opt.resetPeakToMean = true;   % Reset tracked pk to mean? (otherwise 0)
cfg.opt.chargeWhenCan = false;
cfg.opt.suppressOutput = cfg.fc.suppressOutput;


%% cfg.plt: Plotting Settings
cfg.plt.visible = 'on';             % Whether to plot vizible output


%% Produce Derived values (no new inputs below)
cfg.sim.nInstances = length(cfg.sim.nCustomers)*cfg.sim.nAggregates;
cfg.sim.nProc = min(cfg.sim.nInstances, nProcAvail);
cfg.sim.nMethods = length(cfg.sim.methodList);

cfg.sim.stepsPerDay = cfg.sim.stepsPerHour*cfg.sim.hoursPerDay;
cfg.fc.nHoursTrain = cfg.sim.hoursPerDay*cfg.fc.nDaysTrain;
cfg.sim.nHoursTest = cfg.sim.hoursPerDay*cfg.sim.nDaysTest;

% Generate filename for saving:
nCustString = '';
for ii = 1:length(cfg.sim.nCustomers);
    nCustString = [nCustString num2str(cfg.sim.nCustomers(ii)) '_'];
    %#ok<*AGROW>
end

if cfg.opt.knowDemandNow
    CDstring = '_withCD';
else
    CDstring = '_noCD';
end

cfg.sav.intermediateFileName = [cfg.sav.resultsDir filesep 'nCust_' ...
    nCustString '_batt_' num2str(100*cfg.sim.batteryCapacityRatio) ...
    'pc__nAgg_' num2str(cfg.sim.nAggregates) CDstring '_intermediate.mat'];

cfg.sav.finalFileName = [cfg.sav.resultsDir filesep 'nCust_' nCustString...
    '_batt_' num2str(100*cfg.sim.batteryCapacityRatio) 'pc__nAgg_' ...
    num2str(cfg.sim.nAggregates) CDstring '.mat'];

% Save a copy of this Confid file to results directory
copyfile([pwd filesep 'Config.m'], cfg.sav.resultsDir);

end
