function battery = getBatteryObject(cfg, nCustomer, data)

if isequal(cfg.type, 'oso')
    if ~isfield(cfg.sim, 'batteryCapacityTotal')
        % Battery size fixed by number of customers:
        battery = Battery(cfg, cfg.sim.batteryCapacityPerCustomer*...
            nCustomer);
    else
        % Constant overall battery size
        battery = Battery(cfg, cfg.sim.batteryCapacityTotal);
    end
else
    % Battery size depends on demand of the aggregation considered
    meanDemand = mean(data.demand(cfg.sim.initIdxs));
    battery = Battery(cfg, meanDemand*cfg.sim.batteryCapacityRatio*...
        cfg.sim.stepsPerDay);
end

end
