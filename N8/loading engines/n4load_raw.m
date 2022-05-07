function n4load_raw
%%Import and convert RAW files to N8
%multiple files stored as different depths (dim3)
%Author: NSJ

%set globals
global DATA NOTES

%% Reduce memory demands
%reduce sample rate 
NOTES.Downsample=1;  
%data type
NOTES.DataType{1}='uint16'; 
%shorthand
ds=NOTES.Downsample;
dt=NOTES.DataType{1};

%% RAW file parameters
imx = 512; 
imy = 512; 
n   = 500;

readstr = ['uint16=>' dt]; %convert data type after reading raw file
bitsize = 2; %16 bit
imsize=imx*imy*bitsize; %(n bytes in one image)

%% Get file name(s)
[fn,path]=uigetfile('.raw','MultiSelect','on');
if ischar(fn)
    f{1}=[path fn];
    temp=fn;
    clearvars fn;
    fn{1}=temp;
    ss=fn{1};
else
    for i=1:length(fn)
        f{i}=[path fn{i}];
    end
    ss=[fn{1} fn{end}];
end
%save filenames in NOTES
NOTES.SaveString=['n4data_' ss];
NOTES.Files=f;

%% Pre-allocate data
%preallocate data
DATA.Raw=zeros(imx,imy,length(f),floor(n/ds),dt);

%% Import
for d3=1:length(f)
    %open file
    fid = fopen(f{d3});
    %counter
    x=0;
    %get images from .raw file(s)
    for i=0:ds:n-1
        %set file position indicator
        fseek(fid,(i)*imsize,'bof');
        %read image and save to DATA.Raw
        x=x+1;
        DATA.Raw(:,:,d3,x)=fread(fid,[imx,imy],readstr,0,'b')';
    end
    fclose(fid);
end
