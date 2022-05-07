function [spikes,spikecount] = n8spikesearch(data,threshold,peaktype,spikewindow,fixedthresh)
%Finds all negative and positive peaks beyond threshold
% Unless specified by spkwindow_el, all peaks are counted regardless of
% proximity to other peaks
% peaktype = indicate whether to use pos (=1), negative (=2), or all peaks (=3)

%% Variables
if nargin<5
    fixedthresh=false;
end
if nargin<4
    spikewindow = 5;
end
if nargin<3
    peaktype = 3;
end
%dimensions
d=ones(1,8);
d(1:length(size(data)))=size(data);
d2=[d(4) d(1:3) d(5:8)];

%% Collapse all dimensions except 4D
data=permute(data,[4 1 2 3 5 6 7 8]);
data=reshape(data,[d(4) prod(d)/d(4)]);
%create list of original N8 indices
[i1,i2,i3,i4,i5,i6,i7,i8]=ind2sub(d2,1:size(data,2));
indx=[i1; i2; i3; i4; i5; i6; i7; i8]';

%% Preallocate data
spikes=[];
if nargout>1
    spikecount=nan(1,size(data,2));
end

%% Find peaks
for i=1:size(data,2)
    %get trace
    a=data(:,i);
    a=double(a);
    %threshold
    if fixedthresh
        thr=threshold;
    else
        thr=threshold*std(a);
    end
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
    %limit to peak type
    if peaktype==1
        peaks=pospeaks;
    elseif peaktype==2
        peaks=negpeaks;
    elseif peaktype==3
        peaks=allpeaks;
    end
    %convert from logical to elements
    peaks=find(peaks);
    %save spikes
    if ~isempty(peaks)
        %remove spikes within window
        peaks_win=flipud(peaks);
        peaks_win=diff(-[peaks_win; 0]);
        peaks_win=flipud(peaks_win);
        peaks=peaks(peaks_win>spikewindow);
        if nargout>1
            %save spike count
            spikecount(i)=length(peaks);
        end
        %save spike timestamps
        c=repmat(indx(i,:),[length(peaks),1]); %tile indx for #spikes
        if ~isempty(peaks)
            c(:,4)=peaks; %replace d4 with spike timestamps
            spikes(end+1:end+length(peaks),1:8)=int32(c); %add to spikes variable
        end
    end
end

%%  Reshape spike count data
if nargout>1
    spikecount=reshape(spikecount,[1,d(1),d(2),d(3),d(5),d(6),d(7),d(8)]);
    spikecount=permute(spikecount,[2,3,4,1,5,6,7,8]);
end

%% Functions
    function plotspikes
        %NOT USED BUT HERE FOR DEBUGGING
        plot(data(:,i));
        axis tight;
        hold on;
        scatter(peaks,ones(1,length(peaks))*-thr,'MarkerEdgeColor','r');
        %scatter(spikes,ones(1,length(spikes))*-thr,'FillColor','r');
        line([1 length(data)],[-thr -thr],'Color','r');
        line([1 length(data)],[thr thr],'Color','r');
        set(gca,'YLim',[-2*thr 2*thr]);
    end
end