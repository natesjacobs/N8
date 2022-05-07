function [spikes,spikecount] = n8spikesearch2(data,spktemplate)
%Finds spikes with deconvolution
%uses fast non-negative deconvolution from Vogelstein et al., 2010

%% Variables
%dimensions
d=ones(1,8);
d(1:length(size(data)))=size(data);
d2=d; d2(4)=1;
%collapse all dimensions except 4D
data=permute(data,[4 1 2 3 5 6 7 8]);
data=reshape(data,[d(4) prod(d)/d(4)]);
%create list of original N8 indices
[i1,i2,i3,i4,i5,i6,i7,i8]=ind2sub(d2,1:size(data,2));
indx=[i1; i2; i3; i4; i5; i6; i7; i8]'; 
%make trace double
data=double(data);

%% Find spikes
spikes=[];
spikecount=nan(1,size(data,2));
for i=1:size(data,2)
    a=data(:,i);
    %thresholds
    thr=threshold*rms(a);
    %find inflexion points
    dx = diff(a); %first derivative
    dx = dx./abs(dx); %pos slopes = -1, neg slopes = 1
    dxdx = [0; diff(dx); 0]; %second derivative, pos peak = 1, neg peak = -1
    datatLow = a < -thr;
    datatHigh = a > thr;
    %find inflexion points beyond thresholds (peaks)
    pospeaks = logical((dxdx < 0) .* datatHigh); %all pos peaks above thr
    negpeaks = logical((dxdx > 0) .* datatLow); %all neg peaks below -thr
    allpeaks = pospeaks|negpeaks;
    %convert from logical to elements
    allpeaks=find(allpeaks);
    %save spike count
    spikecount(i)=length(allpeaks);
    %save spikes
    if ~isempty(allpeaks)
        %remove spikes within window
        a=diff([0; allpeaks]);
        b=allpeaks(a>spikewindow);
        %tile indx for #spikes
        c=repmat(indx(i,:),[length(b),1]);
        %replace d4 with spike timestamps
        c(:,4)=b;
        %add to spikes variable
        spikes(end+1:end+length(b),1:8)=c;
    end
end
%reshape spike count data
spikecount=reshape(spikecount,[1,d(1),d(2),d(3),d(5),d(6),d(7),d(8)]);
spikecount=permute(spikecount,[2,3,4,1,5,6,7,8]);
end