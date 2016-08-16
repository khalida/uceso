function cfgForController = getCfgForController(cfg)
% return a reduced version of cfg struct with only required fields
% NB: this is a pain; but required as cannot pass a struct with cellarray
% fields to a compiled mex function!

cfgForController.sim.horizon = cfg.sim.horizon;
cfgForController.sim.stepsPerHour = cfg.sim.stepsPerHour;
cfgForController.bat.costPerKwhUsed = cfg.bat.costPerKwhUsed;
cfgForController.fc.seasonalPeriod = cfg.fc.seasonalPeriod;

% Need to also include those used in definition of Battery object
cfgForController.sim.batteryChargingFactor = cfg.sim.batteryChargingFactor;
cfgForController.sim.eps = cfg.sim.eps;
cfgForController.type = cfg.type;

% And those used in calcFracDegradation!
cfgForController.bat.damageModel = cfg.bat.damageModel;
cfgForController.bat.nominalCycleLife = cfg.bat.nominalCycleLife;
cfgForController.bat.nominalDoD = cfg.bat.nominalDoD;
cfgForController.bat.maxLifeHours = cfg.bat.maxLifeHours;

if strcmp(cfg.type, 'oso')
    cfgForController.opt.statesPerKwh = cfg.opt.statesPerKwh;
    
    cfgForController.sim.batteryEtaC = cfg.sim.batteryEtaC;
    cfgForController.sim.batteryEtaD = cfg.sim.batteryEtaD;
    cfgForController.sim.updateBattValue = cfg.sim.updateBattValue;
    cfgForController.sim.minCostDiff = cfg.sim.minCostDiff;
    
    cfgForController.sim.importPriceHigh = cfg.sim.importPriceHigh;
    cfgForController.sim.importPriceLow = cfg.sim.importPriceLow;
    cfgForController.sim.exportPrice = cfg.sim.exportPrice;
    cfgForController.sim.firstHighPeriod = cfg.sim.firstHighPeriod;
    cfgForController.sim.lastHighPeriod = cfg.sim.lastHighPeriod;
else
    %cfgForController.sim.batteryCapacityRatio = ...
    %    cfg.sim.batteryCapacityRatio;
    
end

end
