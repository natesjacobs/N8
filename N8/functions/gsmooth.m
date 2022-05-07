function trace_filt=gsmooth(trace,sigma,size)
%sigma=sharpness of gaussian curve (small=sharp, large=flat)

%create gaussian filter
x = linspace(-size/2,size/2,size);
gaussFilter = exp(-x.^2/(2*sigma^2));

%normalize gaussian filter
gaussFilter = gaussFilter / sum(gaussFilter);

%smooth trace    
trace_filt = conv(trace,gaussFilter,'same');

