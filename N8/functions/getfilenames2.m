function files = getfilenames2(defaultname,promptstring,multiyesno)

%default values
if nargin<1, defaultname='*'; end
if nargin<2, promptstring='Select first file(s)'; end
if nargin<3, multiyesno=1; end

%convert multiyesno to string
if multiyesno==1
    ms='on';
else
    ms='off';
end

%get files
AddMore = 1;
x=0;
files.paths={};
files.names={};
while AddMore == 1;
    x=x+1;
    files(x).paths = {};
    files(x).names = {};
    [fn root] = uigetfile(defaultname,promptstring,'Multiselect',ms);
    fnend = length(files(x).paths);
    if ischar(fn)
        files(x).paths{fnend+1} = [root fn];
        files(x).names{fnend+1} = [fn];
    else
        for i = 1:length(fn)
            files(x).paths{fnend+i} = [root fn{i}];
            files(x).names{fnend+i} = [fn{i}];
            disp([root fn{i}]);
        end
    end
    AddMore = menu('Add more files?','Yes','No');
end

pause(0.5);