function n8collapseroi

global NOTES DATA

%% Get spatial neuropil data (chunk into 50x50 bins)
%LOW PRIORITY, WAIT

%% Average values within each ROI (3D data must be simultaneously acquired)
%Get ROI masks
roi=bwlabeln(squeeze(NOTES.ROI));
nroi=max(roi(:));
%set current dims to all
d=NOTES.Dimensions{1};
NOTES.CurrentD5=1:d(5);
NOTES.CurrentD6=1:d(6);
NOTES.CurrentD7=1:d(7);
NOTES.CurrentD8=1:d(8);
%save average ROI traces
for i=1:length(NOTES.Fields)
    NOTES.CurrentField=i;
    cf=NOTES.Fields{i};
    for j=1:nroi
        NOTES.CurrentROI=roi==j;
        n8getdata2(false);
        %NEED DIFFERENT LINE FOR TIMESTAMP SPARSE MATRIX?
        eval(['data.' cf '(j,1,1,:,:,:,:,:)=NOTES.CurrentData;']);
    end
end

%% Update NOTES and save
DATA=data;
NOTES.ROIghost=NOTES.ROI;
n8check;
NOTES.SaveString=[NOTES.SaveString '_roi'];
n8save(false);
