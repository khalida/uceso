# uceso
Repository for the MATLAB code for "Integrating Data-Driven Forecasting and Oprimization to Improve the Operation of Distributed Energy Storage" (submitted to IEEE SmartCity 2016).

The main files for running the simulations are in the folder `./mainScripts`:

1) `Config.m`
This is a funtion which takes the present working directory as an argument and returns a `cfg` structure with parameters as fields which control the forecasting and optimisation algorithms. It also sets filenames for saving, options for plotting etc, based on the current date and time. The `cfg` structure is broken into 6 main fields; `cfg.fc, cfg.opt, cfg.sim, cfg.bat, cfg.plt, cfg.sav`, which are each themselves structures controlling the forecasting, optimization, simulation, battery, plotting, and saving aspects of the run. 

2) `Main.m`
This runs, in order; (i) Forecast (and Integrated Forecast and Optimization (IFO)) training on historical data; (ii) Simulation of forecasts (and associated controller) in an online setting, against unseen test data.

4) `CompareForecasts.m`
Script to evaluate the forecasts used in the study against other bench-mark methods (to verify forecast performance is close to state-of-the-art on the data-set, given the available predictor variable inputs).

5) `TestUnprincipledController.m`
Script which runs a cut-down version of the code, designed to evaluate the performance of the IFO controller on artificially generated data. Used to confirm that the FFNN models being used for IFO is capable of replacing the conventional (exact) optimization models, provided with a perfect foresight forecast, and also under random uniform zero-mean noise. This script was used for generating Figures 7 and 8 in the paper.

In addition to these main scripts there are many functions in the folder `./functions` (and its subfolders); which are called from these scripts.

Note that all of this code is "research-quality", so documentation and units tests are quite scant. At the time this README was last updated the code was not in fully working order.

## Getting the data:
In order for the above scripts to work, data-sets for the "Application One" (minMaxDemand) and "Application Two" (oso) problems needs to be put in the `data\dataMmd` and `data\dataOso` folders respectively.

### Application One
The ISSDA CER smart meter customer behaviour trials data must be requested, and can be accessed via the (Irish Social Science Data Archive)[www.ucd.ie/issda]. When it was originally accessed for this work it was delivered as 6 zipped text files `File1.txt` through `File6.txt`. If these are put in the `data\dataMmd` folder and the `importIssdaDataAll.m` is run, it should produce a `demand_3639.mat` file which is used by the rest of the application.

### Application Two
The Ausgrid solar home electricity data, is publically available and can be accessed (online)[http://www.ausgrid.com.au/Common/About-us/Corporate-information/Data-to-share/Solar-home-electricity-data.aspx#.V8PzCEbLHhU]. The data for 2011-2013 should come as a pair of zipped `.csv` files. If these are unzipped, renamed to `2011_2012_Solar_home_electricity_data_v2.csv` and `2012_2013_Solar_home_electricity_data_v2.csv` put in the `data\dataOso\data\AusGrid_data` folder, and the `dataImport` java runnable is run, for example from the command line `java -jar dataImport.jar`, this should produce the data in the format required by the rest of the application.
