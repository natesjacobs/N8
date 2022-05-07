function n8check

global DATA NOTES
%save current field

%% Check for NOTES.SampleRate (required)
if ~isfield(NOTES,'SampleRate')
    NOTES.SampleRate = n8getnumber('Sample Rate (Hz)'); 
end

%% Check field names
NOTES.Fields=fields(DATA);
NOTES.CurrentField=1;
NOTES.CurrentField_t=NaN;
%Timestamps should be saved as: DATA.*_t
NOTES.TSvars=[];
a=regexp(fields(DATA),'_t.*'); %list all timestamp fields (end with "_t")
for i=1:length(a)
    NOTES.TSvars(i)=~isempty(a{i});
end
if sum(NOTES.TSvars)>0
    NOTES.CurrentField_t=1;
%     %remove TS fieldnames
%     NOTES.Fields=NOTES.Fields(~NOTES.TSvars);
%     %add TS fields to end of Fields list
%     NOTES.Fields(end+1:end+length(NOTES.Fields_t))=NOTES.Fields_t;
    %redo list of timestamp variables
    a=regexp(fields(DATA),'_t.*'); %list all fields starting with "Timestamps_"
    for i=1:length(a)
        NOTES.TSvars(i)= ~isempty(a{i});
    end    
end
NOTES.TSvars=logical(NOTES.TSvars);

%% Dimensions (recalculate each time)
%dimensions for each data type
if isfield(NOTES,'Dimensions')
    NOTES=rmfield(NOTES,'Dimensions');
end
for i=1:length(NOTES.Fields)
    NOTES.Dimensions{i}=ones(1,8);
    eval(['d1=size(DATA.' NOTES.Fields{i} ');']);
    NOTES.Dimensions{i}(1:length(d1))=d1;
end
d=NOTES.Dimensions{1};
%3D data?
if sum(d(1:3)>1)>2
    NOTES.data3D=true;
else
    NOTES.data3D=false;
end
%current dimensions
if ~isfield(NOTES,'CurrentDims')
    for i=3:8
        NOTES.CurrentDims{i}=1;
    end
end

%% Check for NOTES.ROI (required)
if ~isfield(NOTES,'ROI')
    NOTES.ROI = false(0);
else
    a=ones(1,3);
    a(1:length(size(NOTES.ROI)))=size(NOTES.ROI);
    if any(a~=d(1:3))
        NOTES.ROI = false(0);
    end        
end
NOTES.CurrentROI = false(NOTES.Dimensions{1}(1:3));

%% Set timescale (based on sample rate)
if ~isfield(NOTES,'TimeScale')
    if NOTES.SampleRate<1/61 %<1 sample/min
        NOTES.TimeScale=1/3600; %hr/sec
        NOTES.TimeScaleString='hr';
    end
    if NOTES.SampleRate>=1/61; %1 sample/min
        NOTES.TimeScale=1/60; %min/sec
        NOTES.TimeScaleString='min';
    end
    if NOTES.SampleRate>=1; %1 sample/sec
        NOTES.TimeScale=1; %sec/sec
        NOTES.TimeScaleString='sec';
    end
    if NOTES.SampleRate>=1e3; %1 sample/ms
        NOTES.TimeScale=1000; %ms/sec
        NOTES.TimeScaleString='ms';
    end
end
%note for calculating times:
%time in sec = element# / NOTES.SampleRate
%time in correct units = element# / NOTES.SampleRate * NOTES.TimeScale (?)

%% Get default threshold for color scale
if ~isfield(NOTES,'Threshold')  ||  length(NOTES.Threshold)<length(NOTES.Fields) || size(NOTES.Threshold,2)~=2
    if isfield(NOTES,'Threshold')
        NOTES=rmfield(NOTES,'Threshold');
    end
    for i=1:length(NOTES.Fields)
        NOTES.CurrentField=i;
        n8clims;
    end
end

%% Miscellaneous
if ~isfield(NOTES,'Triggers'), NOTES.Triggers=[];end
if ~isfield(NOTES,'SaveString'), NOTES.SaveString='n8data'; end
if ~isfield(NOTES,'Baseline'), NOTES.Baseline=[]; end
if ~isfield(NOTES,'BaselineNorm'), NOTES.BaselineNorm=1; end
if ~isfield(NOTES,'BinSize'), NOTES.BinSize=1; end
if ~isfield(NOTES,'FrameCount'), NOTES.FrameCount=1; end
if ~isfield(NOTES,'CurrentData'), NOTES.CurrentData=[]; end
if ~isfield(NOTES,'CurrentData_t'), NOTES.CurrentData_t=[]; end

%% Add baseline if triggers present
if ~isempty(NOTES.Triggers)
    if isempty(NOTES.Baseline)
        NOTES.Baseline=[1 NOTES.Triggers(1)-1];
    end
end

%% Check if n4data or n8data
if all(d(5:8)==1)
    NOTES.n4data=true;
else
    NOTES.n4data=false;
end

%% Remove extension from file save name
a=strfind(NOTES.SaveString,'.');
if ~isempty(a)
    NOTES.SaveString=NOTES.SaveString(1:a-1);
end

%% Save
n8save; %by default just saves NOTES variable
%reset current field
NOTES.CurrentField=1;

