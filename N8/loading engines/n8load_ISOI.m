function n8load_ISOI
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
%save string

NOTES.SaveString='n8data';

%% Import
imspecs = imfinfo(f{1},'tif');
if length(f)==1
    n = length(imspecs); %# of frames
    for i = 1:n
        image = imread(f{1},'Index',i); %read image
        images(:,:,1,i) = image;
    end
else
    for i=1:length(f)
        imspecs = imfinfo(f{i},'tif');
        n = length(imspecs); %# of frames
        for j=1:n
            image = imread(f{i},'Index',j); %read image
            images(:,:,1,j,i) = image; %files=conditions, z-stack=time
            %images(:,:,j,i) = image; %files=time, z-stack=depth
        end
    end
end

%% Save data
NOTES.Files=f;
DATA.Raw=images;
n8check;
n8isoi;
n8save;

