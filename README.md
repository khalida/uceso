# uceso
Repository for the MATLAB code for Unprincipled Controllers for Energy Storage Optimization paper (in draft).

The main files for running the simulations which are in the folder `./mainScripts` which contains the following scripts:

1) `Config.m`
This is a funtion which takes the present working directory as an argument and returns a `cfg` structure with parameters as fields which control the forecasting and optimisation algorithms. It also sets filenames for saving, options for plotting etc.

2) `Main.m`
This runs, in order; (i) forecast (and unprincipled controller) training on historical data; (ii) simulation of forecasts (and associated controller) in an online setting, against unseen test data.

4) `CompareForecasts.m`
Script to evaluate the forecasts used in the study against other bench-mark methods (confirm forecast performance is close to state-of-the-art on the data-set).

5) `TestUnprincipledController.m`
Script which runs a cut-down version of the code, designed to evaluate the performance of the unprincipled controller on artificially generated data. User to confirm that the FFNN models being used for data-driven forecasting and optimization is capable of replacing the conventional (principled) optimization models, provided with a perfect foresight forecast, and also under random uniform zero-mean noise.

In addition to these main scripts there are many functions in the folder `./functions` (and its subfolders); which are called from these scripts.

Note that this is a work-in-progress. At the time this README was last updated the code was not in fully working order.
