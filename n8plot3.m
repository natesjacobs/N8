function n8plot3
%to plot multi-variate measures

%% Variables
global NOTES DATA
%dimensions
d=NOTES.Dimensions{1};
%number of plots
n=length(NOTES.Fields);
%persistent ROI variables
ROI=[]; R=[]; nroi=[]; C=[]; b1=[];
%figure color
c=[1 1 1];
currentfield=NOTES.CurrentField;

%% Check array size
sz=max([prod(d([1,2])) prod(d([1,3])) prod(d([2,3]))]);
if sz>500
    %for large arrays, use ROIs
    bigarray=true;
    if isempty(NOTES.ROI)
        error('segment large frames into ROIs using n8roi');
    end
else
    %for small arays, use channels/pixels
    bigarray=false;
end

%% Reference figure with ROIs
if bigarray
    f2a = figure('Units','normalized',...
        'Outerposition',[0 0 0.5 1],...
        'Color',[0.15 0.15 0.15],...
        'toolbar','none');
    tight_subplot;
    im=imagesc([]);
    axis image off;
    datacursormode on;
end

%% Figure window, axes, and plot handles
%full window if no ROIs
if bigarray
    pos=[0.05 0 0.95 1];
else
    pos=[0 0 1 1];
end
%plot window
f2 = figure('Units','normalized',...
    'Outerposition',pos,...
    'Color',c,...
    'toolbar','none');
%axes
ha=tight_subplot(n,1,0.01,[0.05 0.01],0.07);
set(ha,'visible','off');
for i=1:n
    hold(ha(i),'on');
end
linkaxes(ha,'x');

%% UI - Select ROIs
updateroi;
roibuttons; %creates pushbuttons for each roi/ch

%% UI - binsize
%Bin size
b2 = uicontrol(gcf,'Style','edit',...
    'String',round(NOTES.BinSize*1e4/NOTES.SampleRate)/1e4,...
    'FontSize',14,...
    'FontWeight','bold',...
    'Units','normalized',...
    'BackgroundColor',c,...
    'ForegroundColor',[0.5 0.5 0.5],...
    'Position',[0.91 0.95 0.04 0.04],...
    'Callback',@(obj,evt)RefreshData(obj,evt));
uicontrol(gcf,'Style','text',...
    'string',['(' NOTES.TimeScaleString ')'],...
    'FontSize',16,...
    'HorizontalAlignment','left',...
    'BackgroundColor',c,...
    'ForegroundColor',[0.5 0.5 0.5],...
    'Units','normalized',...
    'Position',[0.955 0.952 0.04 0.03]);

%% UI constrain Dims 5-8: condition, subject, trials, and other
%create strings
for i=[3 5:8]
    for j=1:d(i)
        s{i}{j}=['D' num2str(i) '-' num2str(j)];
    end
end
%Dim 3 (depth)
b3=uicontrol(gcf,'Style','popup',...
        'String',s{3},...
        'FontSize',12,...
        'Units','normalized',...
        'Value',1,...
        'Position',[0.95 0.86 0.04 0.03],...
        'BackgroundColor',[0.82 0.82 0.82],...
        'Callback',@(obj,evt)UpdateDims(obj,evt));
%Dim 5 (condition)
b5 = uicontrol(gcf,'Style','popup',...
        'String',s{5},...
        'FontSize',12,...
        'Units','normalized',...
        'Value',NOTES.CurrentD5,...
        'Position',[.95 0.82 0.04 0.03],...
        'BackgroundColor',[0.82 0.82 0.82],...
        'Callback',@(obj,evt)RefreshData(obj,evt));
%Dim 6 (subject)
b6 = uicontrol(gcf,'Style','popup',...
        'String',s{6},...
        'FontSize',12,...
        'Units','normalized',...
        'Value',NOTES.CurrentD6,...
        'Position',[0.95 0.79 0.04 0.03],...
        'BackgroundColor',[0.82 0.82 0.82],...
        'Callback',@(obj,evt)RefreshData(obj,evt));
%Dim 7 (trial)
b7 = uicontrol(gcf,'Style','popup',...
        'String',s{7},...
        'FontSize',12,...
        'Units','normalized',...
        'Value',NOTES.CurrentD7,...
        'Position',[0.95 0.76 0.04 0.03],...
        'BackgroundColor',[0.82 0.82 0.82],...
        'Callback',@(obj,evt)RefreshData(obj,evt));
%Dim 8 (other)
b8 = uicontrol(gcf,'Style','popup',...
        'String',s{8},...
        'FontSize',12,...
        'Units','normalized',...
        'Value',NOTES.CurrentD8,...
        'Position',[0.95 0.71 0.04 0.05],...
        'BackgroundColor',[0.82 0.82 0.82],...
        'Callback',@(obj,evt)RefreshData(obj,evt));

%% UI miscellaneous
%data type names
pos=[0.07 0.9 0.05 0.03];
for i=1:n
    pos(2)=0.9 -(0.95/n)*(i-1);
    uicontrol(gcf,'Style','text',...
        'String',NOTES.Fields{i},...
        'FontSize',18,...
        'HorizontalAlignment','left',...
        'Units','normalized',...
        'Position',pos,...
        'BackgroundColor',c,...
        'ForegroundColor','k');
end
%show frames
uicontrol(gcf,'Style','pushbutton',...
    'String','[  ]',...
    'FontSize',14,...
    'Units','normalized',...
    'Position',[0.95 0.01 0.04 0.04],...
    'BackgroundColor',[0.94 0.94 0.94],...
    'Callback','close; n8plot;');
