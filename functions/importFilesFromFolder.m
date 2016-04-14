function [ unixTime, allValues ] = importFilesFromFolder( folderName, ...
    maxNoFilesToImport )

%IMPORTFILESFROMFOLDER Imports all files from 'folderName' up to a maximum
%of 'maxNoFilesToImport

% OUTPUT:
% unixTime:     [nIntervals x 1] vector of unix timestamps
% allValues:    [nIntervals x nInstances] matrix of values

%% Get list of filenames
list = dir(folderName); %get info of files/folders in 'folderName'
isfile = ~[list.isdir]; %determine index of files vs folders
filenames = {list(isfile).name}; %create cell array of file names
nFiles = length(filenames);

%% Pre-allocate
if nFiles > 0
    nIntervals = str2double(perl('countlines.pl',...
        [folderName filenames{1}]));
else
    error('No files found');
end

unixTime = zeros(nIntervals, 1);
if maxNoFilesToImport <= nFiles
    allValues = zeros(nIntervals, maxNoFilesToImport);
else
    allValues = zeros(nIntervals, nFiles);
end

%% Read in the data (checking that timestamp arrays match
for eachFile = 1:min(nFiles, maxNoFilesToImport)
    [unixTime, allValues(:, eachFile)] =...
        importSingleFile([folderName filenames{eachFile}]);
    if eachFile > 1
        if ~isequal(unixTime, oldUnixTime)
            error('Unix timestamp vectors of two files didnt match');
        end
    end
    oldUnixTime = unixTime;
end

end
