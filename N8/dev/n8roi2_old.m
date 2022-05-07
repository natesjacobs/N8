function [roi,stats]  = n8roi2(data,thresh,RemoveSmallBlobs)
%Gets ROI for larger images (with help from user)

%% Variables
%threshold
if nargin<2
    thresh = nanmedian(data(:))+nanstd(data(:)); 
end
%parameters for removing small "blobs" less than 1% of image area
if nargin<3
    RemoveSmallBlobs = round(prod(size(data))*0.01); 
end
data = squeeze(data);
d=size(data);

%% Start figures
figure('Units','normalized',...
    'Outerposition',[0 0.04 0.95 0.96],...
    'Color',[0.1 0.1 0.1],...
    'ToolBar','none');

%% Threshold data & remove minor blobs
%threshold data
tdata = data > thresh;
tdata = bwareaopen(tdata,RemoveSmallBlobs); %remove blobs smaller than "RemoveSmallBlobs" pixels
replot;

%% Ask for help removing larger blobs
tdata = bwlabel(tdata);
nobjects = double(max(tdata(:)));
blobs{1}='keep all';
%plot blob labels and ask for help
if nobjects>0
    cla;
    imagesc(tdata);
    axadjust('thresholded');
    for n=1:nobjects
        loc=regionprops(tdata==n,'Centroid');
        [locx locy] = ds2nfu(gca,loc.Centroid(1),loc.Centroid(2));
        x = [locx+0.01 locx];
        y = [1-locy+0.05 1-locy];
        if x(1)>1
            x(1)=.99;
        end
        if y(1)>1
            y(1)=0.95;
        end
        blobs{end+1}=num2str(n);
        a(n)=annotation('textarrow',x,y,'String', blobs{n+1},'FontSize',22,'Color','k');
        b(n)=annotation('textarrow',x-0.001,y,'String', blobs{n+1},'FontSize',22,'Color','w');
    end
    %choose blobs to remove
    choice = listdlg('PromptString','Select area(s) to be REMOVED','ListString',blobs);%should be +1 to not include background, but adding 'none' option does this
    %remove blob tags
    for n=1:length(a)
        try
            delete(a(n),b(n));
        catch
        end
    end
    if isempty(choice)
        close all;
        error('n8roi2 terminated by user');
    elseif max(choice)>1
        if min(choice)==1
            choice=choice(2:end);
        end
        for i=1:length(choice)
            tdata(tdata==choice(i)-1)=0;
        end
    end
    tdata = tdata>0;
end

% %% Ask for help removing overlapping artifacts (contours2 - remove)
% nobjects = double(max(tdata(:)));
% %parameters used to dilate areas
% se1 = strel('disk',2);
% se2 = strel('disk',7);
% %plot and ask for help
% if nobjects>0
%     %contour plot
%     cdata = data;
%     cdata(~tdata) = NaN;
%     m = nanmax(cdata(:));
%     cla;
%     c = contourf(flipud(cdata),thresh:(m-thresh)/10:m);
%     axadjust('contours');
%     [index,value,coord] = clabel2(c); %separates contourline info into vars
%     %remove small blobs
%     %label contour lines
%     blobs = {'keep all'};
%     for n=1:length(index)
%         %skip if nan or small blobs
%         if any(isnan(coord{n}(:))) || length(coord{n})<15
%             continue;
%         end
%         %switch where label is placed to avoid overlap
%         if mod(n,2)==1
%             [locx locy] = ds2nfu(gca,coord{n}(2,1),coord{n}(2,2));
%         else
%             [locx locy] = ds2nfu(gca,coord{n}(ceil(end/2),1),coord{n}(ceil(end/2),2));
%         end
%         blobs{end+1}=num2str(n);
%         if locx>0.98, locx=0.98; end
%         if locy>0.95, locy=0.95; end
%         x = [locx+0.005 locx];
%         y = [locy+0.03 locy];
%         a(n)=annotation('textarrow',x,y,'String', blobs{end},'FontSize',16,'Color','k');
%         b(n)=annotation('textarrow',x+0.001,y,'String', blobs{end},'FontSize',16,'Color','w');
%     end
%     %choose contour line(s) to remove
%     [ui,ok] = listdlg('PromptString','Area(s) to REMOVE','ListString',blobs);
%     %remove blob tags
%     for n=1:length(a)
%         try
%             delete(a(n),b(n));
%         catch
%         end
%     end
%     choice=blobs{ui};
%     %set values inside of contour to 0
%     if isempty(ui)
%         close all;
%         error('n8roi2 terminated by user');
%     elseif max(ui)>1
%         if min(ui)==1
%             ui=ui(2:end);
%         end
%         for i=1:length(ui)
%             choice=str2num(blobs{ui(i)});
%             coord{choice}=coord{choice}(~isnan(coord{choice}(:,1)),:); %remove NaNs
%             trash = poly2mask(coord{choice}(:,1),d(2)-coord{choice}(:,2),d(1),d(2));
%             trash = imdilate(trash,se1); %expand selection
%             tdata(trash)=0;
%         end
%     end
% end

