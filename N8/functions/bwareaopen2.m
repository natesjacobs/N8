function BW2 = bwareaopen2(BW,Property,value)
%same as bwareaopen but removes objects with any property greater than value
%input must be 2D array

%check if image is binary
if ~islogical(BW)
    error('input needs to be binary image (logical array)');
end
%get objects in image
L = bwlabel(BW);
%get specified property for each region in image
if strcmp(Property,'SAV')
    %added new region prop: surface area to volume ration (SAV)
    sa=regionprops(L,'Perimeter');
    vol=regionprops(L,'Area');
    STATS.SAV=[sa.Perimeter] ./ [vol.Area];
else
    %otherwise just look up in standard props
    STATS=regionprops(L,Property);
end
%find and delete objects with property > value
eval(['ix = find([STATS.' Property '] > value);']);
for i=ix
    L(L==i)=0;
end
%return to binary image
BW2=L>0;
