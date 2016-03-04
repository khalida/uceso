function [ mseTest ] = assessNp( demand, trainControl )
% assessNp: Return the average mse for the Naive (Daily) Periodic forecast

nLags = trainControl.horizon;
horizon = trainControl.horizon;

[npForecast, actuals] = computeFeatureResponseVectors(demand, nLags, ...
    horizon);

mseTest = mse(actuals, npForecast);

end

