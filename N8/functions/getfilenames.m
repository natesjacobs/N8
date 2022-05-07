function [FilePaths,FileNames] = getfilenames(defaultname,promptstring)

%default values
if nargin<1, promptstring= ''; end
if nargin<1, defaultname= ''; end

%get filenames
FilePaths = {};
FileNames = {};
[fn,root] = uigetfile(defaultname,promptstring,'Multiselect','on');
fnend = length(FilePaths);
if ischar(fn)
    FilePaths{fnend+1} = [root fn];
    FileNames{fnend+1} = [fn];
    disp(['|   ' root fn]);
else
    for i = 1:length(fn)
        FilePaths{fnend+i} = [root fn{i}];
        FileNames{fnend+i} = [fn{i}];
        disp(['|   ' root fn{i}]);
    end
end