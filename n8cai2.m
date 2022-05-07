function n8cai2

global DATA NOTES

%% Collapse all ROIs
disp('Collapsing ROIs');
n8collapseroi;

%% Find calcium spike timestamps
disp('Finding calcium spike timestamps');
%find peaks
win=round(NOTES.SampleRate/2); %0.5 sec window
DATA.dFdt_t=n8spikesearch(DATA.dFdt,100,1,win,true); %thr= 3*std, %peak type=1 (only positive peaks)

%% Remove Raw data
DATA=rmfield(DATA,'Raw');

%% Save again
n8check;
n8save(false);