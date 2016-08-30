h = gcf;
axesObjs = get(h, 'Children');
dataObjs = get(axesObjs, 'Children');

for eachObj = 1:length(dataObjs)
    % objTypes(eachObj) = dataObjs{eachObj}(2);
    objTypes(eachObj) = dataObjs{eachObj}(1);
end

corrCoefs = zeros(length(objTypes), 1);
nPoints = zeros(length(objTypes), 1);

for eachScatter = 1:length(objTypes)
    xdata = get(objTypes(eachScatter), 'XData');
    ydata = get(objTypes(eachScatter), 'YData');
    correlation = corrcoef(xdata', ydata');
    corrCoefs(eachScatter) = correlation(2,1);
    nPoints(eachScatter) = length(xdata);
end

disp('Coefficients: ');
disp(corrCoefs);

disp('nPoints: ');
disp(nPoints);
