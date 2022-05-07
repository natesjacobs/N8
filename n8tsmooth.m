function data=n8tsmooth(data,sigma,l)
%sigma=sharpness of gaussian curve (small=sharp, large=flat)
%length(l)=length of gaussian filter in elements
%dim=which dimension to filter
%SMOOTHS DIM4 ONLY!!!
%can result in issues at edges

%% Variables
if nargin<2
    sigma=5;
end
if nargin<3
    l=10;
end
%dimensions
d=ones(1,8);
d(1:length(size(data)))=size(data);
%class
c=class(data);

%% Create filter
%create gaussian
x = linspace(-l/2,l/2,l);
gaussFilter = exp(-x.^2/(2*sigma^2));
%normalize gaussian filter
gaussFilter = gaussFilter / sum(gaussFilter);

%% Collapse all non-temporal dimensions
data=permute(data,[4 1 2 3 5 6 7 8]);
data=reshape(data,[d(4) prod(d)/d(4)]);

%% Smooth data
for i=1:size(data,2)
    temp = conv(double(data(:,i)),gaussFilter,'same');
    eval(['data(:,i) = ' c '(temp);']);
end

%% Reshape data into N8 array
data=reshape(data,[d(4),d(1:3),d(5:8)]);
data=permute(data,[2,3,4,1,5,6,7,8]);

