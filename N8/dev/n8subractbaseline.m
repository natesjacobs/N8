function data=N8subractbaseline(data)

global NOTES

if NOTES.Triggers~=0
    w=NOTES.BaselineWindow;
    %replace non-missing NaNs with 0s
    data(isnan(data))=0;
    data(NOTES.MissingData)=NaN;
    %find bl mean
    bl=nanmean(data(:,:,:,w(1):w(2),:,:),4);
    %duplicate array
    bl=repmat(bl,[1 1 1 d(4) 1 1]);
    %subtract values
    data=data-bl;
end