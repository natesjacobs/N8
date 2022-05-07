function data = n8getdata(field)
%gets data
%inverts data (if specified)
%subtracts baseline (if specified)
%crops data

%% Variables
global DATAa NOTES
if ischar(field)
    fieldname=field;
    for i=1:length(NOTES.FieldNames)
        if strcmp(field,NOTES.FieldNames{i})
            fval=i;
        end
    end   
else
    fval=field;
    fieldname=NOTES.FieldNames{fval};
end

%% Get data
eval(['data=DATAa.' fieldname ';']);
%dimensions
d=ones(1,8);
d(1:length(size(data)))=size(data);

%% Invert (if specified)
if NOTES.FieldsToInvert(fval)
    data=-data;
end

%% Subtract baseline (if specified)
% if NOTES.SubtractBaseline
%     w=NOTES.BaselineWindow;
%     %calculate bl mean
%     bl=nanmean(data(:,:,:,w(1):w(2),:,:,:,:),4);
%     %duplicate to allow subtraction
%     bl=repmat(bl,[1 1 1 d(4) 1 1 1 1]);
%     %subtract values
%     data=data-bl;
% end

%% Normalize (if specified)
if NOTES.Normalize
    for d5=1:d(5)
        for d6=1:d(6)
            %get data
            temp=data(:,:,:,:,d5,d6);
            %divide by max
            temp_mx=data(:,:,:,NOTES.CurrentTimeWindow(1):NOTES.CurrentTimeWindow(3),d5,d6);
            temp=temp/max(temp_mx(:));
            %save
            data(1:d(1),1:d(2),1:d(3),1:d(4),d5,d6)=temp;
        end
    end
end

%% Crop
data=data(NOTES.CropX,NOTES.CropY,NOTES.CropZ,:,:,:,:,:);


    
