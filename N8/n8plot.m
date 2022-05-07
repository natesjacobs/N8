function n8plot
%time is in sec for all figure GUIs
%time is in elements for CurrentD4 and BinSize

%% Variables
global NOTES DATA
%dimensions
d=NOTES.Dimensions{NOTES.CurrentField};
%Set current time if var doesn't exist
if ~isfield(NOTES,'CurrentTime')
    NOTES.CurrentTime=1;
end
SR=NOTES.SampleRate;
%Initialize variables that span multiple functions
%close open windows
close all;
resetC=true;

%% Figure window, axes, and image data
%plot window
f1 = figure('name','f1','Units','normalized',...
    'Outerposition',[0 0 1 1],...
    'Color',[0.15 0.15 0.15],...
    'toolbar','none');
%axes
tight_subplot(1,1,[0.01 0.001],[0.01 0.06],0);
%image data (continuous)
im=imagesc([]);
axis image off;
c=colorbar('Location','South');
set(c,'XTick',[],'Position',[0.041 0.9495 0.1485 0.042]);
%scatter data (timestamps)
hold on;
sc=scatter([],[],'MarkerFaceColor',[0.9 0.95 1],'MarkerEdgeColor','k','SizeData',25,'LineWidth',0.5);

%% UI data type: continuous
%Current field value
b1 = uicontrol(gcf,'Style','popup',...
    'String',NOTES.Fields,...
    'Value',NOTES.CurrentField,...
    'FontSize',16,...
    'Units','normalized',...
    'Position',[0.9 0.94 0.09 0.05],...
    'BackgroundColor',[0.82 0.82 0.82],...
    'Callback',@(obj,evt)RefreshData(obj,evt));

%% UI data type: timestamps
b2 = uicontrol(gcf,'Style','popup',...
    'String','temp',...
    'Value',1,...
    'FontSize',12,...
    'Units','normalized',...
    'Position',[0.9 0.923 0.09 0.03],...
    'BackgroundColor',[0.82 0.82 0.82],...
    'Callback',@(obj,evt)RefreshData(obj,evt));
if ~isnan(NOTES.CurrentField_t)
    set(b2,'string',NOTES.Fields{NOTES.TSvars},'value',NOTES.CurrentField_t);
end

%% UI constrain Dim 4: time
%Start time
b4a= uicontrol(gcf,'Style','slider',...
    'Min',1,...
    'Max',2,...
    'SliderStep',[0.1 0.5],...
    'Value',1,...
    'Units','normalized',...
    'Position',[0.28 0.95 0.37 0.04],...
    'BackgroundColor',[0.82 0.82 0.82],...
    'Callback',@(obj,evt)RefreshData(obj,evt));
updateslider;
%Bin size
b4b = uicontrol(gcf,'Style','edit',...
    'String',round(NOTES.BinSize*1e4/SR)/1e4,...
    'FontSize',14,...
    'FontWeight','bold',...
    'Units','normalized',...
    'BackgroundColor',[0.15 0.15 0.15],...
    'ForegroundColor',[0.7 0.7 0.7],...
    'Position',[0.661 0.95 0.04 0.04],...
    'Callback',@(obj,evt)RefreshData(obj,evt));
uicontrol(gcf,'Style','text',...
    'string',['(' NOTES.TimeScaleString ')'],...
    'FontSize',16,...
    'HorizontalAlignment','left',...
    'BackgroundColor',[0.15 0.15 0.15],...
    'ForegroundColor',[0.7 0.7 0.7],...
    'Units','normalized',...
    'Position',[0.704 0.952 0.04 0.03]);

%% UI constrain Dims 5-8: condition, subject, trials, and other
%create strings
for i=[3 5:8]
    for j=1:d(i)
        s{i}{j}=['D' num2str(i) '-' num2str(j)];
    end
    s{i}{end+1}=['D' num2str(i) '-ave'];
end
%make sure current dims are scalar
for i=[3 5:8]
    if length(NOTES.CurrentDims{i})>1
        NOTES.CurrentDims{i}=1;
    end
end
%Dim 3 (depth)
b3=uicontrol(gcf,'Style','popup',...
        'String',s{3},...
        'FontSize',14,...
        'Units','normalized',...
        'Value',1,...
        'Position',[0.95 0.854 0.04 0.03],...
        'BackgroundColor',[0.82 0.82 0.82],...
        'Callback',@(obj,evt)RefreshData(obj,evt));
%Dim 5 (condition)
b5 = uicontrol(gcf,'Style','popup',...
        'String',s{5},...
        'FontSize',14,...
        'Units','normalized',...
        'Value',NOTES.CurrentDims{5},...
        'Position',[.95 0.82 0.04 0.03],...
        'BackgroundColor',[0.82 0.82 0.82],...
        'Callback',@(obj,evt)RefreshData(obj,evt));
%Dim 6 (subject)
b6 = uicontrol(gcf,'Style','popup',...
        'String',s{6},...
        'FontSize',14,...
        'Units','normalized',...
        'Value',NOTES.CurrentDims{6},...
        'Position',[0.95 0.79 0.04 0.03],...
        'BackgroundColor',[0.82 0.82 0.82],...
        'Callback',@(obj,evt)RefreshData(obj,evt));
