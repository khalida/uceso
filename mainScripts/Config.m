%%  ==== UCESO: Unprincipled Controllers for Energy Storage Operation ====
%% Global Config File

%% Set all configuration options in 'cfg' structure, divided into
% cfg.fc:   forecast settings
% cfg.opt:  optimization settings
% cfg.sim:  simulation settings
% cfg.bat:  properties of the battery (some are under cfg.sim)
% cfg.plt:  plotting settings
% cfg.sav:  saving settings

function cfg = Config(pwd)

rng(42);                        % For repeatability
cfg.type = 'minMaxDemand';   	% Problem: 'minMaxDemand', 'oso'
cfg.description = 'test_run';

% Could use "getenv('NUMBER_OF_PROCESSORS')" but wouldn't work in *nix
nProcAvail = 16;

%% cfg.sim: Simulation Settings
% Horizon length, in intervals:
cfg.sim.stepsPerHour = 2;
cfg.sim.hoursPerDay = 24;
cfg.sim.horizon = cfg.sim.hoursPerDay*cfg.sim.stepsPerHour;
cfg.sim.nCustomers = [1, 100];
cfg.sim.nAggregates = 2;

cfg.sim.batteryChargingFactor = 2;  % ratio of charge rate to capacity
cfg.sim.nDaysTest = 24*7;           % days to run simulation for
cfg.sim.eps = 1e-4;                 % Threshold for constraint checking
cfg.sim.billingPeriodDays = 7;      % No. of days in billing period

% cfg.sim settings specific to the two-types of control problem:
if isequal(cfg.type, 'minMaxDemand')
    % fraction of daily mean demand of the aggregation
    cfg.sim.batteryCapacityRatio = 0.05;  
else
    % Battery properties for Oso study only
    cfg.sim.batteryCapacityPerCustomer = 2;
    % Declare total battery size if we want to use single battery size:
    % cfg.sim.batteryCapacityTotal = 2;
    cfg.sim.batteryEtaC = 0.94;
    cfg.sim.batteryEtaD = 0.94;
    cfg.sim.updateBattValue = false;
    cfg.sim.minCostDiff = 1e-6;
    cfg.sim.exportPrice = 0.05;
    cfg.sim.importPriceHigh = 0.4;
    cfg.sim.importPriceLow = 0.2;
    cfg.sim.firstHighPeriod = 14;
    cfg.sim.lastHighPeriod = 43;
end

% List of methods to run:
%  {'NB', 'SP', 'NPFC', 'MFFC', 'DDFC' 'IMFC', 'PFFC'};
cfg.sim.methodList = {'NB', 'SP', 'NPFC', 'MFFC','IMFC', 'PFFC'};  


%% cfg.fc: Forecast, and forecast-training Settings
cfg.fc.nDaysTrain = 52*7;     % days of historic demand to train on
cfg.fc.modelType = 'FFNN';    % {'RNN', 'MLR', 'RNN', '...'}

% Seasonal period for NP forecast, in intervals
cfg.fc.seasonalPeriod = cfg.sim.hoursPerDay*cfg.sim.stepsPerHour;

% Forecast training options
cfg.fc.nNodes = 50;                     % No. of nodes for NN, forests for RF
cfg.fc.nStart = 10;                      % No. initializations
cfg.fc.minimizeOverFirst = cfg.sim.horizon;
cfg.fc.suppressOutput = false;
cfg.fc.mseEpochs = 1000;
cfg.fc.maxTime = 60*60;                 % Max seconds to train one NN
cfg.fc.nRecursive = 1;                  % No. of recursive feedbacks for RNN
cfg.fc.clipNegative = true;             % Prevent output fcasts from being -ve
cfg.fc.perfDiffThresh = 0.05;           % Performance diff. to notify of
cfg.fc.nLags = cfg.fc.seasonalPeriod;   % No. of lags to train models on
cfg.fc.trainRatio = 0.8;
cfg.fc.lagsToInclude = 1:cfg.fc.nLags;

% Forecast-free options
cfg.fc.nTrainShuffles = 30;             % # of shuffles to consider
cfg.fc.nDaysSwap = 0; %floor(cfg.fc.nDaysTrain/4); % day-pairs to swap
cfg.fc.nNodesFF = 50;                   % No. of nodes in FF ctrler
cfg.fc.knowFutureFF = false;            % FF ctrlr sees future? (true for testing only)
% How often to randomize SoC in FF example generation (to build robustness)
cfg.fc.randomizeInterval = 7;
cfg.fc.randTrainIdx = false;            % whether to randomize training indexes
cfg.fc.createNetDemand = true;          % whether to convert demand/PC to net demand


