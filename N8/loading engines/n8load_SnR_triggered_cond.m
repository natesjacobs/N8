function n8load_SnR_triggered_cond(savename)
%Compiles continuous data saved with Alpha Omega SnR to N8 standard format
%Assumes consecutive files are contiguous in time and converts to
%continuous data
%Only loads data for a single subject/condition

%% Variables
clc;

global DATA NOTES STATS

%filename
if nargin<1
    savename = 'n8data_triggered';
else
    savename = ['n8data_' savename];
end
%pre-stim / post-stim time window
win1=0.5; %pre-stim, in sec
win2=1; %post-stim, in sec

%channels:
chlist(1,:,1,1) = [1:4:16,24,20,32,28]; %LI
chlist(1,:,2,1) = [2:4:16,23,19,31,27]; %LII,III
chlist(1,:,3,1) = [3:4:16,22,18,30,26]; %LIV
chlist(1,:,4,1) = [4:4:16,21,17,29,25]; %LV
sch=ones(4,1);
sch(1:length(size(chlist)))=size(chlist); %size of chanel list

%events (e.g. pMCAO)
NOTES.Events = []; %sec from beginning of session

%triggers
NOTES.Triggers = 1:0.01:1.5; %100 Hz stim with 1 sec BL
ntrig = 50;

%bit depth
c=1.905e-4; %accounts for bit depth (16-bit -5V to +5V) and gain (200) for standard SnR parameters

%% Get filenames
disp('Getting File Names');
pause(0.5);
[files,path] = uigetfile('F*.mat','Choose files for subject/condition','MultiSelect','on');

%% Pre-allocate memory % get sample rates
%load first file in list
try
    load([path files{1}]);
catch
    load([path files]);
    files={files};
end
%sample rate
SR=CRAW_001_KHz*1e3;
%calculate size of 4th dimension(assumes same recording length for all files)
d4 = 1.5*SR;
%preallocate data
DATA.Raw=nan(sch(1),sch(2),sch(3),d4,length(files),1,1,sch(4));
%notes
NOTES.SampleRate = SR;
NOTES.Channels=chlist;
NOTES.FileNames=files;
NOTES.SaveString=savename;

%%  Load files
disp('Loading files into N8 array');
d7count=0;
for i=1:length(files)
    %load data file
    clearvars C*
    load([path files{i}]);
    d5=i; %each file is separate condition
    %get triggers
    if exist('CTTL_051_KHz','var') %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        disp(['File ' num2str(i)]);
        t=CTTL_051_Up; %get triggers
        t=t(1:ntrig:end); %remove subtriggers
        t=t/(CTTL_051_KHz*1e3); %convert to sec
        t=t-win1; %shift back by win1
        t=t+CTTL_051_TimeBegin; %convert to time from beginning of session
        t=t-CRAW_001_TimeBegin; %convert to time from beginning of this file
        t=t*SR; %convert to elements
        win=round((win1+win2)*SR);
        %organize recordings into N8 array according to channel list
        %assumes files are contiguous and joins along dim 4 (time)
        for d7=1:length(t)
%             d7count=d7count+1;
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
                            try
                                data=data(round((t(d7):t(d7)+win)));
%                                 DATA.Raw(d1,d2,d3,1:length(data),d5,1,d7count,d8) = data;
                                DATA.Raw(d1,d2,d3,1:length(data),d5,1,d7,d8) = data;
                            catch
                            end
                        end
                    end
                end
            end
        end
    else
        disp(['File ' num2str(i) ' - no triggers']);
        NOTES.Files{end+1}=files{i};
    end
end

%% Ephys analysis
%convert to double
DATA.Raw=double(DATA.Raw)*c;
%get results
n8ephys;
clearvars data
data.LFP=DATA.LFP;
data.rLFP=DATA.rLFP;
data.MUP=DATA.MUP;
data.rMUP=DATA.rMUP;
data.MUPspk=DATA.Timestamps_MUP;
DATA=data;

%% Save
%save .mat file
disp(['Saving N8 array as ' savename '.mat']);
save(NOTES.SaveString,'DATA','NOTES','STATS','-v7.3');
disp('Done.');

