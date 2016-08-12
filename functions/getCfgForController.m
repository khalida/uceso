function cfgForController = getCfgForController(cfg)
% return a reduced version of cfg struct with only required fields

cfgForController.sim.horizon = cfg.sim.horizon;
cfgForController.sim.stepsPerHour = cfg.sim.stepsPerHour;
cfgForController.sim.batteryEtaC = cfg.sim.batteryEtaC;
cfgForController.sim.batteryEtaD = cfg.sim.batteryEtaD;
cfgForController.bat.costPerKwhUsed = cfg.bat.costPerKwhUsed;
cfgForController.sim.minCostDiff = cfg.sim.minCostDiff;
cfgForController.fc.seasonalPeriod = cfg.fc.seasonalPeriod;
cfgForController.sim.importPrice = cfg.sim.importPrice;
cfgForController.sim.exportPriceLow = cfg.sim.exportPriceLow;
cfgForController.sim.exportPriceHigh = cfg.sim.exportPriceHigh;
cfgForController.sim.firstHighPeriod = cfg.sim.firstHighPeriod;
cfgForController.sim.lastHighPeriod = cfg.sim.lastHighPeriod;

% Need to also include those used in definition of Battery object
cfgForController.sim.batteryChargingFactor = cfg.sim.batteryChargingFactor;
cfgForController.sim.eps = cfg.sim.eps;
cfgForController.type = cfg.type;
cfgForController.opt.statesPerKwh = cfg.opt.statesPerKwh;
cfgForController.sim.updateBattValue = cfg.sim.updateBattValue;

% And those used in calcFracDegradation!
cfgForController.bat.damageModel = cfg.bat.damageModel;
cfgForController.bat.nominalCycleLife = cfg.bat.nominalCycleLife;
cfgForController.bat.nominalDoD = cfg.bat.nominalDoD;
cfgForController.bat.maxLifeHours = cfg.bat.maxLifeHours;

end
