function n8load_raw
%%Import and convert RAW files to N8
%Author: NSJ

%set globals
global DATA NOTES

%% Reduce memory demands
%reduce sample rate by factor of x
NOTES.Downsample=1; 
%data type (keep as integer for better performance)
NOTES.DataType{1}='int16';
%shorthand
ds=NOTES.Downsample;
dt=NOTES.DataType{1};

%% RAW file parameters
imx = 512;
imy = 512;
n   = 4000;
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
for i = 0:ds:n-1
    %advance counter
    x=x+1;
    %set file position indicator
    fseek(fid,(i-1)*imsize,'bof');
    %read image
    DATA.Raw(:,:,1,x) = fread(fid,[imx,imy],readstr,0,'b')';
end
fclose(fid);
