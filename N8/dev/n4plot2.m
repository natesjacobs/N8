function n4plot2
%plots all data for a single channel or ROI
%to add ROIs, use n8roi

%% Variables
global NOTES DATA
%dimensions
d=NOTES.Dimensions{1};
if any(d(5:8)>1)
    error('n4plot2 can only handle 4D arrays')
end
%number of plots
n=length(NOTES.Fields);
%persistent ROI variables
ROI=[]; R=[]; nroi=[]; C=[];
%figure color
c=[1 1 1];
currentfield=NOTES.CurrentField;

%% Reference figure with ROIs
f2a = figure('Units','normalized',...
    'Outerposition',[0 0 0.38 0.6],...
    'Color',[0.15 0.15 0.15],...
    'toolbar','none');
tight_subplot;
im=imagesc([]);
axis image off;
datacursormode on;

%% Figure window, axes, and plot handles
%plot window
f2 = figure('Units','normalized',...
    'Outerposition',[0 0 1 1],...
    'Color',c,...
    'toolbar','none');
%axes
%ha=tight_subplot(n,1,0.01,0.01,0.07);
ha=tight_subplot(n,1,0.01,0.01,0.07);
set(ha,'visible','off');
for i=1:n
    hold(ha(i),'on');
end
linkaxes(ha,'x');

%% UI - Select ROIs
j=0;
k=0;
for i=1:100
    if i>50
        j=0.02;
        k=0.925;
    end
    b1(i) =  uicontrol(gcf,'Style','togglebutton',...
        'String',num2str(i),...
        'FontSize',10,...
        'Units','normalized',...
        'Position',[0.01+j 0.96-(0.0185*i)+k 0.02 0.0185],...
        'BackgroundColor',[0.82 0.82 0.82],...
        'Callback',@(obj,evt)RefreshData(obj,evt));
end

%% UI - binsize
%Bin size
b2 = uicontrol(gcf,'Style','edit',...
    'String',round(NOTES.BinSize*1e4/NOTES.SampleRate)/1e4,...
    'FontSize',14,...
    'FontWeight','bold',...
    'Units','normalized',...
    'BackgroundColor',c,...
    'ForegroundColor',[0.7 0.7 0.7],...
    'Position',[0.86 0.95 0.04 0.04],...
    'Callback',@(obj,evt)RefreshData(obj,evt));
uicontrol(gcf,'Style','text',...
    'string',['(' NOTES.TimeScaleString ')'],...
    'FontSize',16,...
    'HorizontalAlignment','left',...
    'BackgroundColor',c,...
    'ForegroundColor',[0.7 0.7 0.7],...
    'Units','normalized',...
    'Position',[0.905 0.952 0.03 0.03]);

%% UI constrain Dims 5-8: condition, subject, trials, and other
%create strings
for i=[3 5:8]
    for j=1:d(i)
        s{i}{j}=['D' num2str(i) '-' num2str(j)];
    end
    s{i}{end+1}=['D' num2str(i) '-ave'];
    s{i}{end+1}=['D' num2str(i) '-all'];
end
%Dim 3 (depth)
b3=uicontrol(gcf,'Style','popup',...
        'String',s{3},...
        'FontSize',12,...
        'Units','normalized',...
        'Value',1,...
        'Position',[0.91 0.9 0.04 0.03],...
        'BackgroundColor',[0.82 0.82 0.82],...
        'Callback',@(obj,evt)UpdateDims(obj,evt));
% %Dim 5 (condition)
% b5 = uicontrol(gcf,'Style','popup',...
%         'String',s{5},...
%         'FontSize',12,...
%         'Units','normalized',...
%         'Value',NOTES.CurrentD5,...
%         'Position',[.95 0.82 0.04 0.03],...
%         'BackgroundColor',[0.82 0.82 0.82],...
%         'Callback',@(obj,evt)RefreshData(obj,evt));
% %Dim 6 (subject)
% b6 = uicontrol(gcf,'Style','popup',...
%         'String',s{6},...
%         'FontSize',12,...
%         'Units','normalized',...
%         'Value',NOTES.CurrentD6,...
%         'Position',[0.95 0.79 0.04 0.03],...
%         'BackgroundColor',[0.82 0.82 0.82],...
%         'Callback',@(obj,evt)RefreshData(obj,evt));
% %Dim 7 (trial)
% b7 = uicontrol(gcf,'Style','popup',...
%         'String',s{7},...
%         'FontSize',12,...
%         'Units','normalized',...
%         'Value',NOTES.CurrentD7,...
%         'Position',[0.95 0.76 0.04 0.03],...
%         'BackgroundColor',[0.82 0.82 0.82],...
%         'Callback',@(obj,evt)RefreshData(obj,evt));
% %Dim 8 (other)
% b8 = uicontrol(gcf,'Style','popup',...
%         'String',s{8},...
%         'FontSize',12,...
%         'Units','normalized',...
%         'Value',NOTES.CurrentD8,...
%         'Position',[0.95 0.71 0.04 0.05],...
%         'BackgroundColor',[0.82 0.82 0.82],...
%         'Callback',@(obj,evt)RefreshData(obj,evt));

