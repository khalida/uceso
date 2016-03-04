# iddfo
Repository for the MATLAB code for Integrated Data-Driven Forecasting and Optimization paper (in draft).

The main files for running the simulations which are in the folder `./mainScripts` which contains the following scripts:

1) `Config.m`
This runs a script to set up several structures which control the forecasting and optimisation algorithms. It also sets filename for saving etc.

2) `Main.m`
This runs, in order; (i) forecast training on historical data; (ii) simulation of forecasts (and associated controller) in an online setting.

4) `CompareForecasts.m`
Script to evaluate the FFNN forecasts used in majorigy of the study against other bench-mark methods (confirm performance is state-of-the-art).

5) `CompareOptimization.m`
Script to confirm that the FFNN model being used for intergrated data-driven forecasting and optimization is capable of replacing the conventional (principled) optimization models, provided with a perfect foresight forecast.

In addition to these main scripts there are many functions in the folder `./functions` (and its subfolders); which are called from these scripts.

Note that this is a work-in-progress. At the time this README was last updated the code was not in fully working order.
