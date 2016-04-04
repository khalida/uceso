[X,T] = simpleseries_dataset;
recNet = layrecnet(1:2,10);
X = con2seq([cell2mat(X); cell2mat(X)]);

[Xs,Xi,Ai,Ts] = preparets(recNet,X,T);
recNet = train(recNet,Xs,Ts,Xi,Ai);
view(recNet);
Y = recNet(Xs,Xi,Ai);
perf = perform(recNet,Y,Ts);
disp('Perfromance:');
disp(perf);


%% Original training example:

[X,T] = simpleseries_dataset;
net = layrecnet(1:2,10);
[Xs,Xi,Ai,Ts] = preparets(net,X,T);
net = train(net,Xs,Ts,Xi,Ai);
view(net)
Y = net(Xs,Xi,Ai);
perf = perform(net,Y,Ts);


%% Phoneme example:
load phoneme
p = con2seq(y);
t = con2seq(t);
lrn_net = layrecnet(1,8);
lrn_net.trainFcn = 'trainbr';
lrn_net.trainParam.show = 5;
lrn_net.trainParam.epochs = 50;
lrn_net = train(lrn_net,p,t);

y = lrn_net(p);
plot(cell2mat(y))