function n2roi
%helps user select ROI
%saves new ROIs in NOTES.ROIs
%ROIs are saved as 8D logical arrays
%REWORK TO HANDLE N8

%% Variables
global DATA NOTES
%get current dimensions
d=NOTES.Dimensions;
n=prod(d(1:3)); %number of spatial elements
%find non-singleton spatial dimensions
dxy=d(1:3);
dxy=dxy(dxy>1);
%get current ROI
if ~isfield(NOTES,'CurrentROI') || isempty(NOTES.CurrentROI)
    roi=false(d(1),d(2),d(3));
    NOTES.CurrentROI=roi;
else
    roi=NOTES.CurrentROI(:,:,:,1);
end

%% Get ROI
if n<64
    %select channels
    if length(dxy)>2
        %pick channel(s)
        if ~isempty(dxy)
            roi=n8choose(dxy(1),dxy(2));
        else
            roi=true(d(1:3));
        end
        %reshape into 3 spatial dims
        roi=roi(:); %vectorize
        roi=reshape(roi,[d(1),d(2),d(3)]); %reshape
        %extend to all time points, conditions
        roi=repmat(roi,[1,1,1,d(4),d(5)]);
        %save to global
        NOTES.CurrentROI=roi;
    else
        %create blank roi
        roi=false(d(1),d(2),d(3));
        %pick channel (dim 1/2) ***dim 3 not used for picking ROI
        roi(:,:,NOTES.CurrentDepth)=n8choose(d(1),d(2),'Choose channel(s) to plot');
        %extend to all time points, conditions
        if ~isempty(roi)
            roi=repmat(roi,[1,1,d(3),d(4),d(5)]);
        else
            roi=NOTES.CurrentROI; %if user closes window before choosing
        end
    end
else
    n4roi;
end
    
    