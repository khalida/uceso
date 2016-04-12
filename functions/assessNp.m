function [ mseTest, rmsTest ] = assessNp(cfg, demand)
% assessNp: Return the average mse for the Naive (Daily) Periodic forecast

nLags = cfg.fc.nLags;
horizon = cfg.sim.horizon;

[npForecast, actuals] = computeFeatureResponseVectors(demand, nLags, ...
    horizon);

fc = npForecast(1:horizon,:);
mseTest = mse(actuals, fc);
rmsTest = rms(fc(:));

end
