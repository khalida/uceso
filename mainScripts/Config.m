%% Global Configuration File - Forecast free controller for minimizing maximum Demand!

%% Create string for storing results, and copy of config file
timeString = [num2str(timeStart(1)), '_',...
    num2str(timeStart(2),'%0.2d'), '_', ...
    num2str(timeStart(3),'%0.2d'), '_', num2str(timeStart(4),'%0.2d'), ...
    num2str(timeStart(5),'%0.2d')];

Sim.resultsDir = ['..' filesep 'results' filesep timeString];
mkdir(Sim.resultsDir);

%% Instances
Sim.nCustomers = [1, 5, 25];
Sim.nAggregates = 3;
Sim.nInstances = length(Sim.nCustomers) * Sim.nAggregates;
Sim.nProc = min(Sim.nInstances, 4);

%% Battery Properties
Sim.batteryCapacityRatio = 0.10;    % as fraction of daily average demand
Sim.batteryChargingFactor = 2;      % ratio of charge rate to capacity

%% Simulation Duration and properties
Sim.nDaysTrain = 38*7;      % days of historic demand data
Sim.nDaysTest = 38*7;       % 56;    % days to run simulation for
Sim.stepsPerHour = 2;      % Half-hourly data
Sim.hoursPerDay = 24;       
Sim.k = 48;                    % horizon & seasonality (assumed same)

%% Methods
Sim.methodList = {'SP', 'NPFC', 'MFFC', 'IMFC', 'PFFC'}; % 'SP', , 'IMFC',
Sim.nMethods = length(Sim.methodList);
Sim.forecastModels = 'FFNN';

%% Forecast training options
trainControl.nNodes = 50;                % For the forecast models
trainControl.nStart = 3;                % No. of NN initializations
trainControl.minimiseOverFirst = Sim.k;
trainControl.suppressOutput = false;
trainControl.mseEpochs = 4000;
trainControl.maxTime = 20*60;           % Allow max of n minutes to train NN

trainControl.performanceDifferenceThreshold = 0.05;
trainControl.nDaysPreviousTrainSarma = 10;
trainControl.useHyndmanModel = false;
trainControl.seasonality = Sim.k;
trainControl.nLags = Sim.k;
trainControl.horizon = Sim.k;
trainControl.trainRatio = 0.8;

% Forecast-free parameters
trainControl.nTrainShuffles = 15;                    % # of shuffles to consider
trainControl.nDaysSwap = floor(Sim.nDaysTrain/4);   % pairs of days to swap per shuffle
trainControl.nNodesFF = 50; %ceil(trainControl.nNodes*2);  % For fcast-free controller
trainControl.nRecursive = 1;

%% MPC options
MPC.secondWeight = 0;% 1e-4;       % Of secondary objective
MPC.knowDemandNow = false;         % Is current demand known to controller?
MPC.clipNegativeFcast = true;
MPC.iterationFactor = 1.0;         % To apply to default maximum iterations
MPC.rewardMargin = true;           % Reward margin from creating a new peak?
MPC.SPrecourse = true;             % Whether or not to allow set point recourse
MPC.billingPeriodDays = 7;
MPC.resetPeakToMean = true;
MPC.chargeWhenCan = false;
MPC.suppressOutput = trainControl.suppressOutput;
MPC.UPknowFuture = false;

Sim.trainControl = trainControl;    % A bit hacky... keep a copy of trainControl along with Sim settings

%% Data filename
dataFileWithPath = ...
    ['..' filesep 'data' filesep 'demand_3639.mat'];

Sim.visiblePlots = 'on';

%% Misc.
rng(42);

%% Produce 'derived' values:
Sim.stepsPerDay = Sim.stepsPerHour*Sim.hoursPerDay;
Sim.nHoursTrain = Sim.hoursPerDay*Sim.nDaysTrain;
Sim.nHoursTest = Sim.hoursPerDay*Sim.nDaysTest;

nCustString = '';
for ii = 1:length(Sim.nCustomers);
    nCustString = [nCustString num2str(Sim.nCustomers(ii)) '_'];
    %#ok<*AGROW>
end

if MPC.knowDemandNow
    CDstring = '_withCD';
else
    CDstring = '_noCD';
end

Sim.intermediateFileName = [Sim.resultsDir filesep 'nCust_' ...
    nCustString '_batt_' num2str(100*Sim.batteryCapacityRatio) ...
    'pc__nAgg_' num2str(Sim.nAggregates) CDstring '_intermediate.mat'];

Sim.finalFileName = [Sim.resultsDir filesep 'nCust_' nCustString...
    '_batt_' num2str(100*Sim.batteryCapacityRatio) 'pc__nAgg_' ...
    num2str(Sim.nAggregates) CDstring '.mat'];
