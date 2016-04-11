function [ battery ] = makeBattery( meanDemand, cfg )

% makeBattery: Generate a battery object (for now just a structure)

% TODO: would be good to make this proper object; can then use bettery
% updating rules to avoid duplicated code!

battery.capacity = meanDemand*cfg.sim.batteryCapacityRatio*...
    cfg.sim.stepsPerDay;

battery.maximumChargeRate = cfg.sim.batteryChargingFactor*battery.capacity;

battery.maximumChargeEnergy = battery.maximumChargeRate/...
    cfg.sim.stepsPerHour;

end
