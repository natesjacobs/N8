function n8load_SnR_light(savename)
%Compiles continuous data saved with Alpha Omega SnR to N8 standard format
%Assumes consecutive files are contiguous in time and converts to
%continuous data
%Only loads data for a single subject/condition

%% Variables
clc;
global NOTES DATA

%filename
if nargin<1
    savename = 'n8data_cont';
else
    try
        savename = ['n8data_' savename];
    catch
        error('Please specify string input for filename')
    end
end
%channels:
chlist(1,:,1,1) = 1:4:32; %LI
chlist(1,:,2,1) = 2:4:32; %LII,III
chlist(1,:,3,1) = 3:4:32; %LIV
chlist(1,:,4,1) = 4:4:32; %LV
sch=ones(4,1);
sch(1:length(size(chlist)))=size(chlist); %size of chanel list

%events (e.g. pMCAO)
NOTES.Events = []; %sec from beginning of session

%triggers
NOTES.Triggers=[];
NOTES.SubTriggers = [0 200 400 600 800]; %e.g., for 5 Hz stim use [0 200 400 600 800]
ntrig = length(NOTES.SubTriggers);

%bit depth
NOTES.Constant = 1.905e-4; %constant to convert to mV, for SnR it accounts for bit depth (16-bit -5V to +5V) and gain (200) for standard SnR parameters

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
    a{1}=files;
    clearvars files;
    files=a;
end
%calculate size of 4th dimension(assumes same recording length for all files)
d4 = round(length(CRAW_001)/11) * length(files);
%preallocate data
disp('Preallocating memory');
data.LFP=int16(nan(sch(1),sch(2),sch(3),d4,1,1,1,sch(4)));
data.rLFP=int16(nan(sch(1),sch(2),sch(3),d4,1,1,1,sch(4)));
data.Timestamps_MUP=[];
%sample rate
NOTES.SampleRate=CRAW_001_KHz*1e3;

%%  Load files
disp('Loading files into N8 array');
for i=1:length(files)
    %load data file
    disp(['File ' num2str(i)]);
    clearvars C*
    DATA=[];
    try
        load([path files{i}]);
    catch me
        disp('COULD NOT LOAD FILE!');
        disp(me);
        continue;
    end
    %get sample rate
    SR = CRAW_001_KHz * 1e3;
    %restart element count for new conditions
    if i==1
        y = 0;
    end
    %save triggers
    if exist('CTTL_050_KHz','var') %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        t=CTTL_050_Up; %get triggers
        t=t/(CTTL_050_KHz*1e3); %convert to sec
        t=t+CTTL_050_TimeBegin; %convert to time from beginning of session
        t=t-CRAW_001_TimeBegin; %convert to time from beginning of this file
        t=t*SR; %convert to elements (of recording traces)
        t=t+y*11; %convert to elements from beginning of entire session/condition (assumes files are contiguous)
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
                        eval(['a = CRAW_00' num2str(k) ';']); %%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    catch
                        eval(['a = CRAW_0' num2str(k) ';']);
                    end
                    DATA.Raw(d1,d2,d3,1:length(a),1,1,1,d8) = int16(a);
                end
            end
        end
    end
    %get ephys results for this file (stored in global DATA)
    n8ephys;
    %get dimensions
    d=ones(1,8); 
    d(1,1:length(size(DATA.Raw)))=size(DATA.Raw); 
    %spikes
    b=DATA.Timestamps_MUP;
    b(:,4)=b(:,4)+(y*11); %add current time
    data.Timestamps_MUP(end+1:end+size(b),1:8)=b; %save
    %LFP
    temp=int16(DATA.LFP);
    temp=temp(:,:,:,1:11:end,:,:,:,:); %downsample to 2 kHz
    d(4)=size(temp,4);
    data.LFP(1:d(1),1:d(2),1:d(3),y+1:y+d(4),1:d(5),1:d(6),1:d(7),1:d(8)) = temp;
    %rectified LFP
    temp=int16(DATA.rLFP);
    temp=temp(:,:,:,1:11:end,:,:,:,:); %downsample to 2 kHz
    d(4)=size(temp,4);
    data.rLFP(1:d(1),1:d(2),1:d(3),y+1:y+d(4),1:d(5),1:d(6),1:d(7),1:d(8)) = temp;
    %Advance element count
    y = y + length(temp); %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end

%% Update variables affected by new sample rate
%update sample rate (downsampled to 2 kHz)
NOTES.SampleRate=NOTES.SampleRate/11;
%update spike times for new sample rate
a=data.Timestamps_MUP;
a(:,4)=ceil(a(:,4)/11);
b=a(:,4)<=size(data.LFP,4);
a=a(b,:);
data.Timestamps_MUP=a;
%update spike times for new sample rate
a=NOTES.Triggers;
if ~isempty(a)
    a=ceil(a/11);
    b=a<=size(data.LFP,4);
    a=a(b);
    NOTES.Triggers=a;
end

%% Save
%compile NOTES
NOTES.Channels=chlist;
NOTES.Dimensions = ones(1,8);
NOTES.Dimensions(1:length(size(data.LFP))) = size(data.LFP);
NOTES.FileNames=files;
c=NOTES.Constant(1);
NOTES.Constant=[c c 1];
NOTES.Baseline=[1 NOTES.SampleRate*60*5];
%rename data
DATA=data;
%save .mat file
disp(['Saving N8 array as ' savename '.mat']);
save(savename,'DATA','NOTES','-v7.3'); %matlab forces you to use compression for data files >2GB :(
disp('Done.');
