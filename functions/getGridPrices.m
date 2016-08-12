function [importPrice, exportPrice] = getGridPrices(cfg, hourNow)

if hourNow > (cfg.fc.seasonalPeriod-1) || hourNow < 0
    error('Hour index is out of bounds');
end

% getGridPrices: Look-up function to return the grid-prices:
exportPrice = cfg.sim.importPrice; % $/kWh
importPrice = cfg.sim.exportPriceLow; % $/kWh

% set imports to peak tarriff if required 7AM = 10PM
if hourNow >= cfg.sim.firstHighPeriod && hourNow <= cfg.sim.lastHighPeriod
    importPrice = cfg.sim.exportPriceHigh;
end

end
