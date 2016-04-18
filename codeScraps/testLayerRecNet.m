%% Original training example:

[X,T] = simpleseries_dataset;
net = layrecnet(1:2,10);
[Xs,Xi,Ai,Ts] = preparets(net,X,T);
net = train(net,Xs,Ts,Xi,Ai);
view(net)
Y = net(Xs,Xi,Ai);
perf = perform(net,Y,Ts);
disp(perf);


%% Applied to this data-set:
load(['C:\LocalData\Documents\Documents\PhD\21_Projects\'...
    '2016_04_07_uceso\mainScripts\ctrlrTrainExamples.mat']);

X = mat2cell(featVecsTrain, size(featVecsTrain, 1),...
    ones(size(featVecsTrain, 2), 1));

T = mat2cell(respVecsTrain, size(respVecsTrain, 1), ...
    ones(size(respVecsTrain, 2), 1));

net = layrecnet(1:2,10);

[Xs,Xi,Ai,Ts] = preparets(net,X,T);

net = train(net,Xs,Ts,Xi,Ai);
view(net)

Y = net(Xs,Xi,Ai);
perf = perform(net,Y,Ts);
disp(perf);