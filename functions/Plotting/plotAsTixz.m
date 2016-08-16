function plotAsTixz( fileName)
%PLOTASTIXZ Create tikz plot, making use of the matlab2tikz library

cleanfigure();

%% Simple fuinction to save the current figure as a Tikz plot:
matlab2tikz(fileName, 'height', '\figureheight', 'width', '\figurewidth');

end
