%% Script to run some simple tests on the Battery class
% Not exhaustive, but useful as a sanity check.
clearvars;

% Create new 10kWh battery, with 10kW (dis)charge rate, and 0.1kWh charge
% states:
cfg.opt.statesPerKwh = 10;
cfg.type = 'oso';
cfg.sim.batteryChargingFactor = 1;
cfg.sim.eps = 1e-8;
cfg.sim.stepsPerHour = 2;

% Battery damage model propeties:
cfg.bat.damageModel = 'fixed';      % {'fixed', 'staticMultifactor', 'dynamicMultifactor'}
cfg.bat.nominalCycleLife = 1825;    % 5yrs, 1 cycle (charge/discharge) per day
cfg.bat.nominalDoD = 80;            % 10% - 90% cycle
cfg.bat.nominalSoCav = 50;
cfg.bat.maxLifeHours = 7*365.25*24; % 7yrs

battery = Battery(cfg, 10);

% Check single charge correct of 1kWh
startingEnergy = battery.SoC;
battery.chargeStep(10, 0);
pass1 = isequal(battery.SoC, startingEnergy + 1);

% Check multiple charge correct
battery = Battery(cfg, 10);
chargeBy = randi([-5, 5], [5, 1]);
startingEnergy = battery.SoC;
for idx = 1:length(chargeBy)
    battery.chargeStep(chargeBy(idx), 0);
end
pass2 = closeEnough(battery.SoC, startingEnergy + sum(chargeBy)*...
    battery.increment, cfg.sim.eps);

% Check SoC violation works
pass3 = false;
battery = Battery(cfg, 10);
try
    battery.chargeStep(100, 0);
catch ME
    pass3 = true;
end

% Check RoC violation works
pass4 = false;
cfg.sim.batteryChargingFactor = 1e-5;
battery = Battery(cfg, 10);
try
    battery.chargeStep(1);
catch ME
    pass4 = true;
end

if pass1 && pass2 && pass3 && pass4
    disp('test_Battery_mmd PASSED (oso type)!');
else
    error('test_Battery_mmd FAILED');
end
