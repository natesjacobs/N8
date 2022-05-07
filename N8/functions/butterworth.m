function trace_filt = butterworth(trace,bandpass,samplerate,dim)

%determine which dimension to filter
if nargin<4
    [~,dim]=max(size(trace));
end

%collapse all other dimensions except dim (will reassemble afterwards)
a=size(trace);
b=1:length(a);
c1=b(b~=dim);
c2=a(a~=a(dim));
trace=permute(trace,[dim c1]);
trace=reshape(trace,[a(dim) prod(c2)]);

%find NaNs and replace with 0
trace_nan=isnan(trace);
trace(trace_nan)=0;
        
%make trace double
trace=double(trace);

%bandpass filter parameters
n=2; 
ftype='bandpass';
Wn=bandpass*2/samplerate;

%create butterworth filter
[z, p, k] = butter(n,Wn,ftype);
[sos,g]=zp2sos(z,p,k);
hd=dfilt.df2sos(sos,g);

%filter data (use filtfilt for zero phase shift)
for i=1:size(trace,2)
    trace_filt(:,i) = filtfilt(hd.sosMatrix,hd.ScaleValues,trace(:,i));
end

%replace 0 with NaN
trace_filt(trace_nan)=NaN;

%reorganize data into original structure
trace_filt=reshape(trace_filt,[a(dim) c2]);
d([dim c1])=1:length(a);
trace_filt=permute(trace_filt,d);




