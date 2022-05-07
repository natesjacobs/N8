function n8load_tif(downsample)
%%Import and convert TIF files to Matlab format
%Author: NSJ

global DATA NOTES

%% Get file names
[fn,path]=uigetfile('.tif','MultiSelect','on');
if ischar(fn)
    f{1}=[path fn];
else
    for i=1:length(fn)
        f{i}=[path fn{i}];
    end
end
%decimate sample rate?
if nargin<1
    downsample=1;
end
%save string
try
    savestring=['n8data_' fn{1}];
catch
    savestring=['n8data_' fn];
end
NOTES.SaveString=savestring;

%% Import
imspecs = imfinfo(f{1},'tif');
if length(f)==1
    n = length(imspecs); %# of frames
    for i = 1:n
        image = imread(f{1},'Index',i); %read image
        images(:,:,1,i) = image;  %z-stack=time
    end
else
    for i=1:length(f)
        imspecs = imfinfo(f{i},'tif');
        n = length(imspecs); %# of frames
        for j=1:n
            image = imread(f{i},'Index',j); %read image
            images(:,:,1,j,i) = image; %files=conditions, z-stack=time
        end
    end
end

%% Downsample
if downsample>1
    NOTES.Downsample=downsample;
    images=images(:,:,:,1:downsample:end);
end

%% Save data
NOTES.SaveString=savestring;
NOTES.Files=f;
DATA.Raw=images;
n8check;
n8save;

