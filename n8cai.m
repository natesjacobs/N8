function n8cai
%n8cai pre-processing of calcium imaging data
%   Operations include calculating dF/F (F0 = mean of entire trace). Raw
%   data must be saved as DATA.Raw.

%% Variables
%get globals
global DATA NOTES
evalin('base','global DATA NOTES');
clc;

%% Import data
%IMPORT DATA USING N8LOAD_RAW (GOLSHANI) OR N8LOAD_SBX (TRACHTENBERG)
if isempty(DATA)
    disp('Loading data');
    a=dir('n8load*');
    if length(a)==1
        run(a.name);
    end 
elseif ~isfield(DATA,'Raw')
    error('load data or place single loading engine in local folder or load data');
end

%% Check data and get dimensions
n8check;
d=NOTES.Dimensions{1};

%% Smooth data
disp('Smoothing data');
%spatial smooth with gaussian filter (3x3 pixels)
DATA.Raw=n8ssmooth(DATA.Raw,3);
%temporal smooth with gaussian filter (0.5 sec, sigma=2)
t=ceil(0.5*NOTES.SampleRate);
DATA.Raw=n8tsmooth(DATA.Raw,2,t);

%% Align images
disp('Aligning data');
%uses sbx's recursive fftalign method to align
[DATA.Raw,T]=n8align(DATA.Raw); 
NOTES.AlignmentIndx=T{1};
NOTES.MeanImage=mean(DATA.Raw,4);
%find max jitter of frames
crop=max(NOTES.AlignmentIndx)-min(NOTES.AlignmentIndx);
%error if some images shifted by more than 25% of image
if max(crop(:))>0.25*max(d(1:3))
    error('jitter in movie file is greater than 25% of image dimensions');
end
%crop
crop=crop+1;
DATA.Raw=DATA.Raw(crop(1):end-crop(1),crop(2):end-crop(2),1:d(3),1:d(4),1:d(5),1:d(6),1:d(7),1:d(8));
NOTES.MeanImage=NOTES.MeanImage(crop(1):end-crop(1),crop(2):end-crop(2));
%update dimensions
d(1:2)=[size(DATA.Raw,1) size(DATA.Raw,2)];

%% Filter low frequency noise   
disp('Removing drift');
DATA.Raw=n8fixdrift(DATA.Raw);

%% Remove "patchy" luminance
%ie, make images "flatter"
disp('Removing "patchy" luminance');
%average and over-smooth
blobs=nanmean(DATA.Raw,4);
blobs=n8ssmooth(blobs,100,15);
c=class(DATA.Raw);
eval(['blobs=' c '(blobs);']);
%subtact blobs from raw data
DATA.Raw=reshape(DATA.Raw,[prod(d(1:3)) prod(d(4:8))]);
for i=1:prod(d(4:8))
    DATA.Raw(:,i)=DATA.Raw(:,i)-blobs(:);
end
DATA.Raw=reshape(DATA.Raw,d);

%% Save mean image in notes
NOTES.MeanImage=mean(DATA.Raw,4);

%% Calculate dF/F
disp('Calculating fractional change (dF/F)');
%uses F = mean value across entire trace for each pixel
DATA.dFF=n8dFF(DATA.Raw); %centered at 0, ie -10% = 90% of mean value (for plotting purposes)
%smooth across space again
DATA.dFF=n8ssmooth(DATA.dFF,3);

%% Deconvolve (first temporal derivative - dFdt)
%RESULT IS VERY SIMILAR TO FAST NON-NEGATIVE DECONVOLUTION (Voglestein, 2010)
disp('Deconvolving with fast non-negative transform (dFdt)');
%start with dFF
DATA.dFdt=DATA.dFF;
%smooth time again
win=round(1*NOTES.SampleRate);
DATA.dFdt=n8tsmooth(DATA.dFdt,5,win);
%pad with zeros at front
DATA.dFdt=permute(DATA.dFdt,[4,1,2,3,5,6,7,8]);
DATA.dFdt=permute(DATA.dFdt,[2,3,4,1,5,6,7,8]);
%first derivative
DATA.dFdt=diff(DATA.dFdt,1,4);
%multiply by dFF to remove fast fluctuations near noise level
DATA.dFdt=DATA.dFdt.*DATA.dFF(:,:,:,2:end,:,:,:,:);
%zero out negative values
DATA.dFdt(DATA.dFdt<0)=0;

%% Calculate "significant" activity
disp('Threshold dFdt data to >5 SD (dFdt_p)');
%calculate standard deviation
DATA.dFdt_p=std(single(DATA.dFdt),[],4);
%multiply by threshold level (can be really high for dFdt)
DATA.dFdt_p=DATA.dFdt_p*5;
%replicate matrix to same size
DATA.dFdt_p=repmat(DATA.dFdt_p,[1,1,1,d(4)-1,1,1,1,1]);
%create logical array of significant elements
DATA.dFdt_p=DATA.dFdt>DATA.dFdt_p;
%remove values that last only 1 frame
a=diff(DATA.dFdt_p,3,4); %find edges
a=a==0;
DATA.dFdt_p=DATA.dFdt_p(:,:,:,1:end-3,:,:,:,:);
d=size(DATA.dFdt_p);
DATA.dFdt_p=all([a(:)'; DATA.dFdt_p(:)']);
DATA.dFdt_p=reshape(DATA.dFdt_p,d);
%remove small blobs
DATA.dFdt_p=n8imagefun(DATA.dFdt_p,'bwareaopen','10');

%% Save
%remove data fields
DATA=rmfield(DATA,'Raw');
DATA=rmfield(DATA,'dFF');

disp('Checking NOTES');
n8check;
NOTES.Cmap(:)=1;
disp('Saving as N8 array');
%n8save(false);

%display options:
clc;
disp(' ');
disp('type "global DATA NOTES" to see variables in workspace"');
disp(' ');
disp('type "n8roi" to segment image(s) into ROIs');
disp(' ');
disp('type "n8plot" to visualize data');
disp(' ');
disp(' ');

n8plot;


