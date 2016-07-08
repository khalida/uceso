function [importPrice, exportPrice] = getGridPrices(hourNow)

if hourNow > 47 || hourNow < 0
    error('Hour index is out of bounds');
end

% getGridPrices: Look-up function to return the grid-prices:
exportPrice = 0.05; % $/kWh

importPrice = 0.1; % $/kWh

% set imports to peak tarriff if required 7AM = 10PM
if hourNow >= 14 && hourNow <= 43
    importPrice = 0.4;
end

end
