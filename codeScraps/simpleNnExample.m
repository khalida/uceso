%%
clearvars; close all; clc;
p = [-1:.05:1];
t = sin(2*pi*p)+0.1*randn(size(p));
net = feedforwardnet(100,'trainbr');
net.trainParam.showWindow = false;
[net, tr] = train(net,p,t);
a = net(p);
plotregression(t, a);
disp(tr);


%% 
x = -1:0.05:1;
t = sin(2*pi*x) + 0.1*randn(size(x));
net = feedforwardnet(20,'trainbr');
net = train(net,x,t);

%%
[x,t] = simplefit_dataset;
net = fitnet(10);
[net, tr] = train(net,x,t);
view(net)
y = net(x);
perf = perform(net,y,t)