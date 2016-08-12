%% Script to run some simple tests on the Battery class
% Not exhaustive, but useful as a sanity check.
clearvars;

% Create new 10kWh battery, with 10kW (dis)charge rate:
cfg.type = 'minMaxDemand';
cfg.sim.batteryChargingFactor = 1;
cfg.sim.eps = 1e-8;
cfg.sim.stepsPerHour = 2;

battery = Battery(getCfgForController(cfg), 10);

% Check single charge correct
startingEnergy = battery.SoC;
battery.chargeBy(1);
pass1 = isequal(battery.SoC, startingEnergy + 1);

% Check multiple charge correct
battery = Battery(getCfgForController(cfg), 10);
chargeBy = rand(5, 1)-0.5;
startingEnergy = battery.SoC;
for idx = 1:length(chargeBy)
    battery.chargeBy(chargeBy(idx));
end
pass2 = closeEnough(battery.SoC, startingEnergy + sum(chargeBy), ...
    cfg.sim.eps);

% Check SoC violation works
pass3 = false;
battery = Battery(getCfgForController(cfg), 10);
try
    battery.chargeBy(10);
catch ME
    pass3 = true;
end

% Check RoC violation works
pass4 = false;
cfg.sim.batteryChargingFactor = 1e-5;
battery = Battery(getCfgForController(cfg), 10);
try
    battery.chargeBy(1);
catch ME
    pass4 = true;
end

if pass1 && pass2 && pass3 && pass4
    disp('test_Battery_mmd PASSED (mmd type)!');
else
    error('test_Battery_mmd FAILED');
end
