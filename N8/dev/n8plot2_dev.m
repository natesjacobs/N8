function n8plot2_dev
%plots all data for a single channel or ROI
%to add ROIs, use n8roi

%% Variables
global NOTES DATA
%dimensions
d=NOTES.Dimensions{1};

%% Store local copy of data
%store continuous data in local var
updateBinSize; %internal function (see below)

%% Figure window & axes
%plot window
f1 = figure('name','f1','Units','normalized',...
    'Outerposition',[0 0.04 1 0.94],...
    'Color',[0.9 0.9 0.9],...
    'toolbar','figure',...
    'WindowButtonMotionFcn',@updateX);
%axes (1 per continuous data type)
n=length(data);
ha=tight_subplot(n,1,0.02,[0.05 0.1],[0.05 0.01]);
linkaxes(ha);

%% UI - select channel(s)/ROI
%select channel button
b1 = uicontrol(gcf,'Style','pushbutton',...
    'String','::::',...
    'FontSize',16,...
    'Units','normalized',...
    'Position',[0.02 0.94 0.03 0.05],...
    'Callback',@(obj,evt)RefreshData(obj,evt));
%select roi button
b2 = uicontrol(gcf,'Style','popup',...
    'String','-',...
    'FontSize',16,...
    'Units','normalized',...
    'Position',[0.051 0.94 0.05 0.05],...
    'Callback',@(obj,evt)RefreshData(obj,evt));

%% UI constrain dimensions
%Dim 3: depth
for i=1:d(3)
    s{i}=['Depth ' num2str(i)];
end
b6=uicontrol(gcf,'Style','popup',...
        'String',s,...
        'FontSize',12,...
        'Units','normalized',...
        'Value',1,...
        'Position',[0.4 0.94 0.06 0.04],...
        'BackgroundColor',[0.82 0.82 0.82],...
        'Callback',@(obj,evt)RefreshData(obj,evt));
%Dims 6-8: subject, trials, and other
string={'Subj ' 'Trial ' 'Other '};
s={};
for i=1:3
    x=d(5+i);
    for j=1:x
        s{j}=[string{i} num2str(j)];
    end
    s{x+1}=[string{i} 'Mean'];
    val=[];
    eval(['val=NOTES.CurrentD' num2str(5+i) ';']);
    b7(i)=uicontrol(gcf,'Style','popup',...
        'String',s,...
        'FontSize',12,...
        'Units','normalized',...
        'Value',val,...
        'Position',[0.6+(0.061*i) 0.94 0.06 0.04],...
        'BackgroundColor',[0.82 0.82 0.82],...
        'Callback',@(obj,evt)RefreshData(obj,evt));
end

%% UI - miscellaneous
%normalize to baseline
b5 = uicontrol(gcf,'Style','popup',...
    'String',{' ' '-BL' '%BL'},...
    'Value',NOTES.BaselineNorm,...
    'FontSize',16,...
    'Units','normalized',...
    'Position',[0.11 0.94 0.05 0.05],...
    'BackgroundColor',[0.82 0.82 0.82],...
    'Callback',@(obj,evt)RefreshData(obj,evt));
%select conditions
for i=1:d(5)
    b8(i) = uicontrol(gcf,'Style','checkbox',...
        'String',['C' num2str(i)],...
        'FontSize',10,...
        'Units','normalized',...
        'BackgroundColor',[0.82 0.82 0.82],...
        'Value',1,...
        'Position',[(0.28+(i-1)*0.05) 0.95 0.04 0.02],...
        'Callback',@(obj,evt)RefreshData(obj,evt));
end
%Bin Size
b9 = uicontrol(gcf,'Style','edit',...
    'String',NOTES.BinSize/NOTES.SampleRate,...
    'FontSize',16,...
    'FontWeight','bold',...
    'Units','normalized',...
    'Position',[0.2 0.94 0.05 0.05],...
    'BackgroundColor',[0.82 0.82 0.82],...
    'Callback',@updateBinSize);
%show line plots
uicontrol(gcf,'Style','pushbutton',...
    'String','[   ]',...
    'FontSize',10,...
    'Units','normalized',...
    'Position',[0.96 0.94 0.03 0.05],...
    'BackgroundColor',[0.82 0.82 0.82],...
    'Callback','close; n8plot;');

%% Turn off buttons that are not applicable
%Depth
if isnan(NOTES.CurrentDepth)
    set(b6,'visible','off'); 
else
    set(b6,'value',NOTES.CurrentDepth);
end
%Subjects
if d(6)==1, set(b7(1),'visible','off'); end
%Trials
if d(7)==1, set(b7(2),'visible','off'); end
%Other/n-trode
if d(8)==1, set(b7(3),'visible','off'); end
%ROI
if ~isfield(NOTES,'ROI')
    set(b2,'visible','off');
    set(b1,'Position',[0.04 0.94 0.03 0.05]);
