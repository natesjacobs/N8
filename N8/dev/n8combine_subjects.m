function n8load_subjects
%loads multiple subjects into one file

%% Variables
global NOTES RESULTS RESULTSa

%% Get subject filenames
home=cd('../');
disp('| Adding new data files');
FilePaths = getfilenames3('eload*.mat','Select subject files');
cd(home);
n=length(FilePaths);
pause(0.5);

%% Load subject NOTES/RESULTS
Rnames={};
for d6=1:n
    %load subject files
    load(FilePaths{d6},'RESULTS','NOTES');
    disp(['|   >' FilePaths{d6}])
    %save RESULTS/NOTES
    RESULTStemp{d6}=RESULTS;
    NOTEStemp{d6}=NOTES;
    %save fieldnames
    Rnames(end+1:end+length(fieldnames(RESULTS))) = fieldnames(RESULTS);
    %save dimensions
    eval(['d(d6,1:length(size(RESULTS.' Rnames{end} ')))=size(RESULTS.' Rnames{end} ');']);
    try
        d(d6,4)=length(NOTES.Triggers);
    catch
        d(d6,4)=1;
    end
    %clear temp data
    RESULTS=[];
    NOTES=[];
end

%% Find common field names between all subjects
%unique fields
Runique=unique(Rnames);
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

%% Check dimensions of each subject
dmin=min(d);
dmax=max(d);
if mean(dmin~=dmax)~=0
    warning('Not all subjects have the same size dimensions...');
    disp('     d1    d2    d3    d4    d5');
    disp(d);
end
%collapse individual dims
d=dmin;
d(4)=NaN;
d(6)=n;

%% Choose continuous data fields to save in 6D array
%find fields with >10 time points
for i=1:length(Rkeep)
    eval(['Rsize(i)=size(RESULTStemp{1}.' Rkeep{i} ',4);']);
end
Rkeep=Rkeep(Rsize>10);
Rchoice=listdlg('ListString',Rkeep);
%save sampling rate
NOTES.SampleRate=NOTEStemp{1}.SampleRate;
for d6=1:n
    for i=1:length(Rchoice)
        %d4 length of current variable
        eval(['D4=size(RESULTStemp{d6}.' Rkeep{Rchoice(i)} ',4);']);
        %downsample/upsample to 1 sample every 0.1 ms
        if strncmp(Rkeep{Rchoice(i)},'PSTH*',4)
            for j=1:length(NOTEStemp)
                sr(j)=NOTEStemp{j}.BinSize*1e3; %convert from bin size to sample rate per sec
            end
            if min(sr)==max(sr)
                step=sr(1)*1e-4; % number of elements per 0.1 ms
                ds=[];
                for j=1:round(D4/step)
                    ds(j)=step*j;
                end
                ds=ceil(ds);
                if min2(ds)==0
                    ds=1:D4;
                end
                %import PSTH data
                if d6==1
                    %preallocate space before loading first subject
                    eval(['RESULTS.' Rkeep{Rchoice(i)} '=nan(d(1),d(2),d(3),length(ds),d(5),d(6));']);
                end
                for d4=1:length(ds)
                    eval(['RESULTS.' Rkeep{Rchoice(i)} '(1:d(1),1:d(2),1:d(3),d4,1:d(5),d6)=RESULTStemp{d6}.' Rkeep{Rchoice(i)} '(1:d(1),1:d(2),1:d(3),ds(d4),1:d(5));']);
                end
            else
                warning('Could not load PSTH data because different binsizes were detected');
            end
        else
            step=NOTES.SampleRate*1e-4; % number of elements per 0.1 ms
            ds=[];
            for j=1:round(D4/step)
                ds(j)=step*j;
            end
            ds=round(ds);
            if min2(ds)==0
                ds=1:D4;
            end
            eval(['RESULTS.' Rkeep{Rchoice(i)} '(1:d(1),1:d(2),1:d(3),1:length(ds),1:d(5),d6)=RESULTStemp{d6}.' Rkeep{Rchoice(i)} '(1:d(1),1:d(2),1:d(3),ds,1:d(5));']);
        end
    end
end
%save copy of RESULTS for "Salign"
RESULTSa=RESULTS;

%% Save subject NOTES into NOTES.NOTES field
for i=1:n
    NOTES.NOTES(i)=NOTEStemp(i);
end
NOTES.FilePaths=FilePaths';
NOTES.Dimensions=d;
NOTES.FieldNames=fieldnames(RESULTS);
NOTES.CurrentField=NOTES.FieldNames{1};
NOTES.CurrentFieldVal=1;
