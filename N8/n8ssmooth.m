function data = n8ssmooth(data,hsize,sigma)
%spatial filter for data in N8 architecture
%default hsize = 5% of size of smallest spatial dimension (excluding singleton dims)
%default sigma =2
%replicates border values to avoid having to crop image

%% Variables
%dimensions
d=ones(1,8);
d(1:length(size(data)))=size(data);
%non-singleton dimensions
nsd=(d(1:3)>1);
if sum(nsd)<1
    error('Could not apply spatial filter since number of locations = 1')
elseif sum(nsd)== 1
    warning('spatial filter applied to 1D array');
end
%default inputs
if nargin<2
    hsize=5; %bin size
end
if nargin<3
    sigma=2; %steepness of gaussian filter
end

%% Collapse all non-spatial dimensions
data=reshape(data,[d(1),d(2),d(3),prod(d(4:8))]);

%% Smooth data
%create filter (works for ND arrays of any size)
filter = fspecial('gaussian',hsize,sigma);
%smooth data
for i=1:size(data,4) 
    %imfilter ok with ND array and with integer class
    data(:,:,:,i) = imfilter(data(:,:,:,i),filter,'replicate');
end

%% Reshape data
data=reshape(data,d);


