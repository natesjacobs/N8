function roi = splitroi(image,roi,minsize)
%%splits specified ROI into multiple ROIs using rising tide method
%n objects in roi must = 1

%% Variables
if nargin<3
    minsize=sum(roi(:))*0.05;
end
%make double
image=double(image);
%delete data outside ROI
image(~roi)=NaN;
%normalize
image=image-min(image(:));
image=image./max(image(:));
%set initial threshold to 0
thr=0;
%get threshold steps
step=nanmedian(image(:))/10;
%initialize n objects var
n=1;
%save roi in case cannot be split
roi_save=roi;

%% Rising tide threshold
while n < 2
    %raise threshold until n > 1
    thr=thr+step;
    %threshold image
    roi=image>thr;
    %remove small blobs
    roi=bwareaopen(roi,round(minsize));
    %get n objects
    roi=bwlabel(roi);
    n=max(roi(:));
    %break loop if n=0 o thr>1
    if thr>1 || n==0
        roi=roi_save;
        break;
    end
end
%return to binary
roi=roi>0;

