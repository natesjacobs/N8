function roi = addroi(image,indx,maxsize)
%%finds ROI around specified coordinate (indx)
%if indx is scalar treats as linear index, if vector treats as subscript

%% Variables
%max size of detected roi
if nargin<3
    maxsize=max(size(image))*0.1;
end
%shorthand for index
i=indx;
%convert linear indices to subscript
if numel(i)==1
    [i(1),i(2),i(3)] = ind2sub(size(image),i);
end
%add singleton 3rd dim if not specified
if numel(i)==2
    i(3)=1;
end

%% Threshold image to detect object
%get value at i
thr=image(i(1),i(2),i(3));
%subtract min value
thr=thr-min(image(:));
%get 5% peak value
v=thr*0.05;
%start threshold at 25% peak
thr=thr/4;
%initialize objsize value
objsize=numel(image);
while objsize > maxsize
    %threshold image
    roi=image>thr;
    %label & get obj #
    roi=bwlabel(roi);
    nobj=roi(i(1),i(2),i(3));
    roi=roi==nobj;
    %get size of object
    objsize = sum(roi(:));
    %advance threshold by 5% of peak
    thr=thr+v;
    %break loop if original value passed
    if thr>image(i(1),i(2),i(3))
        roi(:)=false;
        break
    end
end

