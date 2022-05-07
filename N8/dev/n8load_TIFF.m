function n8load_isoi(savename)
%Organizes data from tiff files into N8 architecture

%% User variables
Triggers = 15; %is 16, but minus 1 after removing first frame
BinSize = 5;
if nargin<1
    savename=[]; 
end

%% Select files
%move out of current folder
folder=cd;
cd ..
%get files
files=getfilenames2;
NOTES.FileNames = files;
%return to current folder
cd(folder);

%% Load data
%select data
for d6=1:length(files)
    for d5=1:length(files(d6).paths) %d5=condition
        disp(files(d6).paths{d5});
        [tempdata,NOTES.ImageSpecs{d5,d6}] = IMimport(files(d6).paths{d5});
        %transpose, fliplr to match V++ format
        tempdata=tempdata';
        tempdata=fliplr(tempdata);
        %remove first frame
        tempdata=tempdata(:,:,2:end);
        %calculate FC and dxdt
        [a,b] = IMfc(tempdata,Triggers(1),BinSize);  
        %smooth
        a=IMsmooth(a);
        b=IMsmooth(b);
        %save
        DATA.FC(:,:,1,:,d5,d6)=a;
        DATA.dxdt(:,:,1,:,d5,d6)=b;
    end
end

%% Save data
NOTES.Triggers=round(Triggers/BinSize);
NOTES.Dimensions = size(DATA.FC);
NOTES.Threshold = 2.5e-4;
NOTES.SampleRate = 2; %(500 ms frames)
if ischar(savename)
    savename = ['n8data_' savename];
else
    savename = 'n8data';  
end
NOTES.SaveString=savename;
save(savename,'DATA','NOTES','-v7.3');
clear all;
n8load;
