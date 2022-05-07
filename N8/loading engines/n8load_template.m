function n8load(InitializeYesNo)
%compiles DATA from multiple subjects into one data structure
%allows group means, standard error, etc to be calculated
%Requirements for "n8data" .mat files:
%   1 - 

%% Variables
global NOTES DATA DATAa STATS

%% Load data (choose if multiple n8data files)
datafiles = dir('n8*');
if isempty(datafiles)
    warning('No "n8data" in current folder.');
elseif size(datafiles,1)==1
    clc;
    disp(['loading ' datafiles.name])
    load(datafiles.name);
    NOTES.SaveString=datafiles.name;
elseif size(datafiles,1)>1
    [name,path]=uigetfile('n8data*.mat','Select a "n8data" file to load');
    clc;
    disp(['loading ' name])
    load([path name]);
    NOTES.SaveString=name;
end

%% Initialize?
%check if data needs to be initialized
if ~isfield(NOTES,'Initialize')
    NOTES.Initialize=true;
end
%initialize data if input is 1
if nargin<1
    NOTES.Initialize=false;
else
    NOTES.Initialize=logical(InitializeYesNo);
end

%% Check required fields
if NOTES.Initialize
    %types of data
    DATAa=DATA; %copy for alignment
    NOTES.FieldNames=fields(DATA);
    NOTES.FieldsToInvert=false(length(NOTES.FieldNames),1);
    NOTES.CurrentField=NOTES.FieldNames{1};
    %dimensions
    d=ones(1,8); 
    eval(['d1=size(DATA.' NOTES.FieldNames{1} ');']); 
    d(1:length(d1))=d1;
    NOTES.Dimensions=d;
    NOTES.CurrentDepth=1;
    %crop settings (no cropping by default)
    NOTES.CropX=true(NOTES.Dimensions(1),1);
    NOTES.CropY=true(NOTES.Dimensions(2),1);
    NOTES.CropZ=true(NOTES.Dimensions(3),1);
    %timescale and sample rate
    [~,NOTES.TimeScale]=choosestring('time units in sec or msec?',{'sec' 'msec'});
    NOTES.CurrentTimeWindow=[1 round(d(4)/21) d(4)];
    %stimulus triggers and baseline options
    if ~isfield(NOTES,'Triggers')
        NOTES.Triggers=0;
    end
    %only do this the first time
    NOTES.Initialize=false;
    %save initialized n8 data architecture
    save(NOTES.SaveString,'DATA','DATAa','NOTES','STATS','-v7.3');
end

%% Plot
n8plot;
clc;
display('Type "global DATA DATAa NOTES STATS" to see data in workspace');