%% cfg.opt: Optimization settings
cfg.opt.knowDemandNow = false;        % Current demand known to optimizer?
cfg.opt.setPointRecourse = false;     % Apply set point recourse?
cfg.opt.suppressOutput = cfg.fc.suppressOutput;
if isequal(cfg.type, 'minMaxDemand')
    cfg.opt.secondWeight = 0;         % Of secondary objective (chargeWhenCan)
    cfg.opt.iterationFactor = 1.0;    % To apply to default max. No. iters
    cfg.opt.rewardMargin = true;      % Reward margin from creating new peak?
    cfg.opt.resetPeakToMean = true;   % Reset tracked pk to mean? (otherwise 0)
    cfg.opt.chargeWhenCan = false;
else
    cfg.opt.statesPerKwh = 8;         % For dynamic program
    cfg.opt.statesTotal = 32;	      % If not 0, use a single resolution for full battery size
end


%% cfg.bat: Battery Settings
cfg.bat.damageModel = 'fixed';      % {'fixed', 'staticMultifactor', 'dynamicMultifactor'}
cfg.bat.nominalCycleLife = 1825;    % 5yrs, 1 cycle (charge/discharge) per day
cfg.bat.nominalDoD = 80;            % 10% - 90% cycle
cfg.bat.nominalSoCav = 50;
cfg.bat.maxLifeHours = 7*365.25*24; % 7yrs
cfg.bat.costPerKwhUsed = 0.0;      % fixed cost for charge and discharge of 1kWh


%% cfg.plt: Plotting Settings
cfg.plt.visible = 'on';             % Whether to plot vizible output


%% Location of input data:
[parentFold, ~, ~] = fileparts(pwd);

if isequal(cfg.type, 'minMaxDemand')
    cfg.dataFileWithPath = [parentFold filesep 'data' filesep 'dataMmd'...
        filesep 'demand_3639.mat'];
else
    cfg.osoDataFolder = [parentFold filesep 'data' filesep 'dataOso'...
        filesep 'data' filesep 'AusGrid_data' filesep '2011_2013'];
end


%% cfg.sav: Location of input/output files:
timeStart = clock;
disp('Time started: '); disp(timeStart);

% Create timeString for folder in which to save data:
timeString = [num2str(timeStart(1)), '_',...
    num2str(timeStart(2),'%0.2d'), '_', ...
    num2str(timeStart(3),'%0.2d'), '_', num2str(timeStart(4),'%0.2d'), ...
    num2str(timeStart(5),'%0.2d')];

if isequal(cfg.type, 'minMaxDemand')
    cfg.sav.resultsDir = [parentFold filesep 'resultsMmd' filesep...
        timeString '_' cfg.description];
else
    cfg.sav.resultsDir = [parentFold filesep 'resultsOso' filesep...
        timeString '_' cfg.description];
end
mkdir(cfg.sav.resultsDir);


%% Produce Derived values (no configurable inputs below this line)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
cfg.sim.nInstances = length(cfg.sim.nCustomers)*cfg.sim.nAggregates;
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
    if cfg.opt.statesTotal == 0
        statesString = [num2str(cfg.opt.statesPerKwh) 'spk'];
    else
        statesString = [num2str(cfg.opt.statesTotal) 'sTtl'];
    end
    
    if ~isfield(cfg.sim, 'batteryCapacityTotal');
        cfg.sav.finalFileName = [cfg.sav.resultsDir filesep 'batt_' ...
            num2str(cfg.sim.batteryCapacityPerCustomer) 'kWhPerC_' ...
            statesString '.mat'];
    else
        cfg.sav.finalFileName = [cfg.sav.resultsDir filesep 'batt_' ...
            num2str(cfg.sim.batteryCapacityTotal) 'kWhTot_' ...
            statesString '.mat'];
    end
end


%% Save a copy of this Config file to results director
% (unless already exists)

if ~exist([cfg.sav.resultsDir filesep 'thisConfig.m']) %#ok<EXIST>
copyfile([pwd filesep 'Config.m'], [cfg.sav.resultsDir filesep ...
    'thisConfig.m']);
else
    warning('thisConfig.m not created as location was taken');
end

%% Generate a list of nCustomers which is nInstances long
% and maps as required:
instance = 0;
cfg.sim.nCustomersByInstance = zeros(cfg.sim.nInstances, 1);
for ii = 1:length(cfg.sim.nCustomers)
    for jj = 1:cfg.sim.nAggregates
        instance = instance + 1;
        cfg.sim.nCustomersByInstance(instance) = cfg.sim.nCustomers(ii);
    end
end

end
