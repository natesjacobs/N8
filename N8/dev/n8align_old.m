function n8align_old(AutoAlignYesNo)
%align group data from Sload
%assumes data should be aligned within x/y plane (D1 and D2 of ND array)

%% Variables
global DATA DATAa NOTES STATS
if nargin<1, AutoAlignYesNo=1; end

%reset DATAa
DATAa=DATA;
%reset dimensions
d=ones(8,1);
eval(['dtemp=size(DATAa.' NOTES.CurrentField ');']);
d(1:length(dtemp))=dtemp;
%reset Crop
NOTES.CropX=true(d(1),1);
NOTES.CropY=true(d(2),1);
NOTES.CropZ=true(d(3),1);
%set alignment field to current
NOTES.Alignment.Field = NOTES.CurrentField;

%% Auto Align
if AutoAlignYesNo==1
    NOTES.Alignment.Mode='auto';
    %GET DATA
    anchor=n8getdata(NOTES.CurrentField);
    anchor=nanmean(anchor,8); %remove other
    anchor=nanmean(anchor,7); %remove trials
    
    %DETERMINE SPATIAL DIMENSIONS (1,2,3) TO BE SHIFTED
    D={[] [] []};
    d_space=d(1:3)>1;
    D{~d_space}=1;
    dims=find(d_space); %non-singleton dimensions
    for i=dims
        string{i}=['dimension ' num2str(dims(i)) ' (' num2str(d(i)) ')'];
    end
    choice = listdlg('PromptString','which dimension(s) to shift?','ListString',string,'SelectionMode','Multiple');
    dims=false(3,1);
    dims(choice)=true; %non-singleton dimensions to be shifted
    for i=1:length(find(dims))
        j=find(dims);
        j=j(i);
        D{j}=1:d(j);
    end
    
    %WHICH LOCATIONS TO USE FOR ALIGNMENT (IF NOT BEING SHIFTED)? 
    NOTES.Alignment.Locations={[] [] []};
    %find nonsingleton dimension NOT being shifted
    dims2=[dims';d(1:3)>1];
    dims2=diff(dims2);
    if sum(dims2)>0
        %ask which data to use for these dimensions
        for i=find(dims2)
            for j=1:d(i)
                options{j}=num2str(j);
            end
            D{i}=listdlg('PromptString',['align using what dim' num2str(i) ' data?'],'ListString',options,'SelectionMode','Multiple');
        end
        %average across selected elements for dims not being shifted
        anchor=anchor(D{1},D{2},D{3},:,:,:);
        for i=find(dims2)
            anchor=nanmean(anchor,i);
            NOTES.Alignment.Locations{i}=D{i};
        end
    end
    
    %WHICH CONDITIONS TO USE FOR ALIGNMENT?
    NOTES.Alignment.Conditions = 1;
    if d(5)>1
        for d5=1:d(5)
            conditions{d5}=num2str(d5);
        end
        D5 = listdlg('PromptString','align using which condition(s)?','ListString',conditions,'SelectionMode','Multiple');
        anchor=anchor(:,:,:,:,D5,:);
        anchor=nanmean(anchor,5);
        NOTES.Alignment.Conditions = D5;
    end
    
    %WHICH TIMES TO USE FOR ALIGNMENT?
    NOTES.Alignment.Times=1;
    if d(4)>1
        for d4=1:d(4)
            times{d4}=num2str(d4);
        end
        times{d(4)+1}='peak time';
        D4 = listdlg('PromptString','align using which time(s)?','ListString',times,'SelectionMode','Multiple');
        if D4<=d(4) %specific time point selected
            anchor=anchor(:,:,:,D4,:,:);
            anchor=nanmean(anchor,4);
        elseif D4==d(4)+1
            D4=[];
            d2=size(anchor);
            temp=reshape(anchor,d2(1)*d2(2)*d2(3),d2(4),d2(6));
            temp=max(temp,[],1);
            for d6=1:d(6)
                temp2=squeeze(temp(:,:,d6));
                temp2=gsmooth(temp2,1,round(d(4)/10));
                [~,D4(d6)]=max(temp2); %max value
%                 [~,pks]=findpeaks(temp2); %first peak
%                 D4(d6)=pks(1);
                %replace first element of dim 4 with data at peak time
                anchor(:,:,:,1,:,d6)=anchor(:,:,:,D4(d6),:,d6);
            end
            %remove data from other times
            anchor=anchor(:,:,:,1,:,:);
        end
        NOTES.Alignment.Times = D4;
    end
    
    %DETERMINE ALIGNMENT SHIFT
    %preallocate space for indices
    loc=ones(d(6),3);
    %make min =0 (removes negative values)
    anchor=anchor-min(anchor(:));
    %find indices of center of mass for each subject
    for d6=1:d(6)
        temp=centerofmass(anchor(:,:,:,:,:,d6));
        loc(d6,1:length(temp))=temp;
    end
    %save values
    NOTES.Alignment.Center=loc;
    shift=max(loc);
    shift=repmat(shift,[size(loc,1) 1 1]);
    shift=round(shift-loc);
    NOTES.Alignment.Shift=shift;
end

%% Manual Align
if AutoAlignYesNo==0
    NOTES.Alignment.Mode='manual';
    %which dims do you want to shift?
    dims=d(1:3)>1;
    dims=choose('shift which dimensions?',3,1,dims,{'Dim1' 'Dim2' 'Dim3'}');
    dims=find(dims);
    %have user input indices of anchors
    for d6=1:d(6)
        for i=1:length(dims)
            string{d6,i}=['subj' num2str(d6) '.dim' num2str(dims(i))];
        end
    end
    c=getnumber('Enter anchors for alignment',string,d(6),length(dims));
    choices=ones(d(6),3);
    for i=1:length(dims)
        j=dims(i);
        choices(:,j)=c(:,i);
    end
    NOTES.Alignment.Center=choices;
    shift=max(choices);
    shift=repmat(shift,[size(choices,1) 1 1]);
    shift=round(shift-choices);
    NOTES.Alignment.Shift=shift;
end

%% Shift data in each fieldname
%new dimensions
dnew=d;
dnew(1:3)=d(1:3)+max(shift)';
%check to make sure new dimensions won't crash computer
if prod(dnew)>2e9
    error('expanded & aligned data too large.');
end
%create new DATAa with shifted data
for f=1:length(NOTES.FieldNames)
    %create array of nans
    b=nan(dnew');
    %get data
    eval(['a=DATA.' NOTES.FieldNames{f} ';']);
    %update 4th dimension
    d(4)=size(a,4);
    dnew(4)=d(4);
    %shift data
    for d6=1:d(6)
        %x shift
        x=shift(d6,1);
        %y shift
        y=shift(d6,2);
        %z shift
        z=shift(d6,3);
        %shift data
        b(1+x:x+d(1),1+y:y+d(2),1+z:z+d(3),1:d(4),1:d(5),d6)=a(:,:,:,:,:,d6);
    end
    %save data
    eval(['DATAa.' NOTES.FieldNames{f} '=b;']);
    %update crop to only include locations with data from all subjects
    %replace all 0s with NaN
    b(b==0)=NaN;
    %collapse across d4 and d5
    test=nanmean(b,4);
    test=nanmean(test,5);
    %count nans across X,Y,Z
    test=~isnan(test);
    test=sum(test,6);
    testX=max(max(test,[],3),[],2)==d(6);
    testY=max(max(test,[],3),[],1)==d(6);
    testZ=max(max(test,[],2),[],1)==d(6);
    %save Crop values
    NOTES.CropX=testX;
    NOTES.CropY=testY';
    NOTES.CropZ=testZ';
end

%% Save results
%update dimensions
NOTES.Dimensions=dnew;
NOTES.Dimensions(1)=sum(NOTES.CropX);
NOTES.Dimensions(2)=sum(NOTES.CropY);
NOTES.Dimensions(3)=sum(NOTES.CropZ);
%save
save(NOTES.SaveString,'DATA','DATAa','NOTES','STATS');
disp('data aligned');
%replot data
n8plot;

