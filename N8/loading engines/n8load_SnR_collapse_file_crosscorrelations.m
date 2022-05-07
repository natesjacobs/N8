function n8load_SnR_collapse_file(savename)
%Compiles continuous data saved with Alpha Omega SnR to N8 standard format
%Assumes consecutive files are contiguous in time and converts to
%continuous data
%Only loads data for a single subject/condition

%% Variables
global NOTES DATA

NOTES.Triggers=60; %INPUT FILE # WHEN OCCLUSION HAPPENED (ie 2 for 2nd file, will be converted to sec later)
NOTES.Triggers=NOTES.Triggers*60; %convert to sec
NOTES.Baseline=[1 60];

%filename
if nargin<1
    savename = 'n8data_crosscorrelation';
else
    savename = ['n8data_' savename];
end

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
[files,path] = uigetfile('F*.mat','Choose files for subject/condition','MultiSelect','on');

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
NOTES.SampleRate=(CRAW_001_KHz*1e3)/22;
d4=length(CRAW_001)/NOTES.SampleRate; %d4=duration of 1 file, use to calculate new sample rate at end

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
    %organize recordings into N8 array according to channel list
    %assumes files are contiguous and joins along dim 4 (time)
    for d1=1:sch(1) %X
        for d2=1:sch(2) %Y
            for d3=1:sch(3) %depth
                k = chlist(d1,d2,d3);
                try
                    eval(['a = CRAW_00' num2str(k) ';']); %%%%%%%%%%%%%%%%%%%%%%%%%%%%
                catch
                    eval(['a = CRAW_0' num2str(k) ';']);
                end
               DATA.Raw(d1,d2,d3,1:ceil(length(a)/22))= a(1:22:end);
            end
        end
    end
    %get ephys results for this file (stored in global DATA)
   % n8ephys;
    n8xcorr(100);
    %get dimensions
    %d=size(DATA.Raw);
    
    %only save 1 data point per file for each data type:
    %cross correlations
    data.r(:,:,:,i)=mean(DATA.R,4);
    data.t(:,:,:,i)=mean(DATA.T,4);
    %rLFP / rMUP
    %data.rLFP(:,:,:,i)=mean(DATA.rLFP,4)*c;
    %data.rMUP(:,:,:,i)=mean(DATA.rMUP,4)*c;
    %spikes
    %data.MUPspk(:,:,:,i)=DATA.MUPspk/d4;
    %data.LFPspk(:,:,:,i)=DATA.LFPspk/d4;
    %FFT (delta, theta, gamma)
    %average of 1 sec bins
    %data.FFTdelta(:,:,:,i)=mean(DATA.FFTdelta(:,:,:,1,1,1,1,1),4);
    %data.FFTtheta(:,:,:,i)=mean(DATA.FFTtheta(:,:,:,1,1,1,1,1),4); 
    %data.FFTgamma(:,:,:,i)=mean(DATA.FFTgamma(:,:,:,1,1,1,1,1),4);
end

%% Save
%new sample rate (1 sample per file)
NOTES.SampleRate=1/d4;
%compile NOTES
NOTES.Channels=chlist;
NOTES.Dimensions = ones(1,8);
%NOTES.Dimensions(1:length(size(data.rLFP))) = size(data.rLFP);
NOTES.FileNames=files;
NOTES.FrameCount=20;
%rename data
DATA=data;
%save .mat file
disp(['Saving N8 array as ' savename '.mat']);
save(savename,'DATA','NOTES','-v7.3'); %matlab forces you to use compression for data files >2GB :(
disp('Done.');
