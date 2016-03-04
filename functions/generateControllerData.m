function [forecasts, stateOfCharges, demandNows, peakSoFars] = ...
    generateControllerData(batteryCapacity, MPC, nObservations)

% generateControllerData: Produce random data for passing to controllerOptimizer

forecasts = unifrnd(0, 5, [MPC.horizon, nObservations]);
stateOfCharges = unifrnd(0, batteryCapacity, [1, nObservations]);
demandNows = unifrnd(0, 5, [1, nObservations]);
peakSoFars = unifrnd(2.5, 5, [1, nObservations]);

end