%Dim 7 (trial)
b7 = uicontrol(gcf,'Style','popup',...
        'String',s{7},...
        'FontSize',14,...
        'Units','normalized',...
        'Value',NOTES.CurrentDims{7},...
        'Position',[0.95 0.76 0.04 0.03],...
        'BackgroundColor',[0.82 0.82 0.82],...
        'Callback',@(obj,evt)RefreshData(obj,evt));
%Dim 8 (other)
b8 = uicontrol(gcf,'Style','popup',...
        'String',s{8},...
        'FontSize',14,...
        'Units','normalized',...
        'Value',NOTES.CurrentDims{8},...
        'Position',[0.95 0.71 0.04 0.05],...
        'BackgroundColor',[0.82 0.82 0.82],...
        'Callback',@(obj,evt)RefreshData(obj,evt));

%% UI color scale
C=NOTES.Threshold(NOTES.CurrentField,:);
%threshold
b9=uicontrol(gcf,'Style','edit',...
    'String',num2str(C(1)),...
    'FontSize',10,...
    'FontWeight','bold',...
    'Units','normalized',...
    'Position',[0.01 0.95 0.03 0.04],...
    'BackgroundColor',[0.82 0.82 0.82],...
    'Callback',@(obj,evt)RefreshData(obj,evt));
b10=uicontrol(gcf,'Style','edit',...
    'String',num2str(C(2)),...
    'FontSize',10,...
    'FontWeight','bold',...
    'Units','normalized',...
    'Position',[0.191 0.95 0.03 0.04],...
    'BackgroundColor',[0.82 0.82 0.82],...
    'Callback',@(obj,evt)RefreshData(obj,evt));


%% UI miscellaneous
%show line plots
b11 = uicontrol(gcf,'Style','pushbutton',...
    'String','~',...
    'FontSize',14,...
    'Units','normalized',...
    'Position',[0.96 0.01 0.03 0.04],...
    'BackgroundColor',[0.82 0.82 0.82],...
    'Callback','close all; n8plot2;');
%get ROI (for data with large spatial dimensions)
if prod(d(1:3))>100
    b12 = uicontrol(gcf,'Style','pushbutton',...
        'String','ROI',...
        'FontSize',14,...
        'Units','normalized',...
        'Position',[0.927 0.01 0.03 0.04],...
        'BackgroundColor',[0.82 0.82 0.82],...
        'Callback','close all; n8roi;');
end
%file name
uicontrol(gcf,'Style','text',...
    'String',NOTES.SaveString,...
    'FontSize',14,...
    'FontWeight','bold',...
    'HorizontalAlignment','left',...
    'Units','normalized',...
    'Position',[0.01 0 0.2 0.03],...
    'BackgroundColor',[0.15 0.15 0.15],...
    'ForegroundColor',[0.4 0.4 0.4]);

%% Hide irrelevant GUIs
if ~all(NOTES.TSvars), set(b2,'visible','off'); end    %timestamp data
if ~NOTES.data3D                                     %D3
    set(b3,'visible','off');             
else
    set(b3,'value',NOTES.CurrentDims{3}); 
end
if d(4)/NOTES.BinSize <2, set(b4a,'visible','off'); end         %D4 (start)
if d(4)/NOTES.BinSize <2, set(b4b,'visible','off'); end         %D4 (start)
if d(5)==1, set(b5,'visible','off'); end                        %D5
if d(6)==1, set(b6,'visible','off'); end                        %D6
if d(7)==1, set(b7,'visible','off'); end                        %D7
if d(8)==1, set(b8,'visible','off'); end                        %D8
if isempty(NOTES.ROI), set(b11,'visible','off'); end
if isfield(NOTES,'ROIghost')
    set(b11,'visible','on');
    set(b12,'visible','off');
end

%% Initialize data
%misc.
D3=[]; D4=[]; D4a=[]; D4b=[]; D5=[]; D6=[]; D7=[]; D8=[];
%plot data
RefreshData(b1,[]); %plots data from first field name in RESULTS
%misc.


