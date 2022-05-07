function n8getdata2
%gets data for n8plot

global DATA NOTES

%% Variables
%dimensions
d=NOTES.Dimensions{NOTES.CurrentFieldVal};

%% Get continuous data (NOTES.CurrentData)
%check if current field for continuous data is timestamp data
ts=strfind(NOTES.CurrentField,'_t');
ts = ~isempty(ts);
%if continuous data:
if ~ts
    %expand current roi to non-spatial dimensions
    roi=repmat(~NOTES.CurrentROI,[1,1,1,prod(d(4:8))]); 
    %reshape into N8 array
    roi=reshape(roi,d);
    %Create logical for current depth
    if isnan(NOTES.CurrentD3)
        a{3}=true(d(3),1); %dim3 = singleton (or x/y is singleton)
    else
        a{3}=1:d(3)~=NOTES.CurrentD3;
    end
    %create logicals for current dims
    for i=5:8
        if d(i)==1
            a{i}=true;
        else
            eval(['a{i}=1:d(i)~=NOTES.CurrentD' num2str(i) ';']);
        end
    end
    %set unselected dims = 0
    roi(:,:,a{3},:,a{5},a{6},a{7},a{8})=false;
    
    
    
    
    
    %grab data specified by NOTES.CurrentD* and immediately average across
    %space
    if isnan(NOTES.CurrentD3)
        eval(['NOTES.CurrentData=nanmean(DATA.' NOTES.CurrentField '(:,:,:,[' num2str(NOTES.CurrentD4) '],[' num2str(NOTES.CurrentD5) '],[' num2str(NOTES.CurrentD6) '],[' num2str(NOTES.CurrentD7) '],[' num2str(NOTES.CurrentD8) ']),4);']);
    else
        eval(['NOTES.CurrentData=nanmean(DATA.' NOTES.CurrentField '(:,:,' num2str(NOTES.CurrentD3) ',[' num2str(NOTES.CurrentD4) '],[' num2str(NOTES.CurrentD5) '],[' num2str(NOTES.CurrentD6) '],[' num2str(NOTES.CurrentD7) '],[' num2str(NOTES.CurrentD8) ']),4);']);
    end
    %average remaining dimensions
    d=size(NOTES.CurrentData); %all dims
    d=find(d>1); %non-singleton dims
    d=d(d>4); %non-singleton non-spatiotemporal dims
    for i=d
        NOTES.CurrentData=nanmean(NOTES.CurrentData,i);
    end
end

%% Get timestamp data %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%IN PROGRESS
%COPY TIMESTAMP CODE FROM n8getdata WHEN FINISHED

%% Functions
%COPY TIMESTAMP CODE FROM n8getdata WHEN FINISHED
end