%file name
uicontrol(gcf,'Style','text',...
    'String',NOTES.SaveString,...
    'FontSize',14,...
    'FontWeight','bold',...
    'Units','normalized',...
    'Position',[0.2 0 0.6 0.03],...
    'BackgroundColor',c,...
    'ForegroundColor',[0.35 0.35 0.35]);

%% Hide irrelevant GUIs
if isnan(NOTES.CurrentD3)                                       %D3
    set(b3,'visible','off');             
else
    set(b3,'value',NOTES.CurrentD3); 
end
if d(5)==1, set(b5,'visible','off'); end                        %D5
if d(6)==1, set(b6,'visible','off'); end                        %D6
if d(7)==1, set(b7,'visible','off'); end                        %D7
if d(8)==1, set(b8,'visible','off'); end                        %D8

%% Initialize data
%plot data
RefreshData([],[]); %plots data from first field name in RESULTS
%bring ROI map in focus
if bigarray 
    figure(f2a);
end
%% Functions
    function checkvals
        %get ROIs
        R=false(nroi,1);
        for i=1:nroi
            R(i)=get(b1(i),'value')==1;
        end
        %check if 'all' button pressed/ just unpressed
        if R(end)
            R(:)=true;
            set(b1,'value',1);
        elseif all(R(1:end-1))
            R(2:end)=false;
            set(b1(2:end),'value',0);
        end
        %get bin size
        bin=str2double(get(b2,'string')); %in time units (ms/sec/hr)
        NOTES.BinSize=(bin*NOTES.SampleRate)/NOTES.TimeScale; %in elements
        if NOTES.BinSize==0
            NOTES.BinSize=1;
            set(b2,'string',num2str(1/NOTES.SampleRate));
        end
        %depth
        D3=get(b3,'value');     %Depth (D3)
        if D3>1
            NOTES.CurrentD3=D3;
        end
        %Other dims
        NOTES.CurrentD5=get(b5,'value');     %Other (D5)
        NOTES.CurrentD6=get(b6,'value');     %Other (D6)
        NOTES.CurrentD7=get(b7,'value');     %Other (D7)
        NOTES.CurrentD8=get(b8,'value');     %Other (D8)
    end
    function RefreshData(src,evt)
        figure(f2);
        %set data type & dimensions
        checkvals;
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
                r=find(R(1:end-1));
                for j=1:length(r)
                    NOTES.CurrentROI = ROI==r(j);
                    n8getdata2; %saves cont data in NOTES.CurrentData, timestamps in NOTES.CurrentData_t
                    %get min/max
                    mn(j)=min(NOTES.CurrentData(:));
                    mx(j)=max(NOTES.CurrentData(:));
                    if NOTES.TSvars(i)
                        scatter(ha(i),NOTES.CurrentData_t/NOTES.BinSize,ones(length(NOTES.CurrentData_t),1)*0.5,...
                            'sizedata',150,...
                            'markeredgecolor',C(r(j),:),...
                            'linewidth',2);
                    else
                        plot(ha(i),bin(NOTES.CurrentData,NOTES.BinSize),...
                            'color',C(r(j),:),...
                            'linewidth',2);
                    end
                end
                if ~isempty(r)
                    %set Yaxis lim
                    set(ha(i),'YLim',[min(mn(:)) max(mx(:))]);
                    if NOTES.TSvars(i)
                        set(ha(i),'YLim',[0 2]);
                    end
                end
                else
            end
        end
        %set Xaxis lim
        set(ha,'XLim',[1 NOTES.Dimensions{1}(4)/NOTES.BinSize]);
        %reset current field
        NOTES.CurrentField=currentfield;
    end
    function updateroi
        if bigarray
            %for large array, use saved NOTES.ROI global
            if isnan(NOTES.CurrentD3)
                ROI=squeeze(NOTES.ROI(:,:,:,1,NOTES.CurrentD5,NOTES.CurrentD6,NOTES.CurrentD7,NOTES.CurrentD8));
            else
                ROI=squeeze(NOTES.ROI(:,:,NOTES.CurrentD3,NOTES.CurrentD5,NOTES.CurrentD6,NOTES.CurrentD7,NOTES.CurrentD8));
            end
            %update persistent vars
            ROI=bwlabel(ROI);
            nroi=max(ROI(:))+1;
            %update ROI map
            im.CData=ROI;
        else
            %for small array: each pixel = ROI
            nroi=prod(d(1:3))+1;
            ROI=1:prod(d(1:3));
        end
    end
    function roibuttons
        %delete old buttons
        delete(b1);
        %set button width/height
        pos(3)=0.03; %width
        pos(4)=1/nroi; %height
        if nroi>50
            pos(3)=0.02;
            pos(4)=1/50;
        end
        if nroi>150
            pos(3)=0.015;
        end
        if nroi>450
            pos(3)=0.01;
        end
        %make new buttons
        for i=1:nroi
            %set horz/vert position
            shift=ceil(i/50)-1;
            pos(1)=0+(shift*pos(3)); %horz
            pos(2)=1-(pos(4)*(i))+shift; %vert
            b1(i) =  uicontrol(gcf,'Style','togglebutton',...
                'String',num2str(i),...
                'FontSize',10,...
                'Units','normalized',...
                'Position',pos,...
                'ForegroundColor',[0.3 0.3 0.3],...
                'BackgroundColor',[0.9 0.9 0.9],...
                'Callback',@(obj,evt)RefreshData(obj,evt));
        end
        %set string of last button to 'all'
        set(b1(end),'String','All');
        %turn first roi on
        set(b1(1),'value',1);
        %update plot colors
        if nroi<64
            x=64/(nroi-1);
            C=parula;
            C=C(round(1:x:end),:);
        else
            C=varycolor(nroi-1);
        end
    end
end
