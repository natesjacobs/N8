function n8badchannel
%replaces one or more channels with data from one or more other channels
%for continuous data, uses simple average
%for timestamp data, adds some timestamps from replacement channels
%by number of channels being combined

%% Variables
global NOTES DATA
f2=msgbox('   please wait...');

%% Reset dimensions
d=ones(1,8);
eval(['temp=size(DATA.' NOTES.FieldNames{1} ');']);
d(1:length(temp))=temp;
NOTES.Dimensions=d;

%% Get bad channel(s)
if isnan(NOTES.CurrentDepth)
    dxy=d(1:3);
    dxy=dxy(dxy>1);
    %pick channel(s)
    bad=n8choose(dxy(1),dxy(2));
    %reshape into 3 spatial dims
    bad=bad(:); %vectorize
    bad=reshape(bad,[d(1),d(2),d(3)]); %reshape
else
    for i=1:NOTES.Dimensions(3)
        bad(:,:,i)=n8choose(d(1),d(2),'BAD channel(s)');
    end
end
%get indices for timestamp data
ix=find(bad);
[bad1,bad2,bad3]=ind2sub(d(1:3),ix);
nbad=length(bad1);
%extend across non-spatial dims
bad=repmat(bad,[1,1,1,d(4:8)]);

%% Get replacement channel(s)
if isnan(NOTES.CurrentDepth)
    dxy=d(1:3);
    dxy=dxy(dxy>1);
    %pick channel(s)
    rep=n8choose(dxy(1),dxy(2));
    %reshape into 3 spatial dims
    rep=rep(:); %vectorize
    rep=reshape(rep,[d(1),d(2),d(3)]); %reshape
else
    for i=1:NOTES.Dimensions(3)
        rep(:,:,i)=n8choose(d(1),d(2),'REPLACEMENT channel(s)');
    end
end
%get indices of bad channels for timestamp data
ix=find(rep);
[rep1,rep2,rep3]=ind2sub(d(1:3),ix);
nrep=length(rep1);
%extend logical indices across non-spatial dimensions
rep=repmat(rep,[1,1,1,d(4:8)]);

%% Replace bad channel(s)
f=NOTES.FieldNames;
for i=1:length(NOTES.FieldNames)
    if NOTES.TSvars(i)
        %timestamp data
        eval(['data=DATA.' f{i} ';']);
        %get timestamp indices for bad channels
        badix=false(size(data,1),1);
        for j=1:nbad
            temp1=data(:,1)==bad1(j);
            temp2=data(:,2)==bad2(j);
            temp3=data(:,3)==bad3(j);
            temp=[temp1 temp2 temp3];
            temp=all(temp,2);
            badix(temp)=true;
        end
        %remove timestamps for bad channels
        data=data(~badix,:);
        %get timestamp indices for replacement channels
        repix=false(size(data,1),1);
        for j=1:nrep
            temp1=data(:,1)==rep1(j);
            temp2=data(:,2)==rep2(j);
            temp3=data(:,3)==rep3(j);
            temp=[temp1 temp2 temp3];
            temp=all(temp,2);
            repix(temp)=true;
        end
        %add some of replacement timestamps to bad channels
        r=round(nrep/nbad); %downsample ratio
        for j=1:nbad
            a=find(repix); %generate list of timestamps
            if r>0
                a=a(1:r:end); %downsample
            end
            repix=false(size(data,1),1); %reset ix
            repix(a)=true; %reset ix with
            l=length(a);
            badloc=[bad1(j) bad2(j) bad3(j)];
            badloc=repmat(badloc,[l,1]);
            data(end+1:end+l,:)=[badloc data(repix,4:8)];
        end
        %resave data
        eval(['DATA.' f{i} '=data;']);
    else
        %continuous data
        eval(['data=DATA.' f{i} ';']);
        %replace bad channels
        a=data(rep);
        a=reshape(a,[nrep,1,1,d(4:8)]);
        a=nanmean(a,1);
        a=repmat(a,[nbad,1,1,1,1,1,1,1]);
        data(bad)=a;
        %resave data
        eval(['DATA.' f{i} '=data;']);
    end
end
        
%% Resave data
%save(NOTES.SaveString,'DATA','NOTES','-v7.3');
close(f2);

