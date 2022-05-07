function n8roi2(data)
%Finds multiple rois in single image (ie, cells) and saves in
%NOTES.CurrentROI
%ROI uses same format as bwlabel (0=backgound, 1=object1, etc.)

%% Initialize variables and figure
global NOTES
data=double(data);
%vars
thr=nanmean(data(:))+1.5*nanstd(data(:));
sz1=10;
sz2=80;
mn=min(data(:));
mx=max(data(:));
roi=data>thr;
v1=[]; v2=thr; v3=sz1; v4=sz2;
%figure window
f1=figure('Units','normalized',...
    'Outerposition',[0 0.04 1 0.94],...
    'Color',[0.1 0.1 0.1],...
    'ToolBar','none');
%axes
ha = tight_subplot(1,1,0,0);

%% GUIs
%Add/remove ROI
b1 = uicontrol(gcf,'Style','togglebutton',...
    'String','Add ROI',...
    'FontSize',11,...
    'Units','normalized',...
    'Position',[0.01 0.9 0.05 0.05],...
    'BackgroundColor',[0.82 0.82 0.82],...
    'Callback',@(obj,evt)addroi(obj,evt));
%Theshold
b2 = uicontrol(gcf,'Style','edit',...
        'String',thr,...
        'FontSize',14,...
        'Units','normalized',...
        'Value',1,...
        'Position',[0.01 0.8 0.05 0.05],...
        'BackgroundColor',[0.82 0.82 0.82],...
        'Callback',@(obj,evt)updateroi(obj,evt));
%Min ROI size
b3 = uicontrol(gcf,'Style','edit',...
        'String',sz1,...
        'FontSize',14,...
        'Units','normalized',...
        'Value',1,...
        'Position',[0.01 0.8 0.05 0.05],...
        'BackgroundColor',[0.82 0.82 0.82],...
        'Callback',@(obj,evt)updateroi(obj,evt));
%Max ROI size
b4 = uicontrol(gcf,'Style','edit',...
        'String',sz2,...
        'FontSize',14,...
        'Units','normalized',...
        'Value',1,...
        'Position',[0.01 0.75 0.05 0.05],...
        'BackgroundColor',[0.82 0.82 0.82],...
        'Callback',@(obj,evt)updateroi(obj,evt));
    
%% Initialize ROI & Plot data
updateroi; %plot function nested inside
    
%% Functions
    function checkvals
        %get gui values
        v2=str2double(get(b2,'string'));
        v3=str2double(get(b3,'string'));
        v4=str2double(get(b4,'string'));
    end
    function plotdata
        %check button values
        checkvals;
        %plot data
        contourf(flipud(data'),mn:(mx-mn)/20:mx);
        hold on;
        %plot rois
        image=data;
        image(roi)=2*mx;
        image(~roi)=NaN;
        contourf(flipud(image'),2*mx);
        %adjust axes
        axis image off;
    end
    function addroi(src,evt)
        %get cursor position/button press
        [x,y] = ginput(1);
        %get image objects
        %...
        %in or out of roi?
        if x>0 && y>0
            inout=roi(round(x),round(y));
        else
            inout=[];
        end
        %add/remove roi
        if inout
            %add roi
            %...
        elseif ~isempty(inout)
            %remove roi
            %...
        end
        %reset toggle button
        set(b1,'value',0);
        %replot
        plotdata;
        %save roi in NOTES
        NOTES.CurrentROI=roi;
    end
    function updateroi(src,evt)
        %check gui values
        checkvals;
        %reset roi
        roi=data>v2;
        %remove small blobs
        roi = bwareaopen(roi,v3);
        %remove large blobs
        roi = bwareaopen2(roi,v4);
        %remove eccentric blobs
        roi = bwareaopen3(roi,0.9);
        %replot data
        plotdata;
        %save roi in NOTES
        NOTES.CurrentROI=roi;
    end
end