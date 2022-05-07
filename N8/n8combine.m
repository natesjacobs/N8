function n8combine
%loads multiple subjects into one file

%% Variables
global DATA NOTES

%% Get subject filenames
home=cd('../');
disp('| Adding new data files');
FilePaths = n8getfiles('n8*.mat','Select files to combine');
cd(home);
n=length(FilePaths);
pause(0.5);

%% Load subject NOTES/DATA
for d6=1:n
    %load subject files
    load(FilePaths{d6},'DATA','NOTES');
    disp(['|   >' FilePaths{d6}])
    %save DATA/NOTES
    D{d6}=DATA;
    N{d6}=NOTES;
end

%% Find common field names
%get field names
Dnames={};
Nnames={};
for i=1:n
    Dnames(end+1:end+length(fieldnames(DATA))) = fieldnames(DATA);
    Nnames(end+1:end+length(fieldnames(DATA))) = fieldnames(DATA);
end
%find unique fields
Nunique=unique(Rnames);

%results fields to keep
Rkeep={};
for i=1:length(Runique)
    %count # of subjects with field name
    fieldcount=strcmp(Runique{i},Rnames);
    fieldcount=sum(fieldcount);
    %if all subjects have fieldname, save
    if fieldcount==n
        Rkeep{end+1}=Runique{i};
    end
end

%% Check dimensions
dmin=min(d);%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
dmax=max(d);
if mean(dmin~=dmax)~=0
    disp('     d1    d2    d3    d4    d5');
    disp(d);
    error('Not all subjects have the same size dimensions...');
end
%collapse individual dims
d=dmin;
d(4)=NaN;
d(6)=n;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Combine into single 8D array
%collapse both arrays into vectors

%combine arrays

%reshape




% %find fields with >10 time points
% for i=1:length(Rkeep)
%     eval(['Rsize(i)=size(DATAtemp{1}.' Rkeep{i} ',4);']);
% end
% Rkeep=Rkeep(Rsize>10);
% Rchoice=listdlg('ListString',Rkeep);
% %save sampling rate
% NOTES.SampleRate=NOTEStemp{1}.SampleRate;
% for d6=1:n
%     for i=1:length(Rchoice)
%         %d4 length of current variable
%         eval(['D4=size(DATAtemp{d6}.' Rkeep{Rchoice(i)} ',4);']);
%         %downsample/upsample to 1 sample every 0.1 ms
%         if strncmp(Rkeep{Rchoice(i)},'PSTH*',4)
%             for j=1:length(NOTEStemp)
%                 sr(j)=NOTEStemp{j}.BinSize*1e3; %convert from bin size to sample rate per sec
%             end
%             if min(sr)==max(sr)
%                 step=sr(1)*1e-4; % number of elements per 0.1 ms
%                 ds=[];
%                 for j=1:round(D4/step)
%                     ds(j)=step*j;
%                 end
%                 ds=ceil(ds);
%                 if min2(ds)==0
%                     ds=1:D4;
%                 end
%                 %import PSTH data
%                 if d6==1
%                     %preallocate space before loading first subject
%                     eval(['DATA.' Rkeep{Rchoice(i)} '=nan(d(1),d(2),d(3),length(ds),d(5),d(6));']);
%                 end
%                 for d4=1:length(ds)
%                     eval(['DATA.' Rkeep{Rchoice(i)} '(1:d(1),1:d(2),1:d(3),d4,1:d(5),d6)=DATAtemp{d6}.' Rkeep{Rchoice(i)} '(1:d(1),1:d(2),1:d(3),ds(d4),1:d(5));']);
%                 end
%             else
%                 warning('Could not load PSTH data because different binsizes were detected');
%             end
%         else
%             step=NOTES.SampleRate*1e-4; % number of elements per 0.1 ms
%             ds=[];
%             for j=1:round(D4/step)
%                 ds(j)=step*j;
%             end
%             ds=round(ds);
%             if min2(ds)==0
%                 ds=1:D4;
%             end
%             eval(['DATA.' Rkeep{Rchoice(i)} '(1:d(1),1:d(2),1:d(3),1:length(ds),1:d(5),d6)=DATAtemp{d6}.' Rkeep{Rchoice(i)} '(1:d(1),1:d(2),1:d(3),ds,1:d(5));']);
%         end
%     end
% end

%% Save subject NOTES into NOTES.NOTES field
for i=1:n
    NOTES.NOTES(i)=NOTEStemp(i);
end
NOTES.FilePaths=FilePaths';
NOTES.Dimensions=d;
NOTES.FieldNames=fieldnames(DATA);
NOTES.CurrentField=NOTES.FieldNames{1};
NOTES.CurrentFieldVal=1;
