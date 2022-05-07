function n4load_sbx
%%Import and convert RAW files to N8
%multiple files stored as different depths (dim3)
%only load first channel
%Author: NSJ

%set globals
global DATA NOTES

%% Reduce memory demands
%reduce sample rate 
ds=1;
%only load n frames of movie
n = 500;
%n = []; %uncomment to use full size

%% Get file name(s)
[fn,path]=uigetfile('.sbx','MultiSelect','on');
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

%% SBX binary file parameters
info=[];
try
    %use info file saved by scanbox
    [~,mfile] = fileparts(f{1});
    load([mfile '.mat']);
    %get parameters
    imx = info.recordsPerBuffer;
    imy = info.config.lines;
    channels = info.channels;
    bitsize = info.bytesPerBuffer/info.postTriggerSamples/imx/channels;
    NOTES.ScanBox = info;
    if isempty(n)
        n = info.postTriggerSamples;
    end
catch
    %manually enter info about binary file
    imx = 512;
    imy = 512;
    bitsize = 2; %16 bit
    channels=2;
end
% Sparse interpolant matix corrects non-uniform sampling of resonant mirror
%S = sparseint;
%imy=size(S,2);
imy=796; %sparseint function doesn't take any inputs, always spits out 796 for imy

% image size
imsize = imx*imy*bitsize;
if bitsize~=2
    error('something is probably wrong')
end
%data type
readstr='uint16=>uint16'; %from sbxreadpacked 7/24/2015

%% Pre-allocate data
%preallocate data
DATA.Raw=zeros(imx*imy*channels,length(f),floor(n/ds),'uint16');

%% Import images from .sbx file
for d3=1:length(f)
    %open file
    try
        fid = fopen(f{d3},'rb');
    catch
        fid = fopen(fn{d3},'rb');
    end
    %counter
    x=0;
    %get images from .raw file(s)
    for i=0:ds:n-1
        %set file position indicator (2x length of imsize)
        fseek(fid,(i)*imsize*channels,'bof'); %channel 1 (+imsize/2 for channel 2)
        %read image and save to DATA.Raw
        x=x+1;
        DATA.Raw(:,d3,x)=fread(fid,imx*imy*channels,readstr,0,'b')';
    end
    %close .sbx binary file
    fclose(fid);
end
%reshape
DATA.Raw=reshape(DATA.Raw,[imy,imx,channels,d3,x]);
DATA.Raw=permute(DATA.Raw,[2,1,4,5,3]);
%invert data
DATA.Raw = intmax('uint16')-DATA.Raw;

%% Save parameters/filenames in NOTES
NOTES.Downsample=ds;
NOTES.SaveString=['n4data_' ss];
NOTES.Files=f;

%% Run standard calcium imaging analysis
%n8check;
%n8cai;

%% Functions
    function S = sparseint
        p = 1250;                   % period of sampling grating (resfreq?)
        t = 0:(p-1);
        xpos = -cos(t*pi/p);        % actual position of beam
        m = max(diff(xpos));        % magnification is isotropic at the center
        L = xpos(1):m:xpos(end);        
        xi = (pi  -(acos(L)))*p/pi; % times at which we want to interpolate
        nsamp = length(xi);        
        
        % Calculate sparse interpolant matrix (simple linear interp.)        
        S = sparse(nsamp,p,0);  %S is the image?      
        for i=1:nsamp
            [d,idx] = sort(abs(xi(i)-t));   % simple nearest neighbor interpolation
            S(i,idx(1))=1;            
        end
        S = S';
    end
end