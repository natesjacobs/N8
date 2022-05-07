function data = n8fixdrift(data)

global DATA NOTES

%% Variables
%get dimensions
d=ones(1,8);
d(1:length(size(data)))=size(data);
%check if intiger (return to same class at end)
if isinteger(data)
    c=class(data);
    data=single(data);
    isint=true;
end

%% Collapse spatial dims and average
data=reshape(data,[prod(d(1:3)) d(4:8)]);
a=nanmean(data,1);

%% Calculate regression
a=reshape(a,[d(4),prod(d(5:8))]);
for i=1:size(a,2)
    %get linear regression coefficient(b)
    b=polyfit(1:d(4),a(:,i)',1);
    %expand into line same length as time (dim 4)
    %replace data in a with linear regession
    a(:,i)=polyval(b,1:d(4));
end

%% Subtract regression from data
data=reshape(data,[prod(d(1:3)) d(4) prod(d(5:8))]);
for i=1:size(data,2)
    for j=1:size(data,3)
        data(:,i,j)=data(:,i,j)-a(i,j);
    end
end
    
%% Reformat data
%reshape
data=reshape(data,d);
%reset class
if isint
    if strcmp(c,'uint16')
        data=int16(data);
    elseif strcmp(c,'uint32')
        data=int32(data);
    else
        eval(['data=' c '(data);']);
    end
end
