function n4getdata2
%gets data for n8plot

global DATA NOTES

%% Variables
%dimensions
d=NOTES.Dimensions{NOTES.CurrentField};
cf=NOTES.Fields{NOTES.CurrentField};
%error if not N4 data
if any(d(5:8)>1)
    error('n4plot2 can only handle 4D arrays')
end
%get num spatial elements in roi
n=sum(NOTES.CurrentROI(:));

%% Get continuous data (NOTES.CurrentData)
%check if current field for continuous data is timestamp data
ts=strfind(cf,'_t');
ts = ~isempty(ts);
%if continuous data:
if ~ts
    
    %alternative- 
    %collapse spatial dimensions of source data & roi
    %then just select each dimension using logicals/indices
    
    %expand roi to 4D array
    if isnan(NOTES.CurrentD3)  %dim3 = singleton (or x/y is singleton)
        roi=repmat(NOTES.CurrentROI,[1,1,1,d(4)]);
    else
        roi=false(d);
        roi(:,:,NOTES.CurrentD3,:)=repmat(NOTES.CurrentROI,[1,1,1,d(4)]);
    end
    %get data at roi
    eval(['NOTES.CurrentData=DATA.' cf '(roi);']);
    %reshape
    NOTES.CurrentData=reshape(NOTES.CurrentData,[n,d(4)]);
    NOTES.CurrentData=nanmean(NOTES.CurrentData,1);    
end

%% Get timestamp data %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%IN PROGRESS
%COPY TIMESTAMP CODE FROM n8getdata WHEN FINISHED
NOTES.CurrentData_t=[];

%% Functions
%COPY TIMESTAMP CODE FROM n8getdata WHEN FINISHED
end
