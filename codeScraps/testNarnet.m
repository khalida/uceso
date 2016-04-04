%% Example code for running an auto-regressive neural network
% t = simplenar_dataset;
nLags = 1;
horizon = 48;

t = noisySine(5, 48, 2.5, 4800)';
[featVecs, respVecs] = computeFeatureResponseVectors(t,1,horizon);
%( A layer recurrent NN requires an input; use as an input the output time-
% series from 1 interval ago, as output use a complete horizon).

t = con2seq(respVecs);
x = con2seq(featVecs);

t_mdl = con2seq(noisySine(5, 48, 0, 4800)');

% net = narnet(1:2,10);
net = layrecnet(1:nLags,20);
view(net);

[X,Xi,Ai,T] = preparets(net,x,t);

net = train(net,X,T,Xi,Ai);

view(net);
Y = net(X,Xi,Ai);
perf = perform(net,Y,T);
disp('Performance:'); disp(perf);

%%  Do a timeseries plot for visual performance check:
% plot the first time-step results only:
figure();
Y1 = cell2mat(Y); Y1 = Y1(1,:);
T1 = cell2mat(T); T1 = T1(1,:);
M1 = cell2mat(t_mdl((nLags+2):(end-horizon+1)));
plot([Y1; T1; M1; Y1-T1]');
legend('RNN output', 'Targets', 'Noise-free model', 'RNN output - target');
grid on;

%% Closed-loop form
netc = closeloop(net);
view(netc);
[Xc,Xic,Aic,Tc] = preparets(netc,{},{},t);
Yc = netc(Xc,Xic,Aic);


%% Step-ahead form
nets = removedelay(net);
view(net);
[Xs,Xis,Ais,Ts] = preparets(nets,{},{},t);
Ys = nets(Xs,Xis,Ais);


%% Open-loop followed by closed-loop form
[Xo,Xio,Aio,To] = preparets(net,{},{},t);
[Y1,Xfo,Afo] = net(Xo,Xio,Aio);
[netc,Xic,Aic] = closeloop(net,Xfo,Afo);
[Y2,Xfc,Afc] = netc(cell(0,5),Xic,Aic);

