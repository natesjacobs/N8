function n8getdata2(avedims)
%gets data for n8plot
%MAKE SURE CURRENT ROI IS 3D ARRAY WITH CORRECT DEPTH SELECTED

global DATA NOTES

%% Variables
if nargin<1
    avedims=true;
end
%dimensions
d=NOTES.Dimensions{NOTES.CurrentField};
cf=NOTES.Fields{NOTES.CurrentField};
%get num spatial elements in roi
n=sum(NOTES.CurrentROI(:));

%% Get continuous data (NOTES.CurrentData)
%check if current field for continuous data is timestamp data
ts=NOTES.TSvars(NOTES.CurrentField);
if ~ts        
    %collapse spatial dims of current field
    eval(['DATA.' cf '=reshape(DATA.' cf ',[prod(d(1:3)) d(4:8)]);']);
    %get current dims and immediately average across spatial dims
    eval(['NOTES.CurrentData=nanmean(DATA.' cf '(NOTES.CurrentROI(:),:,NOTES.CurrentDims{5},NOTES.CurrentDims{6},NOTES.CurrentDims{7},NOTES.CurrentDims{8}),1);']);
    %average any remaining dims
    if avedims
        d1=size(NOTES.CurrentData);
        d1=find(d1>1); %non-singleton dims
        d1=d1(d1>2); %non-singleton non-spatiotemporal dims (dims1-3 collapsed so dim 2= time)
        for i=d1
            NOTES.CurrentData=nanmean(NOTES.CurrentData,i);
        end
    end
    %reshape current field
    eval(['DATA.' cf '=reshape(DATA.' cf ',d);']);
end

%% Get timestamp data
if ts
    d=NOTES.Dimensions{1};
    %get linear indices of ROI
    indx=find(NOTES.CurrentROI);
    %get all timestamps
    eval(['a=DATA.' cf ';']);
    %convert spatial dims 1-3 to linear indices
    d13_indx = a(:,1) + (a(:,2)-1)*d(1) + (a(:,3)-1)*d(1)*d(2);
    %find timestamps with current ROI
    d13=false(length(a),1);
    for i=1:length(indx)
        d13(d13_indx==indx(i))=true;
    end
    %find timestamps at current "other" dims
    d5=a(:,5)==NOTES.CurrentDims{5};
    d6=a(:,6)==NOTES.CurrentDims{6};
    d7=a(:,7)==NOTES.CurrentDims{7};
    d8=a(:,8)==NOTES.CurrentDims{8};
    %extract timestamps
    a=a(all([d13 d5 d6 d7 d8],2),4);
    NOTES.CurrentData_t=a;
end
