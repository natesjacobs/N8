function [data_ts] = n8getdata_ts
%gets timestamp data for current dims 6-8

global DATA NOTES

%% Get data
eval(['data_ts=DATA.' NOTES.CurrentField_TS ';']);
data_ts=double(data_ts);
d=NOTES.Dimensions;

%% Convert timestamps to bin #
data_ts(:,4)=data_ts(:,4)/NOTES.BinSize;
data_ts=ceil(data_ts);

%% Select timestamps at current values
if NOTES.CurrentD6<=d(6) && NOTES.CurrentD7<=d(7) && NOTES.CurrentD8<=d(8)
    if sum(d(1:3)>1)>2
        %Dim 3 (depth)
        ix = data_ts(:,3) == NOTES.CurrentDepth;
        data_ts=data_ts(ix,:);
    end
    %Dim 6 (subject)
    ix = data_ts(:,6) == NOTES.CurrentD6;
    data_ts=data_ts(ix,:);
    %Dim 7 (subject)
    ix = data_ts(:,7) == NOTES.CurrentD7;
    data_ts=data_ts(ix,:);
    %Dim 8 (subject)
    ix = data_ts(:,8) == NOTES.CurrentD8;
    data_ts=data_ts(ix,:);
else
    data_ts=[];
end