%% Functions
    function RefreshData(src,evt)
        %check if new data
        if src==b1
            resetC=true;
        end
        %set data type & dimensions
        checkvals;
        setcurrentdims;
        d=NOTES.Dimensions{NOTES.CurrentField};
        %to add multiple frames back in, use loop here%%%%%%%%%%%%%%%%%%%%
        %get data at new dimensions
        n8getdata;
        %refresh image
        if isfield(NOTES,'ROIghost')
            roidata;
        end
        im.CData=squeeze(NOTES.CurrentData);
        %refresh timestamps
        if ~isempty(NOTES.CurrentData_t)
            sc.XData=NOTES.CurrentData_t(1,:);
            sc.YData=NOTES.CurrentData_t(2,:);
        end
    end
    function roidata
        %check if number of elements = number of ROIs
        roi=bwlabel(NOTES.ROIghost);
        if max(roi(:)) == numel(NOTES.CurrentData)
            for i=1:numel(NOTES.CurrentData)
            roi(roi==i)=NOTES.CurrentData(i);
            end
            NOTES.CurrentData=roi;
        end
    end
    function checkvals
        %Data type (continuous)
        NOTES.CurrentField=get(b1,'value');
        %Data type (timestamps)
        if ~isnan(NOTES.CurrentField_t)
            NOTES.CurrentField_t=get(b2,'value');
        end
        %Threshold
        C(1)=str2double(get(b9,'string'));
        C(2)=str2double(get(b10,'string'));
        setclims; %reset if new data, reject if not increasing
        %Time
        %matlab bug with slider bar
        if NOTES.BinSize>1 && get(b4a,'value')>get(b4a,'Max')-NOTES.BinSize
            set(b4a,'value',1);
        end
        D4a=get(b4a,'value')*NOTES.BinSize;   %D4-start
        D4b=str2double(get(b4b,'string'));  %D4-bin
        %Dimensions (save to NOTES in setcurrentdims)
        D3=get(b3,'value');     %Depth (D3)
        D5=get(b5,'value');     %Depth (D5)
        D6=get(b6,'value');     %Depth (D6)
        D7=get(b7,'value');     %Depth (D7)
        D8=get(b8,'value');     %Depth (D8)
    end
    function setclims
        %check caxis parameters from GUIs
        if resetC
            C=NOTES.Threshold(NOTES.CurrentField,:);
            %check if caxis should be symmetric
            if NOTES.Cmap(NOTES.CurrentField)==1
                %set color map
                set(f1,'Colormap',gray);
                %enable both c thresh
                set(b9,'enable','on');
            elseif NOTES.Cmap(NOTES.CurrentField)==2
                %set color map
                set(f1,'Colormap',cmap2);
                %disable lower c thresh
                set(b9,'enable','off');
                %set lower thresh to -high thresh
                C(1)=-C(2);
            end
            resetC=false;
        end
        %check if increasing
        if C(1)>C(2)
            C=NOTES.Threshold(NOTES.CurrentField,:);
        end
        %check for NaNs
        if any(isnan(C))
            if isempty(NOTES.CurrentData)
                C=[0 1];
            else
                C(1)=min(NOTES.CurrentData(:));
                C(2)=max(NOTES.CurrentData(:));
            end
            NOTES.Threshold(NOTES.CurrentField,:)=C;
        end
        %reset symmetric axis (if applicable)
        if NOTES.Cmap(NOTES.CurrentField)==2
            C(1)=-C(2);
        end
        %reset buttons
        set(b9,'string',num2str(C(1)));
        set(b10,'string',num2str(C(2)));
        %reset color axis
        caxis(C);
        %reset globals
        NOTES.Threshold(NOTES.CurrentField,:)=C;
    end
    function setcurrentdims       
        %Depth (D3)
        if ~isnan(NOTES.CurrentDims{3})
            NOTES.CurrentDims{3}=D3;
        end
        %Time (D4)
        D4a=round(D4a);
        D4b=round(D4b*NOTES.SampleRate/NOTES.TimeScale); %convert user input to elements
        if (D4a+D4b)>NOTES.Dimensions{NOTES.CurrentField}(4)
            D4a=1;
            set(b4a,'value',D4a/NOTES.BinSize); %update slider bar
        end
        if D4b==0
            D4b=1; 
        end
        %update guis
        set(b4b,'string',num2str(D4b*NOTES.TimeScale/NOTES.SampleRate)); %update input string
        %set current dims
        D4=D4a:D4a+D4b-1;
        if D4(end)>d(4)
            D4=D4+(d(4)-D4(end));
        end
        NOTES.CurrentDims{4}=D4;
        if D4b~=NOTES.BinSize
            NOTES.BinSize=D4b;
            updateslider;
        end
        %Other (D5-8)
        if D5>d(5), D5=1:d(5); end
        if D6>d(6), D6=1:d(6); end
        if D7>d(7), D7=1:d(7); end
        if D8>d(8), D8=1:d(8); end
        NOTES.CurrentDims{5}=D5;
        NOTES.CurrentDims{6}=D6;
        NOTES.CurrentDims{7}=D7;
        NOTES.CurrentDims{8}=D8;
    end 
    function updateslider
        %max value
        mx=round(d(4)/NOTES.BinSize);
        %current value
        val=floor((NOTES.CurrentDims{4}(1)/d(4))*mx);
        if val==0, val=1; end
        %small step size (1 bin)
        smstep=1/mx; %1 bin as %mx
        %big step size (1 unit of time, 1 ms, sec or hr)
        bgstep=NOTES.BinSize/NOTES.SampleRate/NOTES.TimeScale; %time units per bin
        bgstep=1/bgstep; %bins per time unit
        bgstep=bgstep/mx; %1 time unit as %mx
        %update slider properties
        set(b4a,'Max',mx+1,'SliderStep',[smstep bgstep],'Value',val);
    end
end
