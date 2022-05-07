function n8load_raw_bin
%%Import and convert RAW files to N8
%Author: NSJ

%set globals
global DATA NOTES

%% Reduce memory demands
%reduce sample rate by factor of x
NOTES.Downsample=2; 
%data type (keep as integer for better performance)
NOTES.DataType{1}='int16';
%shorthand
ds=NOTES.Downsample;
dt=NOTES.DataType{1};

%% RAW file parameters
imx = 512;
imy = 512;
n   = 8000;
readstr = ['uint16=>' dt]; %convert data type after reading raw file
bitsize = 2; %16 bit

%Alternative fread parameters from Tim (for files with bytes > 8.4E9)
% d=dir(f);
% if d.bytes>8.4E9
%    bitsize = 4; %32 bit
%    readstr = 'real*4=>double';

%% Get file names
[fn,path]=uigetfile('.raw');
f=[path fn];
%save info in NOTES
%filenames and savestring
NOTES.SaveString=['n8data_' fn];
NOTES.Files=f;

%% Import
%calculate imsize (n bytes in one image)
imsize=imx*imy*bitsize;
%open file
fid = fopen(f);
%preallocate data
DATA.Raw=zeros(imx,imy,1,floor(n/ds),dt);
%counter for new indices
x=0;
for i = 0:ds:n-1-ds
    %advance counter
    x=x+1;
    %reset temp
    temp=zeros(imx,imy,dt);
    %read image(s) - if ds>1, average images
    for j = i:i+ds-1
        %set file position indicator
        fseek(fid,(j)*imsize,'bof');
        %read image
        temp=temp+fread(fid,[imx,imy],readstr,0,'b')';
    end
    %divide to make average
    temp=double(temp)/ds;
    %return to specified data type
    eval(['temp=' dt '(temp);']);
    %save to DATA.Raw
    DATA.Raw(:,:,1,x)=temp;
end
fclose(fid);
