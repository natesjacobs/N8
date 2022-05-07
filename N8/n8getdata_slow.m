function [data] = n8getdata
%gets data for n8plot
global DATA NOTES

f2=msgbox('   please wait...');

%% Get data
eval(['data=DATA.' NOTES.CurrentField ';']);
data=double(data);
%if timestamps, make continuous at sample rate
a=regexp(NOTES.CurrentField,'Timestamps_.*');
if sum(~isempty(a))
    %get dimensions of first data field (must be continuous)
    d=ones(1,8);
    eval(['temp=size(DATA.' NOTES.FieldNames{1} ');']);
    d(1:length(temp))=temp;
    %preallocate data as vector
    temp=zeros(prod(d),1);
    %Compute linear indices
    k = [1 cumprod(d(1:end-1))];
    ndx=ones(size(data,1),1);
    for i = 1:8
        v = data(:,i);
        ndx = ndx + (v-1)*k(i);
    end
    %add timestamps to vector
    ndx=ndx(ndx>0);
    temp(ndx)=1;
    %reshape vector into N8 array
    temp=reshape(temp,d);
    data=temp;
    clearvars temp;
    ts=true;
else
    ts=false;
end

%Reset dimensions
d=ones(1,8);
d(1:length(size(data)))=size(data);
NOTES.Dimensions=d;

%% Baseline normalization
if NOTES.BaselineNorm > 1
    w=NOTES.Baseline;
    %calculate bl mean
    bl=nanmean(data(:,:,:,w(1):w(2),:,:,:,:),4);
    %duplicate to allow subtraction
    bl=repmat(bl,[1 1 1 d(4) 1 1 1 1]);
    if NOTES.BaselineNorm == 2
        %subtract baseline
        data=data-bl;
    elseif NOTES.BaselineNorm == 3
        %divide by baseline
        data=data./bl;
    end
end

%% Update binsize
b=NOTES.BinSize;
if b>1
    %crop data if d(4) doesn't divide evenly by bin size
    cut = rem(d(4),b);
    %cut = b-cut;
    data=data(:,:,:,1:end-cut,:,:,:,:);
    %update d4
    d(4)=size(data,4);
    %add new dimension before dim4
    data=reshape(data,[d(1),d(2),d(3),b,d(4)/b,d(5),d(6),d(7),d(8)]);
    %average across binsize
    data=nanmean(data,4);
    %remove added dimension
    d(4)=size(data,5);
    data=reshape(data,[d(1),d(2),d(3),d(4),d(5),d(6),d(7),d(8)]);
    %Reset dimensions
    d=ones(1,8);
    d(1:length(size(data)))=size(data);
    NOTES.Dimensions=d;
    %if timestamp data, change to sum instead of ave (x number of elements
    %in bin)
    if ts
        data=data*b;
    end
end    

%% Normalize to peak (if specified)
% %normalizes to each subject/condition
% if NOTES.Normalize
%     %collapse across trials, if any
%     mx=nanmean(data,7);
%     %find max
%     mx=max(mx,[],4);
%     %tile for ND array
%     mx=repmat(mx,[1 1 1 size(data,4) 1 1 size(data,7) 1]);
%     %divide by max
%     data=data./mx;
% end

%% Set color map thresholds
a=NOTES.Threshold(NOTES.CurrentFieldVal);
if isnan(a)
%     %vectorize all data
%     thresh=data(:);
%     %remove negatives
%     thresh=abs(thresh);
%     %sort
%     thresh=sort(thresh);
%     %pick thresh at top 4%
%     thresh=thresh(round(end*0.96));
%     %make double
%     thresh=double(thresh);
%     %round to nearest thousandth
%     thresh=ceil(thresh*1e3)/1e3; %round
    
    %set thresh to abs(mean) + variance
    n8getclim(data);
    
    
%     %make sure it's not 0
%     if thresh==0
%         thresh=1;
%     end
%     %save in global
%     NOTES.Threshold(NOTES.CurrentFieldVal)=thresh;
end
%decide between single or binary color map
c=min(data(:));
if c>=0
    NOTES.Cmap=1;
else
    NOTES.Cmap=2;
end

%% Current depth (D3) and subject (D6)
%Depth
if sum(d(1:3)>1)>2
    data=data(:,:,NOTES.CurrentDepth,:,:,:,:,:);
end
%Subject)
if NOTES.CurrentD6>size(data,6)
    data=nanmean(data,6);
else
    data=data(:,:,:,:,:,NOTES.CurrentD6,:,:);
end

%% close message box
close(f2);

