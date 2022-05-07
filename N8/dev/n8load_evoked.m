function mload(savename)
%Load "trigger-save to same file" data from SnR
%Use "Eload" to analyze data from multiple animals
%Trigger channels must be named T* in SnR (resulting in varname of CT*)
%Triggers controlled by master8 were determined to be accurate within 0.1
%ms, assumed subtriggers (stim pulse 2-5) occured at 200, 400, 600, and 800
%ms.

%% Variables
if nargin<1
    savename=[]; 
else
    if ~ischar(savename)
        error('Please use a string variable for "savename"')
    end
end
%channels:
chlist(1,:,1,1) = 1:4:32; %LI
chlist(1,:,2,1) = 2:4:32; %LII,III
chlist(1,:,3,1) = 3:4:32; %LIV
chlist(1,:,4,1) = 4:4:32; %LV

%miscellaneous
sch=ones(4,1);
sch(1:length(size(chlist)))=size(chlist); %size of chanel list
NOTES.ChList = chlist;
c = 1.905e-4; %accounts for bit depth (16-bit -5V to +5V) and gain (200) for standard SnR parameters
stimdelay = 5e-3;
raw_samplerate = 22.3214e3;
TRIG_samplerate = 44.6429e3;
triggers = [0 200 400 600 800] + 1000 + stimdelay;
samplerate = [raw_samplerate TRIG_samplerate];
savelength = floor(3*samplerate(1)); %keep 3 sec after recording starts

%% Get filenames % Preallocate memory
disp('| Select files');
groups = getfilenames2;
RAW=int16(nan(sch(1),sch(2),sch(3),savelength,length(groups),1,64,1));

%%  Load triggers/data
disp('| Loading data into ND array');
for d5=1:length(groups)
    d7start=1;
    for n=1:length(groups(d5).Paths)
        disp(['|   >' groups(d5).Paths{n}]);
        load(groups(d5).Paths{n});
        %Trigger
        trigger = (CTTL_001_Up/samplerate(2)) + stimdelay;
        trigger = floor(trigger*samplerate(1))+1;
        %Save data
        for d1=1:sch(1) %el. array rows
            for d2=1:sch(2) %el. array columns
                for d3=1:sch(3) %el. array depths
                    for d7=1:length(trigger) %trial
                        for d8=1:sch(4) %n-trode
                            t = trigger(d7);
                            k = chlist(d1,d2,d3,d8);
                            try
                                eval(['data = CRAW_00' num2str(k) ';']);
                            catch
                                eval(['data = CRAW_0' num2str(k) ';']);
                            end
                            try
                                raw(d1,d2,d3,1:length(data(t:t+savelength)),1,1,d7,d8) = data(t:t+savelength);
                            catch
                                try
                                    raw(d1,d2,d3,1:length(data(t:end)),1,1,d7,d8) = data(t:end);
                                catch
                                    disp('Could not load data from:')
                                    disp('d1 d2 d3 d5 d7');
                                    disp([d1 d2 d3 d5 d7]);
                                end
                            end
                        end
                    end
                end
            end
        end
        RAW(1:sch(1),1:sch(2),1:sch(3),1:size(raw,4),d5,1,d7start:d7start+length(trigger)-1)=raw;
        d7start=d7start+length(trigger);
        clear C* raw;
    end
end

%% Clean up & Save
%check for data in RAW
if isempty(RAW)
    disp('                 !!!     no data was imported     !!!');
end
%add notes
NOTES.Triggers = triggers;
NOTES.SampleRate = samplerate(1);
NOTES.Channels=chlist;
NOTES.mV=c;
NOTES.Dimensions = ones(1,8);
NOTES.Dimensions(1:length(size(RAW))) = size(RAW);
for i=1:NOTES.Dimensions(5)
    NOTES.FileNames{i}=' ';
    if length(groups(i).FileNames)>1
        for j=1:length(groups(i).FileNames)
            NOTES.FileNames{i} = [NOTES.FileNames{i} ' ' groups(i).FileNames{j}];
        end
    else
        NOTES.FileNames(i) = groups(i).FileNames;
    end
end
%save
disp('| Saving data to "eload" file');
if isempty(savename)
    savename = 'eload';
else
    savename = ['eload_' savename];
end
save(savename,'RAW','NOTES','-v7.3');
disp('| Done.');
