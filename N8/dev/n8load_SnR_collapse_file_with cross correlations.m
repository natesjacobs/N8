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
    savename = 'n8data';
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
NOTES.SampleRate=CRAW_001_KHz*1e3;
d4=length(CRAW_001)/NOTES.SampleRate; %d4=duration of 1 file, use to calculate new sample rate at end
%preallocate data
disp('Preallocating memory');
data.rLFP=nan(sch(1),sch(2),sch(3),length(files));
data.FFTpeak=nan(sch(1),sch(2),sch(3),length(files));
data.FFTdelta=nan(sch(1),sch(2),sch(3),length(files));
data.FFTtheta=nan(sch(1),sch(2),sch(3),length(files));
data.FFTgamma=nan(sch(1),sch(2),sch(3),length(files));
data.rMUP=nan(sch(1),sch(2),sch(3),length(files));
data.Spikes=nan(sch(1),sch(2),sch(3),length(files));

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
                DATA.Raw(d1,d2,d3,1:length(a)) = a;
            end
        end
    end
    %get ephys results for this file (stored in global DATA)
    n8ephys;
    %get dimensions
    d=size(DATA.Raw);
    %only save 1 data point per file for each data type:
    
    %spikes
    b=DATA.Timestamps_spikes;
    b2=DATA.Timestamps_LFP;
    for d1=1:d(1) %X
        for d2=1:d(2) %Y
            for d3=1:d(3) %depth
                %count MU spikes for each channel
                temp=b(:,1:3);
                temp(temp(:,1)==d1,1)=0;
                temp(temp(:,2)==d2,2)=0;
                temp(temp(:,3)==d3,3)=0;
                temp=mean(temp,2);
                data.Spikes(d1,d2,d3,i)=sum(temp(:)==0);
                %count LFP spikes for each channel
                temp=b2(:,1:3);
                temp(temp(:,1)==d1,1)=0;
                temp(temp(:,2)==d2,2)=0;
                temp(temp(:,3)==d3,3)=0;
                temp=mean(temp,2);
                data.LFP_Spikes(d1,d2,d3,i)=sum(temp(:)==0);
            end
        end
    end
    
    %LFP
    data.LFPrms(:,:,:,i)=rms(DATA.LFP,4); %rms
    
    %FFT (peak, delta, theta, gamma)
    %find # elements per hz in FFT
    hz=ceil(DATA.FFTfreq);
    hz=find(hz==1,1,'last');
    %crop FFT to <100 Hz
    p=DATA.FFTpower(:,:,:,:,:,:,:,1:hz*100);
    %find peak (below 20 hz)
    [~,data.FFTpeak(:,:,:,i)]=max(p(:,:,:,1,1,1,1,10:20*hz),[],8); %don't start at first element because of peak at 0 Hz
    %power at delta, theta, gamma
    data.FFTdelta(:,:,:,i)=mean(p(:,:,:,1,1,1,1,1:4*hz),8);
    data.FFTtheta(:,:,:,i)=mean(p(:,:,:,1,1,1,1,6*hz:12*hz),8);
    data.FFTgamma(:,:,:,i)=mean(p(:,:,:,1,1,1,1,40*hz:80*hz),8);
    
    %spatial cross-correlations
    disp(' calculating cross-correlations');
    %vectorize locations
    a=DATA.LFP;
    d=size(a);
    v=d(1)*d(2)*d(3);
    a=reshape(a,[v,d(4)]);
    %cross correlations for all location pairs
    for j=1:v
        for k=1:v
            [corr,lag]=xcorr(a(j,:)',a(k,:)',NOTES.SampleRate/10,'coeff'); %limit lags to within 100 ms
            [mx(k),pk(k)]=max(abs(corr)); %find max pos or neg correlation
            pk(k)=lag(pk(k)); %convert index to lag time
        end
        mx=reshape(mx,[d(2),d(3)]);
        pk=reshape(pk,[d(2),d(3)])/NOTES.SampleRate;
        %remove autocorrelation
        mx=round(mx*1e4)/1e4;
        mx(mx==1)=NaN;
        %make r^2
        mx=mx.^2;
        %average r2 for all locations
        R2all(j)=nanmean(mx(:));
        %average r2 for close 
        [ix1,ix2]=ind2sub([d(2),d(3)],j);
        ix1=(ix1-2):(ix1+2);
        ix2=(ix2-2):(ix2+2);
        ix1=ix1(ix1>0 & ix1<d(2)+1);
        ix2=ix2(ix2>0 & ix2<d(3)+1);
        temp=mx(ix1,ix2);
        R2close(j)=nanmean(temp(:));
        %average r2 for column
        [col,row]=ind2sub([d(2),d(3)],k);
        R2col(j)=nanmean(mx(col,:));
        %average r2 for row (within 2 pixels =1mm, equivalent to distance within columns =0.9mm)
        R2row(j)=nanmean(mx(ix1,row));
    end
    %reshape r coefficients into images
    data.R2all(:,:,:,i)=reshape(R2all,[d(1),d(2),d(3)]);
    data.R2close(:,:,:,i)=reshape(R2close,[d(1),d(2),d(3)]);
    data.R2row(:,:,:,i)=reshape(R2row,[d(1),d(2),d(3)]);
    data.R2col(:,:,:,i)=reshape(R2col,[d(1),d(2),d(3)]);
end

%% Update variables affected by new sample rate
%convert spike counts to firing rate in Hz
data.Spikes=data.Spikes/d4;
%convert FFT peaks to Hz
data.FFTpeak=data.FFTpeak/hz; %peak in Hz
%convert rLFP and rMUP to mV
data.rLFP=data.rLFP*c;
%new sample rate (1 sample per file)
NOTES.SampleRate=1/60;



%% Save
%compile NOTES
NOTES.Channels=chlist;
NOTES.Dimensions = ones(1,8);
NOTES.Dimensions(1:length(size(data.rLFP))) = size(data.rLFP);
NOTES.FileNames=files;
NOTES.FrameCount=20;
%rename data
DATA=data;
%save .mat file
disp(['Saving N8 array as ' savename '.mat']);
save(savename,'DATA','NOTES','-v7.3'); %matlab forces you to use compression for data files >2GB :(
disp('Done.');
