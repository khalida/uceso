function [ pars ] = trainForecastFreeController( demandValuesTrain, Sim,...
    trainControl, MPC)

% trainForecastFreeController: Train a forecast free controller
%   Given the trainControl parameters, details of the plant to be
%   controlled and a time-series of historic data.

meanKWh = mean(demandValuesTrain);
k = trainControl.horizon;

%% Seperate training data into initialization (1-day) and training (rest)
nDaysInitialization = 1;
initializationIdxs = 1:(nDaysInitialization*Sim.stepsPerDay);
demandValuesInitialization = demandValuesTrain(initializationIdxs, :);
demandValuesTrainOnly = demandValuesTrain(setdiff(...
    (1:length(demandValuesTrain)),initializationIdxs));

% Create 'historical load pattern' used for initialization etc.
loadPatternInitialization = mean(reshape( demandValuesInitialization, ...
    [k, length(demandValuesInitialization)/k]), 2);

%% Create the godCast for training data
godCast = zeros(size(demandValuesTrainOnly, 1), k);
for ii = 1:k
    godCast(:, ii) = circshift(demandValuesTrainOnly, -[ii-1, 0]);
end

%% Set-up parameters for on-line simulation
batteryCapacity = meanKWh*Sim.batteryCapacityRatio*Sim.stepsPerDay;
maximumChargingRate = Sim.batteryChargingFactor*batteryCapacity;

hourNumberTrainOnly = Sim.hourNumberTrain(setdiff(...
    (1:length(demandValuesTrain)), initializationIdxs));

%% Run On-line Model to create training examples
[ featureVectors, decisionVectors] = ...
    mpcGenerateForecastFreeExamples( godCast, demandValuesTrainOnly, ...
    batteryCapacity, maximumChargingRate, loadPatternInitialization, ...
    hourNumberTrainOnly, Sim.stepsPerHour, k, MPC);

% Check that the number of responses are the same:
if size(featureVectors, 2) ~= size(decisionVectors, 2)
    error('different number of feature and response vectors returned!');
end

allFeatureVectors = zeros(size(featureVectors, 1), ...
    size(featureVectors, 2)*(Sim.nTrainShuffles + 1));

allDecisionVectors = zeros(size(decisionVectors, 1), ...
    size(decisionVectors, 2)*(Sim.nTrainShuffles + 1));

allFeatureVectors(:, 1:size(featureVectors, 2)) = featureVectors;
allDecisionVectors(:, 1:size(decisionVectors, 2)) = decisionVectors;
offset = size(decisionVectors, 2);

%% Continue generating examples with shuffled versions of training data:
for eachShuffle = 1:Sim.nTrainShuffles
    newDemandValuesTrain = demandValuesTrainOnly;
    for eachSwap = 1:Sim.nDaysSwap
        thisSwapStart = randi(length(demandValuesTrainOnly) - 2*k);
        tmp = newDemandValuesTrain(thisSwapStart + (1:k));
        newDemandValuesTrain(thisSwapStart + (1:k)) = ...
            newDemandValuesTrain(thisSwapStart + (1:k) + k);
        newDemandValuesTrain(thisSwapStart + (1:k) + k) = tmp;
    end
    
    [ featureVectors, decisionVectors] = ...
        mpcGenerateForecastFreeExamples( godCast, newDemandValuesTrain, ...
        batteryCapacity, maximumChargingRate, loadPatternInitialization,...
        hourNumberTrainOnly, Sim.stepsPerHour, k, MPC);
    
    allFeatureVectors(:, offset + (1:size(featureVectors, 2))) = ...
        featureVectors;
    
    allDecisionVectors(:, offset + (1:size(decisionVectors, 2))) = ...
        decisionVectors;
    
    offset = offset + size(featureVectors, 2);
end


%% Train forecast free model based on examples generated
pars = generateForecastFreeController( allFeatureVectors, ...
    allDecisionVectors, Sim);

end
