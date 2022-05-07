function n8getdata
%gets data for n8plot

global DATA NOTES

%% Variables
%dimensions
d=NOTES.Dimensions{NOTES.CurrentField};
cf=NOTES.Fields{NOTES.CurrentField};

%% Get continuous data (NOTES.CurrentData)
%check if current field for continuous data is timestamp data
ts=NOTES.TSvars(NOTES.CurrentField);
%if continuous data:
if ~ts
    %grab data specified by NOTES.CurrentD* and immediately average across time
    if isnan(NOTES.CurrentDims{3})
        eval(['NOTES.CurrentData=nanmean(DATA.' cf '(:,:,:,NOTES.CurrentDims{4},NOTES.CurrentDims{5},NOTES.CurrentDims{6},NOTES.CurrentDims{7},NOTES.CurrentDims{8}),4);']);
    else
        eval(['NOTES.CurrentData=nanmean(DATA.' cf '(:,:,NOTES.CurrentDims{3},NOTES.CurrentDims{4},NOTES.CurrentDims{5},NOTES.CurrentDims{6},NOTES.CurrentDims{7},NOTES.CurrentDims{8}),4);']);
    end
    %average remaining dimensions
    a=size(NOTES.CurrentData); %all dims
    a=find(a>1); %non-singleton dims
    a=a(a>4); %non-singleton non-spatiotemporal dims
    for i=a
        NOTES.CurrentData=nanmean(NOTES.CurrentData,i);
    end
end

%% Get timestamp data %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%IN PROGRESS
%timestamp data can either be:
%   #1 - overlaid on single trial continuous data (NOTES.CurrentData_t)
%   #2 - used to construct continuous data (NOTES.CurrentData)
if ~isnan(NOTES.CurrentField_t)
    if ~ts && NOTES.CurrentDims{6}<=d(6) && NOTES.CurrentDims{7}<=d(7) && NOTES.CurrentDims{8}<=d(8)
        %#1 get overlay timestamps
        %NOTES.CurrentData_t=findts1;
    elseif ~ts
        %#1 set overlay stamps to empty(not single trial)
        %NOTES.CurrentData_t=[];
    else
        %#2 convert timestamps to image
        %a=findts2;
        %create ND array
        %a;
        %sum to make histogram
        %a;
        %NOTES.CurrentData=a;
    end
    NOTES.CurrentData_t=[];
end

%% Functions
    function a=findts1 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%IN PROGRESS
        
        %assume only 1 index per dim
        
        %find timestamps at current dim 3 (depth)
        if isnan(NOTES.CurrentDims{3})
            ts3=true(size(DATA.X,1),1);
        else
            ts3=DATA.Spikes_t(:,3)==1;
            %find timestamps at current dims 4-8
            
            %find timestamps that meet all criteria
            tsx=all([ts3,ts4,ts5,ts6,ts7,ts8],1);
            %get timestamps at current dims
            a=DATA.X(tsx,:);
            %reshape?
        end
    end
    function a=findts2 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%IN PROGRESS
        
        %can have multiple indices per dime
        
        %find timestamps at current dim 3 (depth)
        if isnan(NOTES.CurrentDims{3})
            ts3=true(size(DATA.X,1),1);
        else
            
        end
        %find timestamps at current dims 4-8
        
        %find timestamps that meet all criteria
        tsx=all([ts3,ts4,ts5,ts6,ts7,ts8],1);
        %get timestamps at current dims
        a=DATA.X(tsx,:);
        %reshape?
    end
end
