function tests = utilitiesTest
%ffnnTest Test suite for FFNN forecasting functions
rng(42);
tests = functiontests(localfunctions);
end

function testCreateGodCast(testCase)
% Test createGodCast

horizonLength = 3;
timeSeries = (0.5:0.5:3)';
actSolution = createGodCast(timeSeries, horizonLength);

expSolution = [0.5 1.0 1.5; 1.0 1.5 2.0; 1.5 2.0 2.5; 2.0 2.5 3.0; ...
    2.5 3.0 0.5; 3.0 0.5 1.0];

verifyEqual(testCase,actSolution,expSolution, 'RelTol', 1e-6);

end

function testMpcController(testCase)
% Test mpcController
disp('mpcController test still to be implemented');
% verifyEqual(testCase,actSolution,expSolution, 'AbsTol', 1e-10);
end

function testControllerOptimizer(testCase)
% Test controllerOptimizer
disp('controllerOptimizer test still to be implemented');
% verifyEqual(testCase,actSolution,expSolution, 'AbsTol', 1e-10);
end

% function setupOnce(testCase)  % do not change function name
% % set a new path, for example
% end
%
% function teardownOnce(testCase)  % do not change function name
% % change back to original path, for example
% end
%
% function setup(testCase)  % do not change function name
% % open a figure, for example
% end
%
% function teardown(testCase)  % do not change function name
% % close figure, for example
% end