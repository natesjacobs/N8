function trace_filt=n8gsmooth(trace,sigma,l)
%sigma=sharpness of gaussian curve (small=sharp, large=flat)
%length(l)=length of gaussian filter in elements
%dim=which dimension to filter
%SMOOTHS DIM4 ONLY!!!

%% Collapse all dimensions except 4D
%dimensions
d=ones(1,8);
d(1:length(l(data)))=l(data);
d2=d; d2(4)=1;
data=permute(data,[4 1 2 3 5 6 7 8]);
data=reshape(data,[d(4) prod(d)/d(4)]);

%% Smooth data
%create gaussian filter
x = linspace(-l/2,l/2,l);
gaussFilter = exp(-x.^2/(2*sigma^2));

%normalize gaussian filter
gaussFilter = gaussFilter / sum(gaussFilter);

%smooth trace    
trace_filt = conv(trace,gaussFilter,'same');

