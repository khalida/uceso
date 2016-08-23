function plotAsTixz( fileName)
%PLOTASTIXZ Create tikz plot, making use of the matlab2tikz library

cleanfigure('minimumPointsDistance', 0.1);

%% Simple fuinction to save the current figure as a Tikz plot:
% matlab2tikz(fileName, 'height', '\figureheight', 'width', '\figurewidth');

%% My hacked version of matlab2tikz
% Reduce amount of modding required to *.tikz files
myMatlab2tikz(fileName, 'height', '\figureheight', 'width',...
    '\figurewidth', 'floatFormat', '%.2f');

end
