function [ unixTime, allValues ] = importFilesFromFolder(cfg)

%IMPORTFILESFROMFOLDER Imports all files from folders according to cfg
%structure passed int

% OUTPUT:
% unixTime:     [nIntervals x 1] vector of unix timestamps
% allValues:    Struct with .pv[nIntervals x nInstances] matrix of PV
%.demand[nIntervals x nInstances] matrix

%% Directories of PV and demand data:
pvDir = [cfg.osoDataFolder filesep 'PV' filesep];
demandDir = [cfg.osoDataFolder filesep 'demand' filesep];

%% Get list of filenames (& check list is same between folders)
pvFilenames = getSortedFileNames(pvDir);
demandFilenames = getSortedFileNames(demandDir);

nFiles = length(pvFilenames);
if nFiles ~= length(demandFilenames)
    error('No. of PV and demand filenames dont match');
end

for ii = 1:nFiles
    if ~isequal(pvFilenames{ii}((end-5):end), ...
            demandFilenames{ii}((end-5):end))
        error('PV, demand filenames dont match');
    end
end

%% Generate list of indexes to sum over (for each instance)
osoCustIdxs = cell(cfg.sim.nInstances, 1);
instance = 0;
for ii = 1:length(cfg.sim.nCustomers)
    thisNcust = cfg.sim.nCustomers(ii);
    
    for jj = 1:cfg.sim.nAggregates
        instance = instance + 1;
        osoCustIdxs{instance} = randsample(nFiles, thisNcust);
    end
end


%% Read in PV & demand data:
if nFiles > 0
    nIntervalsPv = str2double(perl('countlines.pl',...
        [pvDir pvFilenames{1}]));
    
    nIntervalsDem = str2double(perl('countlines.pl',...
        [demandDir demandFilenames{1}]));
    
    if ~isequal(nIntervalsPv, nIntervalsDem)
        error('nIntervals not matched between PV and demand');
    end
else
    error('No files found');
end

allDemValues = zeros(nIntervalsPv, nFiles);
allPvValues = zeros(nIntervalsPv, nFiles);

%% Read in the data (checking that timestamp arrays match
for eachFile = 1:nFiles
    [unixTimeDem, allDemValues(:, eachFile)] =...
        importSingleFile([demandDir demandFilenames{eachFile}]);
    
    [unixTimePv, allPvValues(:, eachFile)] =...
        importSingleFile([pvDir pvFilenames{eachFile}]);
    
    if eachFile > 1
        if ~isequal(unixTimeDem, oldUnixTimeDem) || ...
                ~isequal(unixTimePv, oldUnixTimePv)
            
            error('Unix timestamp vectors of two files didnt match');
        end
    end
    oldUnixTimeDem = unixTimeDem;
    oldUnixTimePv = unixTimePv;
end

unixTime = unixTimePv;

%% Sum customer combinations
% (to allow testing over a range of signal:noise ratios)
allValues.pv = zeros(nIntervalsPv, cfg.sim.nInstances);
allValues.demand = zeros(nIntervalsPv, cfg.sim.nInstances);

for ii = 1:cfg.sim.nInstances
    allValues.pv(:, ii) = sum(allPvValues(:, osoCustIdxs{ii}), 2);
    allValues.demand(:, ii) = sum(allDemValues(:, osoCustIdxs{ii}), 2);
end


end
