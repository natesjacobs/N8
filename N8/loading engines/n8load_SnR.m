function n8load_SnR
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
clc;
disp('Getting File Names');
%files to load
[files,path] = uigetfile('F*.mat','Choose files for subject/condition','MultiSelect','on');
%new N8 data file name
savename = 'n8data_continuous';


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
d4=length(CRAW_001)/NOTES.SampleRate; %d4=duration of 1 file
NOTES.Triggers=d4*10; %end of third file is pMCAO

%%  Load files
disp('Loading files into N8 array');
for i=1:length(files)
    %load data file
    disp(['File ' num2str(i)]);
    load([path files{i}]);
    %element counter
    e=1;
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
                    DATA.Raw(d1,d2,d3,e:e+length(data)-1,1,1,1,d8) = data(1,1:22:end);
                end
            end
        end
    end
    %Advance element count
    e=e + floor(length(data)/22); %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end

%% Save Notes
NOTES.SampleRate = NOTES.SampleRate/22;
NOTES.Channels=chlist;
NOTES.FileNames=files;
NOTES.SaveString=savename;

%% Extras & Plot
%create trigger averaged LFP, MUP, and PSTH
disp('Calculating ephys results');
n8ephys(0);
%save .mat file
disp(['Saving N8 array as ' savename '.mat']);
save(NOTES.SaveString,'DATA','NOTES','-v7.3');
disp('Done.');
