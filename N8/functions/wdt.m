function bw = wdt(bw)
%Converts binary image into segments using watershed distance transform
%objects in ouput image all have same integer value, starting with 2
%background = 1, object border = 0;

%check if image is binary
if ~islogical(bw)
    error('input needs to be binary image (logical array)');
end

%% Distance transform
bw=bwdist(~bw);
bw=n8ssmooth(bw);
bw(bw==0) = -Inf;

%% Watershed transform
%invert values
bw(bw>0)=-bw(bw>0)^4;
bw = watershed(-bw);

%% If no objects then 

%% Clean up
%remove borders
bw(bw==0)=1;
%fix count
bw=bw-1;
