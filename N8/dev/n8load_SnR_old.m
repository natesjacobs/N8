function n8load_SnR(savename)
%Compiles continuous data saved with Alpha Omega SnR to N8 standard format
%Assumes consecutive files are contiguous in time and converts to
%continuous data
%Only loads data for a single subject/condition

%% Variables
global NOTES DATA
%channels:
chlist(1,:,1,1) = 1:4:32; %LI
chlist(1,:,2,1) = 2:4:32; %LII,III
chlist(1,:,3,1) = 3:4:32; %LIV
chlist(1,:,4,1) = 4:4:32; %LV
sch=ones(4,1);
sch(1:length(size(chlist)))=size(chlist); %size of chanel list
%constant to convert units to mV (rLFP and rMUP)
c = 1.905e-4; %constant to convert to mV, for SnR it accounts for bit depth (16-bit -5V to +5V) and gain (200) for standard SnR parameters

%% Get filenames
disp('Getting File Names');
%files to load
[files,path] = uigetfile('F*.mat','Choose files for subject/condition','MultiSelect','on');
%new N8 data file name
if nargin<1
    savename = 'n8data';
else
    savename = ['n8data_' savename];
end

%% Pre-allocate memory % get sample rate
%load first file in list
try
    load([path files{1}]);
catch
    load([path files]);
    a{1}=files;
    clearvars files;
    files=a;
end
%sample rate (leave as continuous until end to avoid error in filtering)
NOTES.SampleRate=CRAW_001_KHz*1e3;
d4=length(CRAW_001)/NOTES.SampleRate; %d4=duration of 1 file, use to calculate new sample rate at end
%preallocate data
disp('Preallocating memory');
data.rLFP=nan(sch(1),sch(2),sch(3),length(files)*length(CRAW_001));
data.rMUP=nan(sch(1),sch(2),sch(3),length(files)*length(CRAW_001));
data.FFTdelta=nan(sch(1),sch(2),sch(3),length(files)*d4);
data.FFTtheta=nan(sch(1),sch(2),sch(3),length(files)*d4);
data.FFTgamma=nan(sch(1),sch(2),sch(3),length(files)*d4);

%%  Load files
disp('| Loading files into N8 array');
for i=1:length(files)
    %load data file
    disp(['|   File ' num2str(i)]);
    load([path files{i}]);
    %get sample rate
    SR = CRAW_001_KHz * 1e3;
    %restart element count for new conditions
    if i==1
        ElementCount = 1;
    end
    %save triggers
    if exist('CTTL_050_KHz','var') %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        t=CTTL_050_Up; %get triggers
        t=t(1:ntrig:end); %remove subtriggers
        t=t/(CTTL_050_KHz*1e3); %convert to sec
        t=t+CTTL_050_TimeBegin; %convert to time from beginning of session
        t=t-CRAW_001_TimeBegin; %convert to time from beginning of this file
        t=t*SR; %convert to elements (of recording traces)
        t=t+ElementCount; %convert to elements from beginning of entire session/condition (assumes files are contiguous)
        NOTES.Triggers(end+1:end+length(t)) = t; %save
    end
    %organize recordings into N8 array according to channel list
    %assumes files are contiguous and joins along dim 4 (time)
    for d1=1:sch(1) %X
        for d2=1:sch(2) %Y
            for d3=1:sch(3) %depth
                for d8=1:sch(4) %n-trode
                    k = chlist(d1,d2,d3,d8);
                    try
                        eval(['data = CRAW_00' num2str(k) ';']); %%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    catch
                        eval(['data = CRAW_0' num2str(k) ';']);
                    end
                    DATA.RAW(d1,d2,d3,ElementCount:ElementCount+length(data)-1,1,1,1,d8) = data;
                end
            end
        end
    end
    %Advance the element count
    ElementCount = ElementCount + length(data); %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end

%% Save Notes
NOTES.SampleRate = SR;
NOTES.Channels=chlist;
NOTES.FileNames=files;
NOTES.SaveString=savename;

%% Extras & Plot
%create trigger averaged LFP, MUP, and PSTH
n8ephys;
%initialize & plot
n8;
%save .mat file
disp(['| Saving N8 array as ' savename '.mat']);
save(NOTES.SaveString,'DATA','NOTES','STATS','-v7.3');
disp('| Done.');
