function trace_filt = n8butterworth(trace,F)
%Operates along 4th dimension (time) of N8 array
%specify filter type with frequency input (F):
    %lowpass:   -300
    %highpass:  300
    %bandpass:  [1 300]
    %bandstop:  [55 65]*-1
global NOTES

%% Collapse N8 array except time (dim 4)
%make double
trace=double(trace);
%get dimensions
d=size(trace);
%move dim 4 to dim1
trace=permute(trace,[4,1,2,3,5,6,7,8]);
%get new dimensions
d2=size(trace);
%reshape into n x m matrix
trace=reshape(trace,[d(4) (prod(d)/d(4))]);

%% Remove NaNs
%remove NaNs
trace_nan=isnan(trace);
trace(trace_nan)=0;

%% Create butterworth filter
%nth order
n=2;
%filter type type
if length(F)==1 && F<0
    ftype='low';
elseif length(F)==1 && F>0
    ftype='high';
elseif length(F)>1 && all(F>0)
    ftype='bandpass';
elseif length(F)>1 && any(F<0)
    ftype='stop';
end
%Remove negatives (used to specify ftype)
F=abs(F);
%Convert from Hz to elements
Wn=(F*2)/NOTES.SampleRate;
%Create filter (based on example from MATLAB)
[z, p, k] = butter(n,Wn,ftype);
[sos,g]=zp2sos(z,p,k);
hd=dfilt.df2sos(sos,g);


%% Filter data with zero phase shift (filtfilt)
%get SOS matrix
a=hd.sosMatrix;
if length(F)==1
    a=a'; %fix to avoid warning
end
%get Scale values
b=hd.ScaleValues;
%filter data
for i=1:size(trace,2)
    trace_filt(:,i) = filtfilt(a,b,trace(:,i));
end

%% Replace NaNs & Reshape aray
%replace NaNs
trace_filt(trace_nan)=NaN;
%reshape N8 array
trace_filt=reshape(trace_filt,d2);
trace_filt=permute(trace_filt,[2,3,4,1,5,6,7,8]);




