function n8plot

%% Variables
global NOTES RESULTS RESULTSa
d=NOTES.Dimensions;

%% Figure window & buttons
%plot window
f1 = figure('name','f1','Units','normalized',...
    'Outerposition',[0 0.04 1 0.94],...
    'Color',[0.2 0.2 0.2],...
    'toolbar','none',...
    'Colormap',cmap1);
ha=tight_subplot(1,1,0,[0.015 0.06],0.01);

%% UI controls
%make movie
b8 = uicontrol(gcf,'Style','pushbutton',...
    'String','Save movie',...
    'FontSize',10,...
    'Units','normalized',...
    'Position',[0.01 0.947 0.04 0.043],...
    'Callback',@saveGIF);
%save frame
b7 = uicontrol(gcf,'Style','pushbutton',...
    'String','Save frames',...
    'FontSize',10,...
    'Units','normalized',...
    'Position',[0.05 0.947 0.04 0.043],...
    'Callback',@saveEPS);
%data type
b1 = uicontrol(gcf,'Style','popup',...
    'String',NOTES.FieldNames(:),...
    'Value',NOTES.CurrentFieldVal,...
    'FontSize',18,...
    'Units','normalized',...
    'Position',[0.113 0.94 0.1 0.05],...
    'Callback',@(obj,evt)RefreshData(obj,evt));
%Normalize
b2b = uicontrol(gcf,'Style','checkbox',...
    'String','Normalize',...
    'FontSize',10,...
    'Units','normalized',...
    'ForegroundColor','w',...
    'BackgroundColor',[0.2 0.2 0.2],...
    'Value',0,...
    'Position',[0.22 0.947 0.05 0.02],...
    'Callback',@(obj,evt)RefreshData(obj,evt));
%invert data
b3=uicontrol(gcf,'Style','checkbox',...
    'String','Invert',...
    'FontSize',10,...
    'Units','normalized',...
    'ForegroundColor','w',...
    'BackgroundColor',[0.2 0.2 0.2],...
    'Value',NOTES.Invert,...
    'Position',[0.22 0.972 0.04 0.02],...
    'Callback',@(obj,evt)RefreshData(obj,evt));
%saturation level
annotation(f1,'textbox',[0.258 0.966 0.03 0.03],...
    'String','Saturation',...
    'Color','w',...
    'BackgroundColor',[0.2 0.2 0.2],...
    'EdgeColor',[0.2 0.2 0.2],...
    'FontSize',10);
b2a = uicontrol(gcf,'Style','popup',...
    'String',num2cell(1:10),...
    'Value',5,...
    'FontSize',9,...
    'Units','normalized',...
    'Position',[0.262 0.945 0.03 0.03],...
    'Callback',@RefreshData);
%select time
b4 = uicontrol(gcf,'Style','edit',...
    'String',num2str(NOTES.CurrentD4/10),...
    'FontSize',26,...
    'FontWeight','bold',...
    'Units','normalized',...
    'Position',[0.41 0.947 0.2 0.043],...
    'Callback',@(obj,evt)RefreshData(obj,evt));
%small time step back
uicontrol(gcf,'Style','pushbutton',...
    'String','<',...
    'FontSize',18,...
    'Units','normalized',...
    'Position',[0.36 0.947 0.05 0.043],...
    'Callback',@BackwardSmallStep);
%big time step back
uicontrol(gcf,'Style','pushbutton',...
    'String','<<',...
    'FontSize',12,...
    'Units','normalized',...
    'Position',[0.34 0.947 0.02 0.043],...
    'Callback',@BackwardBigStep);
%small time step forward
uicontrol(gcf,'Style','pushbutton',...
    'String','>',...
    'FontSize',18,...
    'Units','normalized',...
    'Position',[0.61 0.947 0.05 0.043],...
    'Callback',@ForwardSmallStep);
%big time step forward
uicontrol(gcf,'Style','pushbutton',...
    'String','>>',...
    'FontSize',12,...
    'Units','normalized',...
    'Position',[0.66 0.947 0.02 0.043],...
    'Callback',@ForwardBigStep);
%select conditions
b5=uicontrol(gcf,'Style','popup',...
    'String',num2cell(1:d(5)),...
    'FontSize',18,...
    'Units','normalized',...
    'Value',NOTES.CurrentD5,...
    'Position',[0.728 0.94 0.03 0.05],...
    'Callback',@(obj,evt)RefreshData(obj,evt));
%Select subjects
b6=uicontrol(gcf,'Style','popup',...
    'String',[num2cell(1:d(6)) 'ave'],...
    'FontSize',18,...
    'Units','normalized',...
    'Value',NOTES.CurrentD6,...
    'Position',[0.7575 0.94 0.04 0.05],...
    'Callback',@(obj,evt)RefreshData(obj,evt));
