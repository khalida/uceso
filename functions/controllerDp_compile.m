% CONTROLLERDP_COMPILE   Generate MEX-function controllerDp_mex from
%  controllerDp.
% 
% Script generated from project 'controllerDp.prj' on 17-Aug-2016.
% 
% See also CODER, CODER.CONFIG, CODER.TYPEOF, CODEGEN.

%% Create configuration object of class 'coder.MexCodeConfig'.
cfg = coder.config('mex');
cfg.GenerateReport = true;

%% Define argument types for entry-point 'controllerDp'.
ARGS = cell(1,1);
ARGS{1} = cell(5,1);
ARGS{1}{1} = struct;
ARGS{1}{1}.sim = struct;
ARGS{1}{1}.sim.horizon = coder.typeof(0);
ARGS{1}{1}.sim.stepsPerHour = coder.typeof(0);
ARGS{1}{1}.sim.batteryChargingFactor = coder.typeof(0);
ARGS{1}{1}.sim.eps = coder.typeof(0);
ARGS{1}{1}.sim.batteryEtaC = coder.typeof(0);
ARGS{1}{1}.sim.batteryEtaD = coder.typeof(0);
ARGS{1}{1}.sim.updateBattValue = coder.typeof(false);
ARGS{1}{1}.sim.minCostDiff = coder.typeof(0);
ARGS{1}{1}.sim.importPriceHigh = coder.typeof(0);
ARGS{1}{1}.sim.importPriceLow = coder.typeof(0);
ARGS{1}{1}.sim.exportPrice = coder.typeof(0);
ARGS{1}{1}.sim.firstHighPeriod = coder.typeof(0);
ARGS{1}{1}.sim.lastHighPeriod = coder.typeof(0);
ARGS{1}{1}.sim = coder.typeof(ARGS{1}{1}.sim);
ARGS{1}{1}.bat = struct;
ARGS{1}{1}.bat.costPerKwhUsed = coder.typeof(0);
ARGS{1}{1}.bat.damageModel = coder.typeof('X',[1 5]);
ARGS{1}{1}.bat.nominalCycleLife = coder.typeof(0);
ARGS{1}{1}.bat.nominalDoD = coder.typeof(0);
ARGS{1}{1}.bat.maxLifeHours = coder.typeof(0);
ARGS{1}{1}.bat = coder.typeof(ARGS{1}{1}.bat);
ARGS{1}{1}.fc = struct;
ARGS{1}{1}.fc.seasonalPeriod = coder.typeof(0);
ARGS{1}{1}.fc = coder.typeof(ARGS{1}{1}.fc);
ARGS{1}{1}.type = coder.typeof('X',[1 3]);
ARGS{1}{1}.opt = struct;
ARGS{1}{1}.opt.statesPerKwh = coder.typeof(0);
ARGS{1}{1}.opt = coder.typeof(ARGS{1}{1}.opt);
ARGS{1}{1} = coder.typeof(ARGS{1}{1});
ARGS{1}{2} = coder.typeof(0,[48 48],[1 1]);
ARGS{1}{3} = coder.typeof(0,[48 48],[1 1]);
ARGS{1}{4} = struct;
ARGS{1}{4}.cfg = struct;
ARGS{1}{4}.cfg.sim = struct;
ARGS{1}{4}.cfg.sim.horizon = coder.typeof(0);
ARGS{1}{4}.cfg.sim.stepsPerHour = coder.typeof(0);
ARGS{1}{4}.cfg.sim.batteryChargingFactor = coder.typeof(0);
ARGS{1}{4}.cfg.sim.eps = coder.typeof(0);
ARGS{1}{4}.cfg.sim.batteryEtaC = coder.typeof(0);
ARGS{1}{4}.cfg.sim.batteryEtaD = coder.typeof(0);
ARGS{1}{4}.cfg.sim.updateBattValue = coder.typeof(false);
ARGS{1}{4}.cfg.sim.minCostDiff = coder.typeof(0);
ARGS{1}{4}.cfg.sim.importPriceHigh = coder.typeof(0);
ARGS{1}{4}.cfg.sim.importPriceLow = coder.typeof(0);
ARGS{1}{4}.cfg.sim.exportPrice = coder.typeof(0);
ARGS{1}{4}.cfg.sim.firstHighPeriod = coder.typeof(0);
ARGS{1}{4}.cfg.sim.lastHighPeriod = coder.typeof(0);
ARGS{1}{4}.cfg.sim = coder.typeof(ARGS{1}{4}.cfg.sim);
ARGS{1}{4}.cfg.bat = struct;
ARGS{1}{4}.cfg.bat.costPerKwhUsed = coder.typeof(0);
ARGS{1}{4}.cfg.bat.damageModel = coder.typeof('X',[1 5]);
ARGS{1}{4}.cfg.bat.nominalCycleLife = coder.typeof(0);
ARGS{1}{4}.cfg.bat.nominalDoD = coder.typeof(0);
ARGS{1}{4}.cfg.bat.maxLifeHours = coder.typeof(0);
ARGS{1}{4}.cfg.bat = coder.typeof(ARGS{1}{4}.cfg.bat);
ARGS{1}{4}.cfg.fc = struct;
ARGS{1}{4}.cfg.fc.seasonalPeriod = coder.typeof(0);
ARGS{1}{4}.cfg.fc = coder.typeof(ARGS{1}{4}.cfg.fc);
ARGS{1}{4}.cfg.type = coder.typeof('X',[1 3]);
ARGS{1}{4}.cfg.opt = struct;
ARGS{1}{4}.cfg.opt.statesPerKwh = coder.typeof(0);
ARGS{1}{4}.cfg.opt = coder.typeof(ARGS{1}{4}.cfg.opt);
ARGS{1}{4}.cfg = coder.typeof(ARGS{1}{4}.cfg);
ARGS{1}{4}.SoC = coder.typeof(0);
ARGS{1}{4}.state = coder.typeof(0);
ARGS{1}{4}.capacity = coder.typeof(0);
ARGS{1}{4}.maxChargeRate = coder.typeof(0);
ARGS{1}{4}.maxChargeEnergy = coder.typeof(0,[0 0]);
ARGS{1}{4}.increment = coder.typeof(0);
ARGS{1}{4}.statesInt = coder.typeof(0,[1 17],[0 1]);
ARGS{1}{4}.statesKwh = coder.typeof(0,[1 17],[0 1]);
ARGS{1}{4}.maxDischargeStep = coder.typeof(0);
ARGS{1}{4}.minDischargeStep = coder.typeof(0);
ARGS{1}{4}.eps = coder.typeof(0);
ARGS{1}{4}.cumulativeDamage = coder.typeof(0);
ARGS{1}{4}.cumulativeValue = coder.typeof(0);
ARGS{1}{4} = coder.typeof(ARGS{1}{4});
ARGS{1}{5} = coder.typeof(0);

%% Invoke MATLAB Coder.
codegen -config cfg controllerDp -args ARGS{1}
