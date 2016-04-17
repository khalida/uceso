%% Fit a multinomial regression model for categorical responses with natural ordering among categories.
load('fisheriris.mat')
sp = nominal(species);
sp = double(sp);

[B,dev,stats] = mnrfit(meas,sp);
x = [6.2, 3.7, 5.8, 0.2; 6.2, 3.7, 5.8, 0.2];
pihat = mnrval(B,x);
pihat

%% Ordinal example:
load carbig
X = [Acceleration Displacement Horsepower Weight];
miles = ordinal(MPG,{'1','2','3','4'},[],[9,19,29,39,48]);
[B,dev,stats] = mnrfit(X,miles,'model','ordinal');
disp(B)
disp([B(1:3)'; repmat(B(4:end),1,3)]);

x = X(end,:);
[pihat] = mnrval(B,x,'model','ordinal');
disp(pihat);

LL = pihat - dlow;
UL = pihat + hi;
disp([LL;UL]);