%Align data - manual
uicontrol(gcf,'Style','pushbutton',...
    'String','Align',...
    'FontSize',10,...
    'Units','normalized',...
    'Position',[0.8 0.947 0.03 0.043],...
    'Callback','close all; Salign(0); Splot2;');
%Change Plot Type
uicontrol(gcf,'Style','pushbutton',...
    'String','Lines',...
    'FontSize',10,...
    'Units','normalized',...
    'Position',[0.83 0.947 0.03 0.043],...
    'Callback',@ChangePlotType);

%% Initialize data/plot
for i=1:length(NOTES.FieldNames)
    eval(['R{i}=RESULTSa.' NOTES.FieldNames{i} ';']);
end
SelectData;
%refresh data
data=R{NOTES.CurrentFieldVal};
d(4)=size(data,4);
%invert if selected
if get(b3,'value')==1
    data=-data;
    NOTES.Invert=1;
else
    NOTES.Invert=0;
end
RefreshData([],[]); %plots data from first field name in RESULTS

%% Functions
    function RefreshData(src,evt)
        %refresh current field
        SelectData;
        %refresh data
        data=R{NOTES.CurrentFieldVal};
        d(4)=size(data,4);
        %average L2/3 and L4 to determine alignment for stimulus invariance project%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%         if NOTES.L3L4ave==1
%             temp=nanmean(data(:,:,2:3,:,:,:),3);
%             data(:,:,2,:,:,:)=temp;
%             data(:,:,3,:,:,:)=temp;
%         end
        %crop data
        CropData;
        %normalize data if selected