else
    set(b2,'string',fieldnames(NOTES.ROI));
end
%conditions
if d(5)==1
    for i=1:length(b8)
        set(b8(i),'visible','off');
    end
end

%% Initialize data
%get ROI
if ~isfield(NOTES,'CurrentROI');
    getROI;
    n8save;
end
%plot data
RefreshData([],[]); %plots data from first field name in RESULTS

%% Functions
    function RefreshData(src,evt)
        f2=msgbox('   please wait...');
        %update current depth (D3)
        if ~isnan(NOTES.CurrentDepth)
            NOTES.CurrentDepth=get(b6,'value');
        end
        %update current D6-D8
        NOTES.CurrentD6=get(b7(1),'value');
        NOTES.CurrentD7=get(b7(2),'value');
        NOTES.CurrentD8=get(b7(3),'value');
        %update Baseline norm
        if ~isempty(src) && src==b5
            NOTES.BaselineNorm=get(b5,'value');
            if isempty(NOTES.Baseline)
               n8baseline;
            end
        end
        %get ROI
        if ~isempty(src) && src==b1
            getROI;
        end
        if ~isempty(src) && src==b2
            c=get(b2,'string');
            eval(['NOTES.CurrentROI=NOTES.ROI.' c ';']);
        end
        %update selected conditions
        for i=1:length(b8)
            conds(i)=logical(get(b8(i),'value'));
        end
        %plot data
        PlotData;
    end
    function PlotData
        %constraints
        d6=NOTES.CurrentD6;
        d7=NOTES.CurrentD7;
        d8=NOTES.CurrentD8;
        if d6>d(6), d6=1:d(6); end
        if d7>d(7), d7=1:d(7); end
        if d8>d(7), d8=1:d(8); end
        %cycle through each data type
        for x=1:n
            %get data
            data1=data{x}(:,:,:,:,:,d6,d7,d8);
            %average any non-singleton D6-D8
            data2=nanmean(data1,6);
            data3=nanmean(data2,7);
            data4=nanmean(data3,8);
            %apply roi
            data4(~NOTES.CurrentROI)=NaN;
            %collapse spatial dimensions
            data4=reshape(data4,[d(1)*d(2)*d(3),d(4),d(5)]);
            data5=nanmean(data4,1);
            data5=permute(data5,[2,3,1]);
            %apply baseline normalization
            if NOTES.BaselineNorm>1
                try
                    w=ceil(NOTES.Baseline/NOTES.BinSize);
                    bl=mean(data5(w(1):w(2),:));
                catch
                    n8baseline;
                    w=ceil(NOTES.Baseline/NOTES.BinSize);
                    bl=mean(data5(w(1):w(2),:));
                end
                bl=repmat(bl,[size(data5,1) 1]);
                if NOTES.BaselineNorm==2
                    data5=data5-bl;
                elseif NOTES.BaselineNorm==3
                    data5=data5./bl;                    
                end
            end
            %remove unwanted conditions
            data5(:,~conds)=NaN;
            %bin data
            updateBinSize;
            %set axes
            figure(f1);
            set(gcf,'currentaxes',ha(x));
            set(gca,'ColorOrder',varycolor(d(5)));
            %plot data
            p=plot(data5,'LineWidth',2);
            if ts(x)
                %change TS data only
            end
            box off;
            ylabel(fn{x});
            set(gca,'Color',[0.9 0.9 0.9],'XLim',[1 d(4)]);
            %plot triggers
            tr=(NOTES.Triggers*NOTES.SampleRate)/NOTES.BinSize;
            hold on;
            scatter(tr,ones(1,length(tr))*mean(data5(:)),...
                'Marker','diamond',...
                'MarkerEdgeColor','k',...
                'MarkerFaceColor','w',...
                'SizeData',100);       
            hold off;
            if x<n
                set(gca,'XTickLabel',[]);
            else
                a=get(gca,'XTick');
                a=a/NOTES.SampleRate;
                a=a*NOTES.BinSize;
                if ~isempty(NOTES.Triggers)
                    a=a-NOTES.Triggers(1); %subtract trigger
                end
                d4=max(a(:));
                if d4>=3600
                    tstep=3600;
                    xlabel('(hr)');
                elseif d4>=60
                    tstep=60;
                    xlabel('(min)');
                elseif d4<1
                    tstep=1/1000;
                    xlabel('(ms)');
                else
                    tstep=1;
                    xlabel('(sec)');
                end
                a=a/tstep;
                set(gca,'XTickLabel',round(a*10)/10);
            end
        end
        close(f2);
    end
    function getROI
        %get current dimensions
        d=NOTES.Dimensions;
        %find non-singleton spatial dimensions
        dxy=d(1:3);
        dxy=dxy(dxy>1);
        %calculate n pixels
        npx=prod(dxy);
        %select channels
        if isnan(NOTES.CurrentDepth)
            %pick channel(s)
            if ~isempty(dxy)
                roi=n8choose(dxy(1),dxy(2));
            else
                roi=true(d(1:3));
            end
            %reshape into 3 spatial dims
            roi=roi(:); %vectorize
            roi=reshape(roi,[d(1),d(2),d(3)]); %reshape
            %extend to all time points, conditions
            roi=repmat(roi,[1,1,1,d(4),d(5)]);
            %save to global
            NOTES.CurrentROI=roi;
        else
            %create blank roi
            roi=false(d(1),d(2),d(3));
            %pick channel (dim 1/2)
            roi(:,:,NOTES.CurrentDepth)=n8choose(d(1),d(2),'Choose channel(s) to plot');
            %extend to all time points, conditions
            if ~isempty(roi)
                roi=repmat(roi,[1,1,1,d(4),d(5)]);
            else
                roi=NOTES.CurrentROI; %if user closes window before choosing
            end
        end
    end
    function newData
        for i=1:length(NOTES.FieldNames)
            eval(['data{i}=DATA.' NOTES.FieldNames{i} ';']);
            %data{i}=double(data{i});
        end
        d=ones(1,8);
        d(1:length(size(data{1})))=size(data{1});
        %make timestamp data into continuous variables
        n2=length(NOTES.FieldNames_TS);
        %get dimensions of first data field (must be continuous)
        d=ones(1,8);
        eval(['temp=size(DATA.' NOTES.FieldNames{1} ');']);
        d(1:length(temp))=temp;
        if n2>0
            for i=1:n2
                if ~isempty(data{end-n2+i})
                    %code taken from native matlab script (?)
                    %preallocate data as vector
                    temp=zeros(prod(d),1);
                    %Compute linear indices
                    k = [1 cumprod(d(1:end-1))];
                    ndx=ones(size(data{end-n2+i},1),1);
                    for j = 1:8
                        v = data{end-n2+i}(:,j);
                        v=double(v);
                        ndx = ndx + (v-1)*k(j);
                    end
                    %add timestamps to vector
                    ndx=ndx(ndx>0);
                    temp(ndx)=1;
                    %reshape vector into N8 array
                    temp=reshape(temp,d);
                    data{end-n2+i}=temp;
                    clearvars temp;
                end
                ts(length(data)-n2+i)=true;
            end
        else
            ts=false(1,length(data));
        end
        %check duration of each data type
        for i=1:length(data)
            a(i)=size(data{i},4);
        end
        a=a==max(a(:));
        %remove data types with less than full time duration
        data=data(a);
        ts=ts(a);
        fn=NOTES.FieldNames(a);
        n=length(data);
    end
    function updateBinSize(~,~)
        if nargin==0
            bin=NOTES.BinSize;
        else
            bin=get(b9,'string');
            bin=str2num(bin);
            bin=round(bin*NOTES.SampleRate);
            if bin==0
                bin=1;
            end
            NOTES.BinSize=bin;            
        end
        %get new data
        newData;
        %update 
        for i=1:length(data)
            %temp
            temp=data{i};
            %dimensions
            d=ones(1,8);
            d(1:length(size(temp)))=size(temp);
            %crop data if d(4) doesn't divide evenly by bin size
            cut = rem(d(4),bin);
            %cut = b-cut;
            temp=temp(:,:,:,1:end-cut,:,:,:,:);
            %update d4
            d(4)=size(temp,4);
            %add new dimension before dim4
            temp=reshape(temp,[d(1),d(2),d(3),bin,d(4)/bin,d(5),d(6),d(7),d(8)]);
            %average across binsize
            temp=nanmean(temp,4);
            %remove added dimension
            d(4)=size(temp,5);
            temp=reshape(temp,[d(1),d(2),d(3),d(4),d(5),d(6),d(7),d(8)]);
            %adjust ts to sum (rather than mean)
            if ts(i)
                temp=temp/(bin/NOTES.SampleRate);
            end
            %resave
            data{i}=temp;
        end
        %Reset dimensions
        d=ones(1,8);
        d(1:length(size(data{1})))=size(data{1});
        NOTES.Dimensions=d;
        %update current ROI
        NOTES.CurrentROI=NOTES.CurrentROI(:,:,:,1,:,:,:,:);
        NOTES.CurrentROI=repmat(NOTES.CurrentROI,[1,1,1,d(4),1,1,1,1]);
        %refresh plot
        if nargin>0
            RefreshData(0,0);
        end
    end
end