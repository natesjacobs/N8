function n8load_SnR_triggered(savename)
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
    try
        savename = ['n8data_' savename];
    catch
        error('Please specify string input for filename')
    end
end
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
NOTES.Triggers = [0.5 0.7 0.9 1.1 1.3]; %5 Hz stim with 0.5 sec bl
ntrig = 5;

%bit depth
NOTES.Constant(1) = 1.905e-4; %accounts for bit depth (16-bit -5V to +5V) and gain (200) for standard SnR parameters
NOTES.Units{1} = 'mV';

%% Get filenames
disp('| Getting File Names');
pause(0.5);
[files,path] = uigetfile('F*.mat','Choose files for subject/condition','MultiSelect','on');

%% Pre-allocate memory % get sample rates
%load first file in list
load([path files{1}]);
%sample rate
SR=CRAW_001_KHz*1e3;
%calculate size of 4th dimension(assumes same recording length for all files)
d4 = 2*SR;
%preallocate data
disp('| Preallocating memory');
DATA.Raw=int32(nan(sch(1),sch(2),sch(3),d4,1,1,length(files),sch(4)));
NOTES.Files={};

%%  Load files
disp('| Loading files into N8 array');
d7count=0;
for i=1:length(files)
    %load data file
    clearvars C*
    load([path files{i}]);
    %get triggers
    if exist('CTTL_050_KHz','var') %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        disp(['|   File ' num2str(i)]);
        t=CTTL_050_Up; %get triggers
        t=t(1:ntrig:end); %remove subtriggers
        t=t/(CTTL_050_KHz*1e3); %convert to sec
        t=t-0.5; %shift back by buffer (0.5 sec)
        t=t+CTTL_050_TimeBegin; %convert to time from beginning of session
        t=t-CRAW_001_TimeBegin; %convert to time from beginning of this file
        t=t*SR; %convert to elements (of recording traces)
        win=2*SR;
        %organize recordings into N8 array according to channel list
        %assumes files are contiguous and joins along dim 4 (time)
        for d7=1:length(t)
            d7count=d7count+1;
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
                                DATA.Raw(d1,d2,d3,1:length(data),1,1,d7count,d8) = data;
                            catch
                            end
                        end
                    end
                end
            end
        end
    else
        disp(['|   File ' num2str(i) ' - no triggers']);
        NOTES.Files{end+1}=files{i};
    end
end

%% Save Notes
NOTES.SampleRate = SR;
NOTES.Channels=chlist;
NOTES.FileNames=files;
NOTES.SaveString=savename;

%% Extras & Plot
%create trigger averaged LFP, MUP, and PSTH
n8ephys;
%save .mat file
disp(['| Saving N8 array as ' savename '.mat']);
save(NOTES.SaveString,'DATA','NOTES','STATS','-v7.3');
disp('| Done.');