%         if get(b2b,'Value')==1
%             for d5=1:d(5)
%                 for d6=1:d(6)
%                     temp=data(:,:,:,:,d5,d6);
%                     %find mean BL value 
%                     blw=NOTES.BaseLineWindow;
%                     bl=temp(:,:,:,blw(1):blw(2));
%                     bl=nanmean(bl(:));
%                     %subtract BL value from all times/locations
%                     temp=temp-bl;
%                     %find max and divide
%                     mx=max(temp(:));
%                     temp=temp/mx;
%                     %replace data
%                     data(:,:,:,:,d5,d6)=temp;
%                 end
%             end
%         end
        %if logical data, replace NaNs with 0s
        if min(data(:))==max(data(:))
            data(isnan(data))=0;
        end
        %invert if selected (reset if changing data type)
        if src==b1
            set(b3,'value',0);
        end
        if get(b3,'value')==1
            data=-data;
            NOTES.Invert=1;
        else
            NOTES.Invert=0;
        end
        %find min/max for color map limits (excluding upper/lower 1% of values)
        if firstplot==1 || src==b1 || src==b2a || src==b2b || src==b3 || src==b2b
            ColorLimits;
            firstplot=0;
        end
        %refresh D5 (condition)
        SelectD5;
        %refresh D6 (subject)
        SelectD6;
        %refresh D4 (time)
        SelectD4;
        %plot data
        PlotData;
    end
    function CropData
        try
            data=data(:,NOTES.Crop,:,:,:,:);
        catch
            disp('Crop calculated automatically');
            %remove recording locations with missing subjects
            crop=squeeze(data(1,:,:,1,5,:));
            crop=squeeze(nanmean(crop,2));
            crop=sum(~isnan(crop),2);
            crop=crop>(d(6)*0.7); %DANGEROUS - MAKE SURE MIDDLE LOC ARE NOT REMOVED
            data=data(:,crop,:,:,:,:,:);
        end
    end
    function SelectData
        %get selection
        choice = get(b1,'value');
        %update globals
        NOTES.CurrentField=NOTES.FieldNames{choice};
        NOTES.CurrentFieldVal=choice;
    end
    function ColorLimits
        %sort group ave data
        climdata=nanmean(data,6);
        climdata=data(~isnan(data));
        climdata=sort(climdata,'ascend');
        %get saturation level (1-5)
        s=6-(get(b2a,'value'))/2;
        clow=10^-s; %%%%%%%%%%include + and - values
        chigh=1-10^-s;
        %set color lims
        clim=[climdata(round(end*clow)) climdata(round(end*chigh))]; %%%%%%%%%%include + and - values
        %set arbitrary values if clim is not increasing values
        if clim(1)>clim(2) || clim(1)==clim(2)
            clim = [min(climdata(:)) max(climdata(:))];
            warndlg('MIN/MAX used instead of saturation level. Decrease saturation level or check data.');
        end
    end
    function SelectD4
        D4=round(str2double(get(b4,'string'))*10);
        if isempty(D4)
            D4=1;
        elseif D4>d(4)
            D4=d(4);
        end
        data=data(:,:,:,D4,:,:);
        NOTES.CurrentD4=D4;
    end
    function SelectD5 %condition
        if isempty(D6)
            D5=1;
        else
            D5=get(b5,'Value');
        end
        data=data(:,:,:,:,D5,:);
        NOTES.CurrentD5=D5;
    end
    function SelectD6 %subject
        if isempty(D6)
            D6=d(6)+1;
        else
            D6=get(b6,'Value');
        end
        if D6<=d(6)
            data=data(:,:,:,:,:,D6);
        elseif D6==d(6)+1
            %mean
            data=nanmean(data,6);
        end
        NOTES.CurrentD6=D6;
    end
    function PlotData
        set(f1,'currentaxes',ha);
        p = imagesc(squeeze(data)');
        caxis(clim);
        colormap(cmap2(clim));
        c=colorbar('Location','South','Color','w','Position',[0.89 0.95 0.08 0.025]);
        if min(clim)<0 && max(clim)>0
            set(c,'XTick',[clim(1) 0 clim(2)],'XTickLabel',[clim(1) 0 clim(2)]);
        else
            set(c,'XTick',clim,'XTickLabel',clim);
        end
        axis off;
    end
    function BackwardSmallStep(source,~)
        if D4>1
            D4=D4-1;
        else
            D4=1;
        end
        set(b4,'string',num2str(D4/10));
        RefreshData(source);
    end
    function BackwardBigStep(source,~)
        if D4>10
            D4=D4-10;
        else
            D4=1;
        end
        set(b4,'string',num2str(D4/10));
        RefreshData(source);
    end
    function ForwardSmallStep(source,~)
        if D4<d(4)-1
            D4=D4+1;
        else
            D4=d(4);
        end
        set(b4,'string',num2str(D4/10));
        RefreshData(source);
    end
    function ForwardBigStep(source,~)
        if D4<d(4)-10
            D4=D4+10;
        else
            D4=d(4);
        end
        set(b4,'string',num2str(D4/10));
        RefreshData(source);
    end
    function saveEPS(src,evt)
        set(gcf,'renderer','painters');
        set(b7,'SelectionHighlight','off');
        note = ['S' num2str(D6) '_' NOTES.CurrentField '_' num2str(D4) 'ms(x10)'];
        saveas(gcf,note,'epsc2');
    end
    function setMovie(~,~)
        set(gcf,'renderer','painters');
        %ask for time dimensions & interval
        figure('Name','temp','Units','normalized','OuterPosition',[0.4 0.4 0.2 0.4],'toolbar','none');
        g(1)=uicontrol(gcf,'Style','edit',...
            'String','start time (ms)',...
            'FontSize',20,...
            'Units','normalized',...
            'Position',[0 0.75 1 0.25]);
        g(2)=uicontrol(gcf,'Style','edit',...
            'String','end time (ms)',...
            'FontSize',20,...
            'Units','normalized',...
            'Position',[0 0.5 1 0.25]);
        g(3)=uicontrol(gcf,'Style','edit',...
            'String','interval (ms)',...
            'FontSize',20,...
            'Units','normalized',...
            'Position',[0 0.25 1 0.25]);
        g(4)=uicontrol(gcf,'Style','pushbutton',...
            'String','GIF',...
            'FontSize',22,...
            'FontWeight','bold',...
            'Units','normalized',...
            'SelectionHighlight','off',...
            'Position',[0 0 0.5 0.25],...
            'Callback',@MakeMovie);
        g(5)=uicontrol(gcf,'Style','pushbutton',...
            'String','Frames',...
            'FontSize',22,...
            'FontWeight','bold',...
            'Units','normalized',...
            'SelectionHighlight','off',...
            'Position',[0.5 0 0.5 0.25],...
            'Callback',@MakeMovie);
    end
    function MakeMovie(src,evt)
        %close GIF dialogue window and set current figure
        figure(f1);        
        set(b8,'SelectionHighlight','off');
        %create filename
        %get data parameters & close temp window
        starttime = round(str2double(get(g(1),'string'))*10);
        endtime = round(str2double(get(g(2),'string'))*10);
        interval = round(str2double(get(g(3),'string'))*10);
        close('temp');
        %save string
        note = ['S' num2str(D6) '_' NOTES.CurrentField '_' num2str(starttime) '_'  num2str(interval) '_' num2str(endtime) '_ms_x10'];
        if get(b2b,'Value')==1
            note =[note '_norm'];
        end
%         %write GIF
%         if src==g(4)
%             framedelay=20/length(starttime:interval:endtime); %%%%%%%%%%% total animation time = 15 sec
%             if framedelay<0.05
%                 framedelay=0.05;
%             end
%             x=0;
%             for D4=starttime:interval:endtime
%                 %replot data
%                 set(b4,'string',num2str(D4/10));
%                 RefreshData(0);
%                 %set time string to round number for movie
%                 set(b4,'string',num2str(round(D4/10)));
%                 %save GIF
%                 frame = getframe(1);
%                 im = frame2im(frame);
%                 [imind,cm] = rgb2ind(im,256);
%                 x=x+1;
%                 if x == 1;
%                     imwrite(imind,cm,[note '.gif'],'gif','Loopcount',inf);
%                 else
%                     imwrite(imind,cm,[note '.gif'],'gif','WriteMode','append','DelayTime',framedelay);
%                 end
%             end
%         end
        %Movie Frames
        if src==g(5)      
            %Get data
            %refresh current field
            SelectData;
            %refresh data
            data=R{NOTES.CurrentFieldVal};
            d(4)=size(data,4);
            %invert if selected
            if get(b3,'value')==1
                data=-data;
                NOTES.Invert=1;
            else
                NOTES.Invert=0;
            end
            %SUBTRACT BL FOR EACH ELECTRODE
            data=N8subtractbaseline(data);
            w=NOTES.BaseLineWindow;
            %replace non-missing NaNs with 0s
            data(isnan(data))=0;
            data(NOTES.MissingData)=NaN;
            %find bl mean
            bl=nanmean(data(:,:,:,w(1):w(2),:,:),4);
            %duplicate array
            bl=repmat(bl,[1 1 1 d(4) 1 1]); 
            %subtract values
            data=data-bl;
            %crop data
            CropData;
            %select D4
            data=data(:,:,:,starttime:interval:endtime,:,:);
            %normalize if selected
            d=size(data);
            if get(b2b,'value')==1
                for d5=1:d(5)
                    for d6=1:d(6)
                        %get data
                        temp=data(:,:,:,:,d5,d6);
                        %divide by max %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                        temp=temp/max(temp(:));
                        %save in tdata_norm
                        data(1:d(1),1:d(2),1:d(3),1:d(4),d5,d6)=temp;
                    end
                end
            end
            %calculate sem to include in plot title
            sem=nanstd(data,6)/sqrt(6);
            semC2=nanstd(data(:,:,:,:,1:4,:),6)/sqrt(6);
            semWA=nanstd(data(:,:,:,:,5:8,:),6)/sqrt(7);
            semC2=[mean(semC2(:)) max(semC2(:))]
            semWA=[mean(semWA(:)) max(semWA(:))]
            sem=[median(sem(:)) max(sem(:))];
            %select subjects/mean
            SelectD6;
            %set color limits to min/max for plotted images
            cdata=data(:);
            while sum(cdata==min(cdata))>1
                cdata(cdata==min(cdata))=mean(cdata);
            end
            cdata(cdata==0)=mean(cdata);
            %clim2=[min(cdata) max(cdata)];
            clim2=[-max(abs(cdata)) max(abs(cdata))]; %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %clim2=[-1 1];
            %setup figure/title/axes
            figure('Units','normalized',...
                'Outerposition',[0 0.04 1 0.94],...
                'Color',[0.1 0.1 0.1],...
                'toolbar','none',...
                'Colormap',cmap1); %cmap2(clim2));
            %save frame
            uicontrol(gcf,'Style','pushbutton',...
                'String','save',...
                'FontSize',9,...
                'Units','normalized',...
                'Position',[0.82 0.935 0.03 0.035],...
                'Callback',@saveEPS2);
            l=length(starttime:interval:endtime);
            ha2=tight_subplot(d(5),l,0.0005,[0.015 0.06],0.01);
            %set title
            title_string=[NOTES.CurrentField '   ' num2str(starttime/10) ':'  num2str(interval/10) ':' num2str(endtime/10) 'ms  (median, max sem = ' num2str(sem(1)) ',' num2str(sem(2)) ')'];        
            annotation('textbox',[0.01 0.935 0.8 0.04],...
                'String',title_string,...
                'BackgroundColor',[0.1 0.1 0.1],...
                'FontSize',16,...
                'Color','w',...
                'FontWeight','bold',...
                'linestyle','none');
            %Plot data
            x=0;
            for D4=1:size(data,4)
                x=x+1;
                data_temp = data(:,:,:,D4,:,:);
                %plot each condition
                for i=1:d(5)
                    set(gcf,'currentaxes',ha2(x+l*(i-1)));
                    imagesc(squeeze(data_temp(:,:,:,:,i))');
                    caxis(clim2);
                    %caxis([-max(abs(clim)) max(abs(clim))]);%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    axis off;
                    axis image;
                end
                if D4==size(data,4)
                    %color bar
                    c=colorbar('Location','South','Position',[0.89 0.94 0.08 0.025]);
                    set(c,'XTick',clim2,'XTickLabel',clim2);
                end
                
            end
        end
    end
    function clearframes(src,evt)
    end
    function ChangePlotType(src,~)
        close all;
        Splot2b;
    end
    function saveEPS2(src,evt)
        saveas(gcf,note,'epsc2');
    end
end
