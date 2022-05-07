function [FilePaths,FileNames] = n8getfiles(defaultname,promptstring)

%default values
if nargin<1, promptstring= ''; end
if nargin<1, defaultname= ''; end

%get filenames
FilePaths = {};
FileNames = {};
AddMore = 1;
while AddMore == 1;
    [fn root] = uigetfile(defaultname,promptstring,'Multiselect','on');
    if ischar(fn)
        FilePaths{end+1} = [root fn];
        FileNames{end+1} = fn;
        disp(['|   ' root fn]);
    else
        for i = 1:length(fn)
            FilePaths{end+1} = [root fn{i}];
            FileNames{end+1} = fn{i};
            disp(['|   ' root fn{i}]);
        end
    end
    AddMore = menu('Add more files?','Yes','No');
end