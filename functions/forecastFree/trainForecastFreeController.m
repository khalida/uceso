function [ pars ] = trainForecastFreeController( demandValuesTrain, ...
    Sim, MPC)

% trainForecastFreeController: Train a forecast free controller
%   Given the Sim parameters, details of the plant to be
%   controlled and a time-series of historic demand data.

trainControl = Sim.trainControl;

%% Seperate training data into initialization (1-day) and training (rest)
initializationIdxs = 1:Sim.trainControl.nLags;
demandDelays = demandValuesTrain(initializationIdxs, :);

demandValuesTrainOnly = demandValuesTrain(setdiff(...
    (1:length(demandValuesTrain)),initializationIdxs), :);


%% Create the godCast for training data
demandGodCast = createGodCast(demandValuesTrainOnly, Sim.k);
nTrainIdxs = size(demandGodCast, 1);
demandValuesTrainOnly = demandValuesTrainOnly(1:nTrainIdxs);

%% Set-up parameters for on-line simulation
Sim.hourNumberTrainOnly = Sim.hourNumberTrain(setdiff(...
    (1:length(demandValuesTrain)), initializationIdxs));

meanKWh = mean(demandValuesTrainOnly);
batteryCapacity = meanKWh*Sim.batteryCapacityRatio*Sim.stepsPerDay;
maximumChargeRate = Sim.batteryChargingFactor*batteryCapacity;


%% Simulate Model to create training examples
[ featureVectors, decisionVectors] = ...
    mpcGenerateForecastFreeExamples( demandGodCast, ...
    demandValuesTrainOnly, batteryCapacity, maximumChargeRate, ...
    demandDelays, Sim, MPC);

allFeatureVectors = zeros(size(featureVectors, 1), length(...
    demandValuesTrainOnly)*(trainControl.nTrainShuffles + 1));

allDecisionVectors = zeros(size(decisionVectors, 1), length(...
    demandValuesTrainOnly)*(trainControl.nTrainShuffles + 1));

allFeatureVectors(:, 1:length(demandValuesTrainOnly)) = featureVectors;
allDecisionVectors(:, 1:length(demandValuesTrainOnly)) = decisionVectors;

offset = length(demandValuesTrainOnly);

%% Continue generating examples with suffled versions of training data:
for eachShuffle = 1:trainControl.nTrainShuffles
    
    %% DEBUGGING:
    disp(['Shuffle done, of: ' num2str(trainControl.nTrainShuffles)]);
    disp(eachShuffle);
    
    newDemandValuesTrain = demandValuesTrainOnly;
    for eachSwap = 1:trainControl.nDaysSwap
        thisSwapStart = randi(length(demandValuesTrainOnly) - 2*Sim.k);
        tmpDem = newDemandValuesTrain(thisSwapStart + (1:Sim.k));
        newDemandValuesTrain(thisSwapStart + (1:Sim.k)) = ...
            newDemandValuesTrain(thisSwapStart + (1:Sim.k) + Sim.k);
        
        newDemandValuesTrain(thisSwapStart + (1:Sim.k) + Sim.k) = tmpDem;
    end
    
    [ featureVectors, decisionVectors] = ...
        mpcGenerateForecastFreeExamples( demandGodCast, ...
        demandValuesTrainOnly, batteryCapacity, maximumChargeRate, ...
        demandDelays, Sim, MPC);
    
    allFeatureVectors(:, offset + (1:length(demandValuesTrainOnly))) = ...
        featureVectors;
    
    allDecisionVectors(:, offset + (1:length(demandValuesTrainOnly))) = ...
        decisionVectors;
    
    offset = offset + length(demandValuesTrainOnly);
end

%% Train forecast-free RF model based on examples generated
pars = generateForecastFreeController( allFeatureVectors, ...
    allDecisionVectors, Sim);

end
