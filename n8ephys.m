function n8ephys(allresultsyesno,spikethreshold)
%Analyzes local field potentials (LFP) data from RAW global variable
%dataformat input should be string indicating double, int16, etc. 

%% Variables
%globals
global NOTES DATA
%samplerate
SR=NOTES.SampleRate;
%input arguments
if nargin<1 || sum(allresultsyesno==[0 1])==0
    allresultsyesno=1;
end
if nargin<2
    spikethreshold=3.5;
end
spikewindow=(2e-3) * NOTES.SampleRate;
allresultsyesno=logical(allresultsyesno);
%Data format
intyesno=isinteger(DATA.Raw);
%convert to double
DATA.Raw=double(DATA.Raw);
    
%% RAW
disp('Calculating ephys results');
disp(' subtracting electrical noise');
noise=butterworth(DATA.Raw,[55 65],SR);
DATA.Raw=DATA.Raw-noise;

%% LFP
disp(' filtering for LFP')
DATA.LFP=butterworth(DATA.Raw,[1 300],SR);
if allresultsyesno
    DATA.rLFP=abs(DATA.LFP);
    threshold=spikethreshold/2;
    spikewindow=SR*0.1;
    [a,b]=n8spikesearch(DATA.LFP,threshold,3,spikewindow);
    DATA.Timestamps_LFP=a;
    DATA.LFPspkcount=b;
    %remove timestamp data if empty
    if isempty(DATA.Timestamps_LFP)
        DATA=rmfield(DATA,'Timestamps_LFP');
    end
end

%% MUP
disp(' filtering for MUP/spikes')
try
    DATA.MUP=butterworth(DATA.Raw,[300 3e3],SR);
    spk=true;
catch
    spk=false;
end
if spk
    %MU spikes
    disp(' detecting spikes')
    [a,b]=n8spikesearch(DATA.MUP,spikethreshold,3,spikewindow);
    DATA.Timestamps_MUP=a;
    if allresultsyesno
        %spike count
        DATA.MUPspkcount=b;
        %rectified MUP
        DATA.rMUP=abs(DATA.MUP); %full wave rectified
    end
end
%remove timestamp data if empty
if isempty(DATA.Timestamps_MUP)
    DATA=rmfield(DATA,'Timestamps_MUP');
end

%% FFT (saved in dim 8)
if allresultsyesno
    disp(' computing FFT')
    [a,b,c,d]=n8fft(DATA.Raw,NOTES.SampleRate);
    DATA.FFT=a;
    DATA.FFTdelta=b;
    DATA.FFTtheta=c;
    DATA.FFTgamma=d;
end

%% Remove Raw/MUP and return to integer if allresults == no
if ~allresultsyesno
    DATA=rmfield(DATA,'Raw');
    DATA=rmfield(DATA,'MUP');
end
if intyesno || ~allresultsyesno
    a=fields(DATA);
    for i=1:length(a)
        if ~strcmp(a{i},'Timestamps_LFP') || ~strcmp(a{i},'Timestamps_MUP')
            eval(['DATA.' a{i} '=int32(DATA.' a{i} ');']);
        end
    end
end

%% Downsample LFP if allresults == no
if ~allresultsyesno
    %conversion rate to get to 1 kHz
    c=NOTES.SampleRate/1e3;
    %downsample LFP 1 kHz
    DATA.LFP=DATA.LFP(:,:,:,round(1:c:end),:,:,:,:);
    %change timestamps to 1 kHz SR
    if isfield(DATA,'Timestamps_LFP')
        DATA.Timestamps_LFP(:,4)=round(DATA.Timestamps_LFP(:,4)/c);
    end
    if isfield(DATA,'Timestamps_MUP')
        DATA.Timestamps_MUP(:,4)=round(DATA.Timestamps_MUP(:,4)/c);
    end
    %update sample rate
    NOTES.SampleRate=1e3;
end