%% Ask for help removing overlapping artifacts (watershed2 - distance transform)
nobjects = double(max(tdata(:)));
if nobjects>0
    %watershed distance transform
    tdata4=zeros(d(1)+2,d(2)+2);
    tdata4(2:end-1,2:end-1)=tdata;
    ddata = -bwdist(~tdata4); %distance transform
    ddata = ddata(2:end-1,2:end-1);
    ddata = n8ssmooth(ddata); %smooth distance transform
    ddata(~tdata) = -Inf; %set dist of values outside blob to infinity.
    wsdata = watershed(ddata);
    nobjects2 = double(max(max(wsdata)))-1;
    %replot
    replot;
    imagesc(wsdata);
    axadjust('watershed distance transform');
    blobs = {'keep all'};
    for n=1:nobjects2;
        loc=regionprops(wsdata==n+1,'Centroid');
        [locx locy] = ds2nfu(gca,loc.Centroid(1),loc.Centroid(2));
        x = [locx+0.01 locx];
        y = [1-locy+0.05 1-locy];
        if x(1)>1
            x(1)=.99;
        end
        if y(1)>1
            y(1)=0.95;
        end
        blobs{end+1}=num2str(n);
        a(n)=annotation('textarrow',x,y,'String', blobs{n+1},'FontSize',22,'Color','k');
        b(n)=annotation('textarrow',x-0.001,y,'String', blobs{n+1},'FontSize',22,'Color','w');
    end
    %choose blobs to remove
    [choice ok] = listdlg('PromptString','Area(s) to be REMOVED','ListString',blobs);%should be +1 to not include background, but adding 'none' option does this
    %remove blob tags
    for n=1:length(a)
        try
            delete(a(n),b(n));
        catch
        end
    end
    if isempty(choice)
        close all;
        error('n8roi2 terminated by user');
    elseif max(choice)>1
        if min(choice)==1
            choice=choice(2:end);
        end
        for i=1:length(choice)
            trash = imdilate(wsdata==choice(i),se1);
            tdata(trash)=0;
        end
    end
end

%% Blob statistics
%draw final data image
replot;
axadjust('final');
%stats
roi = tdata;
tdata_obj = bwlabel(tdata);
nobjects = double(max(max(tdata_obj)));
if nobjects>0
        %peak value
        stats.peak = max(max(data(tdata)));
        [stats.peakloc(1) stats.peakloc(2)] = find(data==stats.peak);
        %area and centroid
        blobprops = regionprops(tdata,'Area','Centroid');
        for i =1:length(blobprops)
            area(i) = blobprops(i).Area;
        end
        stats.area = sum(area);
else
    stats.peak=NaN; 
    stats.peakloc=[NaN NaN]; 
    stats.area=NaN;
end

%% Functions
    function axadjust(string)
        if nargin<1
            string='current';
        end
        title(string,'Color','w','FontSize',16);
        %adjust axes
        set(gca,'XTick',[],'YTick',[],...
            'Color','w',...
            'YColor','w',...
            'XColor','w');
    end
    function replot
        clf;
        %axes
        ha = tight_subplot(1,2,0.01,[0.01 0.05],0.01);
        %plot original (as contours)
        axes(ha(1)); %axis 1
        m = max(data(:));
        contourf(flipud(data),0:m/20:m);
        %adjust axis 1
        title('original','Color','w','FontSize',16);
        set(ha(1),'XTick',[],'YTick',[],...
            'Color','w',...
            'YColor','w',...
            'XColor','w');
        %plot current ROI
        axes(ha(2));
        imagesc(tdata);   
    end
end
