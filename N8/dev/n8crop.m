function n8crop
%compiles DATA from multiple subjects into one data structure
%allows group means, standard error, etc to be calculated
%Requirements for "n8data" .mat files:
%   1 - 

%% Variables
global NOTES
d=NOTES.Dimensions;
d(4)=1;
NOTES.Crop = true(d);

%% Crop N8 array
if min(d(1:3))==1
    %remove singleton spatial dimenson
    ns=d(1:3);
    ns=ns(ns>1);
    NOTES.Crop(1:d(1),1:d(2),1:d(3))=n8choose('Select Crop',ns(1),ns(2));
else
    for d3=1:d(3)
        NOTES.Crop(1:d(1),1:d(2),d3)=n8choose(['Crop for depth ' num2str(d3)],d(1),d(2));
    end
end

