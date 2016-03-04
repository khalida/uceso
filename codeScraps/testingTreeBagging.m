clearvars; close all; clc;

%% SIMPLE MATLAB Classification Exmaple Using TreeBagger()

% load fisheriris;
rng(1); % For reproducibility
% 
% BaggedEnsemble = TreeBagger(50,meas,species,'OOBPred','On');
% oobErrorBaggedEnsemble = oobError(BaggedEnsemble);
% 
% plot(oobErrorBaggedEnsemble)
% 
% xlabel 'Number of grown trees';
% ylabel 'Out-of-bag classification error';

%% Regression example;
nSample = 10000;
trainRatio = 0.75;
nDim = 3;
X = rand(nSample,nDim);
noise = rand(nSample, 1) - 0.5;
Y = [X(:,1) + X(:,2).^2 + X(:,3).^3 + noise]; %,...
    % X(:,3) + X(:,2).^2 + X(:,1).^3 + noise];

randIndexes = randperm(nSample);
nTrainSample = floor(nSample*trainRatio);
trainIndexes = randIndexes(1:nTrainSample);
testIndexes = randIndexes((nTrainSample+1):nSample);

Xtrain = X(trainIndexes, :);
Ytrain = Y(trainIndexes, :);

Xtest = X(testIndexes, :);
Ytest = Y(testIndexes, :);
    
BaggedEnsemble = TreeBagger(1000, Xtrain, Ytrain,'method',...
    'regression', 'OOBPred', 'On').compact;

BaggedEnsemble = BaggedEnsemble.comp;

figure();
oobErrorBaggedEnsemble = oobError(BaggedEnsemble);
plot(oobErrorBaggedEnsemble);

figure();
Ytest_hat = BaggedEnsemble.predict(Xtest);
plot(Ytest, Ytest_hat, '.');
xlabel('Actual Test Responses');
ylabel('Predicted Test Responses');
title('Model-Free Response');
axis equal;
grid on;
disp('Model-free SSE:');
disp(sse(Ytest_hat, Ytest));


figure();
Ytest_hat_model = Xtest(:,1) + Xtest(:,2).^2 + Xtest(:,3).^3;
plot(Ytest, Ytest_hat, '.');
xlabel('Actual Test Responses');
ylabel('Predicted Test Responses');
title('Model-Based Response');
axis equal;
grid on;
disp('Model-based SSE:');
disp(sse(Ytest_hat_model, Ytest));

figure();
% Try a linear regression model of the apporiate parameters
Xlinreg = [ones(size(X(:, 1))), X(:,1), X(:,2).^2, X(:,3).^3];
Xlinreg_train = Xlinreg(trainIndexes, :);
Xlinreg_test = Xlinreg(testIndexes, :);

linRegBeta = (Xlinreg_train'*Xlinreg_train)^-1*Xlinreg_train'*Ytrain;

Ytest_hat_regression = Xlinreg_test*linRegBeta;
plot(Ytest, Ytest_hat_regression, '.');
xlabel('Actual Test Responses');
ylabel('Predicted Test Responses');
title('Linear-Regression Response');
axis equal;
grid on;
disp('Linear Regression SSE:');
disp(sse(Ytest_hat_regression, Ytest));
