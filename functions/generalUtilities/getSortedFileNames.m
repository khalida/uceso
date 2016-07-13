function [ filenames ] = getSortedFileNames( folderName )
%getSortedFileNames: Get a cell-array with filenames from the folder passed
%in

list = dir(folderName); %get info of files/folders in 'folderName'
isfile = ~[list.isdir]; %determine index of files vs folders
filenames = {list(isfile).name}; %create cell array of file names
filenames = natsortfiles(filenames); % Sort filenames into 'natural' order:

end
