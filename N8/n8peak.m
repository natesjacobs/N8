function n8peak
%calculates (absolute) peak response for each location
%averages across trials
%finds (absolute) max value within 100 ms (1 sec for SR<1kHz)
%averages peak values across triggers

global NOTES DATA

%get data
disp(['Finding peak values for DATA.' NOTES.CurrentField]);
eval(['data=DATA.' NOTES.CurrentField ';']);

%get triggers
t=NOTES.Triggers*NOTES.SampleRate;
t=round(t);

%determine search window for max value
if NOTES.SampleRate>1e3
    w=0.1*NOTES.SampleRate; %for SR>1kHz use 100 ms window
else
    w=1*NOTES.SampleRate; %for SR<1kHz use 1 sec window
end
w=round(w);

%dimensions
d=ones(1,8);
d(1:length(size(data)))=size(data);

%average across trials
data=nanmean(data,7);

%find peak value (maximum)
p=nan(d(1),d(2),d(3),length(t),d(5),d(6),1,d(8));
l=p;
for i=1:length(t)
    [a,b]=max(abs(data(:,:,:,t:t+w,:,:,:,:)),[],4);
    p(:,:,:,i,:,:,:,:)=a; %max value
    l(:,:,:,i,:,:,:,:)=b/NOTES.SampleRate; %latency
end

%average across triggers
p=nanmean(p,4);
l=nanmean(l,4);

%save results
eval(['DATA.' NOTES.CurrentField 'peak=p;']);
eval(['DATA.' NOTES.CurrentField 'latency=l;']);