%% UI miscellaneous
%show frames
uicontrol(gcf,'Style','pushbutton',...
    'String','[ ]',...
    'FontSize',14,...
    'Units','normalized',...
    'Position',[0.96 0.01 0.03 0.04],...
    'BackgroundColor',[0.82 0.82 0.82],...
    'Callback','close; n8plot;');
%file name
uicontrol(gcf,'Style','text',...
    'String',NOTES.SaveString,...
    'FontSize',14,...
    'FontWeight','bold',...
    'HorizontalAlignment','left',...
    'Units','normalized',...
    'Position',[0.01 0.01 0.1 0.02],...
    'BackgroundColor',c,...
    'ForegroundColor',[0.35 0.35 0.35]);

%% Hide irrelevant GUIs
if isnan(NOTES.CurrentD3)                                       %D3
    set(b3,'visible','off');             
else
    set(b3,'value',NOTES.CurrentD3); 
end
% if d(5)==1, set(b5,'visible','off'); end                        %D5
% if d(6)==1, set(b6,'visible','off'); end                        %D6
% if d(7)==1, set(b7,'visible','off'); end                        %D7
% if d(8)==1, set(b8,'visible','off'); end                        %D8

%% Initialize data
%update ROI
updateroi;
%plot data
RefreshData([],[]); %plots data from first field name in RESULTS
%bring ROI map in focus
figure(f2a);

%% Functions
    function checkvals
        %get ROIs
        R=false(nroi,1);
        for i=1:nroi
            R(i)=get(b1(i),'value');
        end
        %get bin size
        bin=str2double(get(b2,'string')); %in time units (ms/sec/hr)
        NOTES.BinSize=(bin*NOTES.SampleRate)/NOTES.TimeScale; %in elements
        %depth
        D3=get(b3,'value');     %Depth (D3)
        if D3>1
            NOTES.CurrentD3=D3;
        end
%         %Other dims
%         D5=get(b5,'value');     %Depth (D5)
%         D6=get(b6,'value');     %Depth (D6)
%         D7=get(b7,'value');     %Depth (D7)
%         D8=get(b8,'value');     %Depth (D8)
    end
    function setcurrentdims %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%         %Other (D5-8)
%         if D5>d(5), D5=1:d(5); end
%         if D5>d(6), D5=1:d(6); end
%         if D5>d(7), D5=1:d(7); end
%         if D5>d(8), D5=1:d(8); end
%         NOTES.CurrentD5=D5;
%         NOTES.CurrentD6=D6;
%         NOTES.CurrentD7=D7;
%         NOTES.CurrentD8=D8;
    end
    function RefreshData(src,evt)
        figure(f2);
        %set data type & dimensions
        checkvals;
        setcurrentdims;
        %if changing dimensions, update roi
        if src==b3
            updateroi;
        end
        for i=1:n
            %clear axes
            cla(ha(i));
            if any(R)
                %set current field
                NOTES.CurrentField=i;
                %refresh plot data
                r=find(R);
                for j=1:length(r)
                    NOTES.CurrentROI = ROI==r(j);
                    n4getdata2;
                    %get min/max
                    mn(j)=min(NOTES.CurrentData(:));
                    mx(j)=max(NOTES.CurrentData(:));
                    plot(ha(i),bin(NOTES.CurrentData,NOTES.BinSize),'color',C(r(j),:),'linewidth',2);
                end
                %set Yaxis lim
                set(ha(i),'YLim',[min(mn(:)) max(mx(:))]);
            end
        end
        %set Xaxis lim
        set(ha,'XLim',[1 NOTES.Dimensions{1}(4)/NOTES.BinSize]);
        %reset current field
        NOTES.CurrentField=currentfield;
    end
    function updateroi
        if isnan(NOTES.CurrentD3)
            ROI=squeeze(NOTES.ROI);
        else
            ROI=NOTES.ROI(:,:,NOTES.CurrentD3);
        end
        %update persistent vars
        ROI=bwlabel(ROI);
        nroi=max(ROI(:));
        %update ROI map
        im.CData=ROI;
        %update roi buttons
        for i=1:nroi
            set(b1(i),'visible','on','value',0);
        end
        for i=nroi+1:100
            set(b1(i),'visible','off','value',0);
        end
        %turn first roi on
        set(b1(1),'value',1);
        %update plot colors
        if nroi<64
            x=64/nroi;
            C=parula;
            C=C(round(1:x:end),:);
        else
            C=varycolor(nroi);
        end
    end
end
