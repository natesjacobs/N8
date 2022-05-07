function n8xcorr(timelag_sec)
%Analyzes local field potentials (LFP) data from RAW global variable
%dataformat input should be string indicating double, int16, etc. 

global NOTES DATA

%% Variables
if nargin<1
    %default time lag = sample rate x 
    timelag_sec=5;
end
%convert timelag to elements
timelag=timelag_sec*NOTES.SampleRate;
%dimensions
d=NOTES.Dimensions{NOTES.CurrentField};

%% Get data
cf=NOTES.Fields{NOTES.CurrentField};
eval(['data=DATA.' cf ';']);
%make single precision
data=single(data);

%% Vectorize locations & other dims
data=reshape(data,[prod(d(1:3)),d(4),prod(d(5:8))]);

%% Cross correlations
%preallocate data
r=nan(prod(d(1:3)),prod(d(1:3)),1,1,prod(d(5:8)));
t=nan(prod(d(1:3)),prod(d(1:3)),1,1,prod(d(5:8)));
%run correlations
for d58=1:prod(d(5:8))
    for k=1:prod(d(1:3));
        tic;
        for i=k:prod(d(1:3))
            [corr,lag]=xcorr(data(k,:)',data(i,:)',timelag,'coeff');
            %find max pos or neg correlation
            [r(k,i,d58),t(k,i,d58)]=max(abs(corr)); 
            %convert max r-value back to +/-
            r(k,i,d58)=corr(t(k,i,d58));
            %convert lag time to index to lag time
            t(k,i,d58)=lag(t(k,i,d58))/NOTES.SampleRate; 
        end
        if toc>10
            disp(k);
        end
    end
end

%% Reshape results
d_new=size(r);
r=reshape(r,[d_new(1:2),1,1,d(5:8)]);
t=reshape(t,[d_new(1:2),1,1,d(5:8)]);

%% Save to globals
eval(['DATA.' cf '_r=r;']);
eval(['DATA.' cf '_lag=t;']);



