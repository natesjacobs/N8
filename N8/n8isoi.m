function n8isoi
%%Calculates fractional change values in same way as Frostig ISOI analysis
%Author: NSJ

%% Variables
%get globals
global DATA NOTES
%check for baseline
if ~isfield(NOTES,'Baseline') || isempty(NOTES.Baseline)
    n8bl;
end

%% Get Raw data
%remove first frame ("junk" frame)
DATA.Raw=DATA.Raw(:,:,:,2:end,:,:,:,:);
%get raw data
raw=DATA.Raw;
%check data type
if isinteger(raw)
    raw=double(raw);
end
%get baseline values
bl=raw(:,:,:,NOTES.Baseline(1):NOTES.Baseline(2),:,:,:,:);
d4=size(raw,4);
bl=nanmean(bl,4);
bl=repmat(bl,[1,1,1,d4,1,1,1,1]);

%% Calculate fractional change
%divide by baseline
DATA.FC=raw./bl;
%center around zero
DATA.FC=DATA.FC-1;
%smooth data
DATA.FC=n8ssmooth(DATA.FC);

%% Calculate dx/dt
DATA.dxdt=diff(raw,1,4);
DATA.dxdt=n8ssmooth(DATA.dxdt);
%shift over 1 element (to correct for 1 less element)
DATA.dxdt(:,:,:,2:end+1,:,:,:,:)=DATA.dxdt;
DATA.dxdt(:,:,:,1,:,:,:,:)=NaN;

%% Save and plot
%add field to list of fields
NOTES.FieldNames=fields(DATA);
NOTES.CurrentField='FC';
NOTES.CurrentFieldVal=length(fields(DATA))-1;
%update NOTES fields
n8check;
%save and plot
n8save;
n8plot;

