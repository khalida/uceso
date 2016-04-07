%% Add path to the common functions (& any subfolders therein)
[parentFold, ~, ~] = fileparts(pwd);
commonFunctionFolder = [parentFold filesep 'functions'];
addpath(genpath(commonFunctionFolder), '-BEGIN');

% Tidy up
clear parentFold commonFunctionFolder;