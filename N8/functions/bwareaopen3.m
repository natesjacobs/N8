function BW2 = bwareaopen3(BW,Property,value)
%same as bwareaopen but removes objects with property LESS than value
%input must be 2D array

%check if image is binary
if ~islogical(BW)
    error('input needs to be binary image (logical array)');
end

%get objects in image
L = bwlabel(BW);
%get eccentricity of object i
STATS=regionprops(L,Property);

%find objects with property > value
eval(['ix = find([STATS.' Property '] < value);']);

%delete eccentric objects
for i=ix
    L(L==i)=0;
end

%return to binary image
BW2=L>0;
