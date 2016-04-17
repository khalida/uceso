%% Fit a multinomial regression model for categorical responses with natural ordering among categories.
% Load the sample data and define the predictor variables.
tol = 0.9e-3;
[X_Y, colIdxs] = licols([featVecsTrain', respVecsTrain'], tol);

% Create cateogorical response variable
X = X_Y(:, 1:(end - 1));
Y = X_Y(:, end);
Y = ordinal(Y);

% Fit an ordinal response model for the response variable miles.
[B,~,~] = mnrfit(X,Y,'model','ordinal');
disp(B);

X_val = featVecsVal(colIdxs(1:(end-1)), :)';
pihat = mnrval(B,X_val,'model','ordinal');

% Find most probably labels:
[~, maxIdx] = max(pihat,[],2);
plot(respVecsVal, maxIdx', 'o');
xlabel('True Label');
ylabel('Predicted Label');
grid on;
refline(1,0);