function n8plot
% NOTES
%How time is handled
%time is in sec for all figure GUIs
%values stored in NOTES (CurrentTime & Dimensions) are in elements
    %or bins if NOTES.BinSize>1

%% Variables
global NOTES DATA
%dimensions
d=ones(1,8);
d(1:length(NOTES.Dimensions))=NOTES.Dimensions;
%Set current time if var doesn't exist
if ~isfield(NOTES,'CurrentTime')
    NOTES.CurrentTime=1;
end
D4=NOTES.CurrentTime; %in bins
B=NOTES.BinSize;
SR=NOTES.SampleRate;
nframes=NOTES.FrameCount;
label=[];
%Initialize variables that span multiple functions
data=[];
data_ts=[];
clim=[];
data_plot=[];
%check for NaNs
if isnan(NOTES.BinSize)
    NOTES.BinSize=1;
end
%check for bad color threshold
if any(NOTES.Threshold==0)
    NOTES.Threshold(NOTES.Threshold==0)=NaN;
end    
%close open windows
close all;

%% Figure window & axes
%plot window
f1 = figure('name','f1','Units','normalized',...
    'Outerposition',[0 0.04 1 0.94],...
    'Color',[0.2 0.2 0.2],...
    'toolbar','none');
%axes
if d(5)>1
    ha=tight_subplot(d(5),nframes,[0.01 0.001],[0.05 0.13],0.01);
else
    nrows=ceil(nframes/3);
    ha=tight_subplot(nrows,nframes,[0.01 0.001],[0.05 0.13],0.01);
    nframes=nframes*nrows;
    set(ha,'visible','off');
end

%% UI data type
%file name / save data
uicontrol(gcf,'Style','text',...
    'String',NOTES.SaveString,...
    'FontSize',12,...
    'FontWeight','bold',...
    'Units','normalized',...
    'Position',[0.2 0 0.6 0.04],...
    'BackgroundColor',[0.2 0.2 0.2],...
    'ForegroundColor',[0.4 0.4 0.4]);
%continuous data
b1 = uicontrol(gcf,'Style','popup',...
    'String',NOTES.FieldNames,...
    'Value',NOTES.CurrentFieldVal,...
    'FontSize',16,...
    'Units','normalized',...
    'Position',[0.01 0.94 0.09 0.05],...
    'BackgroundColor',[0.82 0.82 0.82],...
    'Callback',@(obj,evt)RefreshData(obj,evt));
%normalize to baseline
b4 = uicontrol(gcf,'Style','popup',...
    'String',{' ' '-BL' '%BL'},...
    'Value',NOTES.BaselineNorm,...
    'FontSize',16,...
    'Units','normalized',...
    'Position',[0.105 0.94 0.05 0.05],...
    'BackgroundColor',[0.82 0.82 0.82],...
    'Callback',@(obj,evt)RefreshData(obj,evt));
%timestamp data
b2string=NOTES.FieldNames_t;
b2string{end+1}='none';
b2 = uicontrol(gcf,'Style','popup',...
    'String',b2string,...
    'Value',1,...
    'FontSize',10,...
    'Units','normalized',...
    'Position',[0.01 0.91 0.09 0.03],...
    'BackgroundColor',[0.82 0.82 0.82],...
    'Callback',@(obj,evt)RefreshData(obj,evt));
if ~isnan(NOTES.CurrentFieldVal_t)
    set(b2,'value',NOTES.CurrentFieldVal_t);
end

%% UI time controls
%current start time (input box)
b5 = uicontrol(gcf,'Style','edit',...
    'String',num2str(round(D4*1e4/SR)/1e4),...
    'FontSize',16,...
    'FontWeight','bold',...
    'Units','normalized',...
    'Position',[0.38 0.94 0.05 0.05],...
    'BackgroundColor',[0.82 0.82 0.82],...
    'Callback',@(obj,evt)RefreshData(obj,evt));
%current start time (scroll button)
b6= uicontrol(gcf,'Style','slider',...
    'Min',1,...
    'Max',nframes,...
    'SliderStep',[0.1 0.5],...
    'Value',1,...
    'Units','normalized',...
    'Position',[0.431 0.94 0.15 0.05],...
    'BackgroundColor',[0.82 0.82 0.82],...
    'Callback',@(obj,evt)RefreshData(obj,evt));
%current bin size
b7 = uicontrol(gcf,'Style','edit',...
    'String',round(B*1e4/SR)/1e4,...
    'FontSize',16,...
    'FontWeight','bold',...
    'Units','normalized',...
    'Position',[0.582 0.94 0.05 0.05],...
    'BackgroundColor',[0.82 0.82 0.82],...
    'Callback',@(obj,evt)RefreshData(obj,evt));

%% UI constrain dimensions
%Dim 3: depth
for i=1:d(3)
    s{i}=['Depth ' num2str(i)];
end
b10=uicontrol(gcf,'Style','popup',...
        'String',s,...
        'FontSize',12,...
        'Units','normalized',...
        'Value',1,...
        'Position',[0.699 0.927 0.05 0.05],...
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
    b8(i)=uicontrol(gcf,'Style','popup',...
        'String',s,...
        'FontSize',12,...
        'Units','normalized',...
        'Value',val,...
        'Position',[0.75+(0.051*(i-1)) 0.927 0.05 0.05],...
        'BackgroundColor',[0.82 0.82 0.82],...
        'Callback',@(obj,evt)RefreshData(obj,evt));
end

%% UI miscellaneous
%movie
uicontrol(gcf,'Style','pushbutton',...
    'String','.MOV',...
    'FontSize',10,...
    'Units','normalized',...
    'Position',[0.928 0.94 0.03 0.05],...
    'BackgroundColor',[0.82 0.82 0.82],...
    'Callback',@(obj,evt)savemovie(obj,evt));
%show line plots
uicontrol(gcf,'Style','pushbutton',...
    'String','~',...
    'FontSize',14,...
    'Units','normalized',...
    'Position',[0.96 0.94 0.03 0.05],...
    'BackgroundColor',[0.82 0.82 0.82],...
    'Callback','close; n8plot2;');
%threshold
b9=uicontrol(gcf,'Style','edit',...
    'String',num2str(NOTES.Threshold(NOTES.CurrentFieldVal)),...
    'FontSize',10,...
    'FontWeight','bold',...
    'Units','normalized',...
    'Position',[0.878 0.889 0.04 0.031],...
    'BackgroundColor',[0.82 0.82 0.82],...
    'Callback',@(obj,evt)RefreshData(obj,evt));


%% UI hide buttons that are not applicable
%Time
if d(4)<=nframes+1
    set(b5,'visible','off'); 
    set(b6,'visible','off'); 
    NOTES.CurrentTime=1;
end
%timestamp data
if isempty(NOTES.FieldNames_t), set(b2,'visible','off'); end
%Depth
if isnan(NOTES.CurrentDepth) || d(3)==1
    set(b10,'visible','off'); 
else
    set(b10,'value',NOTES.CurrentDepth);
end
%Subjects
if d(6)==1, set(b8(1),'visible','off'); end
%Trials
if d(7)==1, set(b8(2),'visible','off'); end
%Other/n-trode
if d(8)==1, set(b8(3),'visible','off'); end

%% Initialize data
%plot data
RefreshData([],[]); %plots data from first field name in RESULTS

%% Functions
    function RefreshData(src,evt)
        %set timestamp data field
        if ~isempty(src) && src==b2
            NOTES.CurrentFieldVal_t=get(b2,'value');
            if NOTES.CurrentFieldVal_t>length(NOTES.FieldNames_t)
                NOTES.CurrentFieldVal_t=NaN;
                NOTES.CurrentField_t=NaN;
            else
                NOTES.CurrentField_t=NOTES.FieldNames_t{NOTES.CurrentFieldVal_t};
            end
        end
        
        %GET NEW DATA
        if isempty(data)
            data=n8getdata;
        end
        %data type
        if ~isempty(src) && src==b1 
            %update global
            NOTES.CurrentFieldVal=get(b1,'value');                
            NOTES.CurrentField=NOTES.FieldNames{NOTES.CurrentFieldVal};
            %get new data
            data=n8getdata;
        end
        %normalize to baseline yes/no
        if ~isempty(src) && src==b4
            NOTES.BaselineNorm=get(b4,'value');
            if isempty(NOTES.Baseline)
                n8bl;
            end
            %get new data
            data=n8getdata;
        end
        %bin size 
        if ~isempty(src) && src==b7
            %save current time in elements before binning
            NOTES.CurrentTime=NOTES.CurrentTime*NOTES.BinSize;
            %get new bin size
            bin=str2double(get(b7,'string')); %get bin size in sec
            bin=round(bin*SR); %convert to elements
            %check bin size input
            if bin<1
                bin=1; %bin=1 means no binning
            end
            %save new bin size in global
            NOTES.BinSize=bin;
            %get new data
            data=n8getdata;
            %convert current time back to bins
            NOTES.CurrentTime=ceil(NOTES.CurrentTime/NOTES.BinSize);
        end
        %subject and other dimensions
        %depth
        if ~isempty(src) && src==b10
            %save globals
            NOTES.CurrentDepth=get(b10,'value');
            %get new data
            data=n8getdata;
        end
        %subject
        if ~isempty(src) && src==b8(1)
            %save globals
            NOTES.CurrentD6=get(b8(1),'value');
            %get new data
            data=n8getdata;
        end
        
        %UPDATE GLOBALS
        %start time
        if NOTES.Dimensions(4)>nframes+1
            %change current time if user input
            if ~isempty(src) && (src==b5 || src==b6)
                if src==b5
                    d4=str2double(get(b5,'string')); %get current time from input box
                    %add trigger
                    if ~isempty(NOTES.Triggers)
                        d4=d4+NOTES.Triggers(1); %add trigger time
                    end
                    d4=d4*SR; %convert to elements
                    d4=ceil(d4/NOTES.BinSize); %convert to bins
                    if d4==0
                        d4=1;
                    end
                    NOTES.CurrentTime=d4; %save in global
                elseif src==b6
                    d4=round(get(b6,'value')); %get current time from scroll
                    NOTES.CurrentTime=d4; %save in global
                end
            end
            %check current time
            d4=NOTES.CurrentTime;
            if d4>NOTES.Dimensions(4)-nframes
                NOTES.CurrentTime=NOTES.Dimensions(4)-nframes;
            end
            %update start time input box
            set(b5,'visible','on');
            d4=NOTES.CurrentTime*NOTES.BinSize; %convert to elements
            d4=d4/SR; %convert to sec
            %subtract trigger
            if ~isempty(NOTES.Triggers)
                d4=d4-(NOTES.Triggers(1));
            end
            set(b5,'string',num2str(round(d4*1e3)/1e3));
            %update time scroll bar
            set(b6,'visible','on');
            d4=NOTES.Dimensions(4);
            a=1/(d4-nframes-1); %step size
            b=nframes/d4; %scroll bar size
            c=d4-nframes; %max value
            %make sure b>a
            if b<a
                b=a;
            end
            set(b6,'SliderStep',[a b],'Max',c,'value',NOTES.CurrentTime);
        else
            set(b5,'visible','off');
            set(b6,'visible','off');
            NOTES.CurrentTime=1;
        end
        %threshold
        if ~isempty(src) && src==b9
            thresh=str2num(get(b9,'string'));
            NOTES.Threshold(NOTES.CurrentFieldVal)=thresh;
        end
        
        %GET PLOT DATA
        data_plot=data;
        %trial (D7)
        NOTES.CurrentD7=get(b8(2),'value');
        if NOTES.CurrentD7>NOTES.Dimensions(7)
            data_plot=nanmean(data_plot,7);
        else
            data_plot=data_plot(:,:,:,:,:,:,NOTES.CurrentD7,:);
        end
        %other/n-trode (D8)
        NOTES.CurrentD8=get(b8(3),'value');
        if NOTES.CurrentD8>NOTES.Dimensions(8)
            data_plot=nanmean(data_plot,8);
        else
            data_plot=data_plot(:,:,:,:,:,:,:,NOTES.CurrentD8);
        end
        %time (D4)
        if NOTES.Dimensions(4)>nframes+1
            %get start time
            D4=NOTES.CurrentTime;
            %get time series
            data_plot=data_plot(:,:,:,D4:D4+nframes-1,:,:,:,:);
        end
        
        %Color axis
        clim=abs(NOTES.Threshold(NOTES.CurrentFieldVal));
        if isnan(clim)
            clim=n8getclim(data_plot);
            clim=clim(2);
        end
        if NOTES.Cmap==1
            clim=[0 clim];
            set(f1,'Colormap',jet);
        elseif NOTES.Cmap==2
            clim=[-clim clim];
            if clim(1)==0 || isnan(mean(clim(:)))
                clim=[-1 1];
                set(b9,'string','1 (error)')
            end
            set(gcf,'Colormap',cmap2);
        end
        if get(b4,'value')==3
            clim=[0 2];
            NOTES.Cmap=2;
            set(gcf,'Colormap',cmap2);
            set(b9,'visible','off');
        else
            set(b9,'visible','on');
        end
        set(b9,'string',num2str(clim(2)));
        
        %get timestamp data%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %unlike continuous data, get all timestamp data each time
        if ~isempty(NOTES.FieldNames_t)
            d=NOTES.Dimensions; %dimensions
            %only include for non-averaged continuous data that is not derived from timestamps
            if NOTES.CurrentD6<=d(6) && NOTES.CurrentD7<=d(7) && NOTES.CurrentD8<=d(8) && isempty(strfind(NOTES.CurrentField,'_t'))
                set(b2,'visible','on');
                if ~isnan(NOTES.CurrentField_t)
                    data_ts=n8getdata_t;
                else
                    data_ts=[];
                end
            else
                data_ts=[];
                set(b2,'visible','off');
            end
        end 
        
        %plot data%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        PlotData;
    end
    function PlotData
        %Plot data
        %identify singleton spatial dimension
        d=NOTES.Dimensions;
        xy=(d(1:3)~=1);
        %reset frame counter
        x=0;
        %cycle through conditions
        for d5=1:size(data_plot,5)
            %cycle through time series
            for d4=1:nframes
                %plot data for each time point
                x=x+1; %advance axis counter
                %set axes
                set(gcf,'currentaxes',ha(x));
                cla(gca);
                axis off;
                title('');
                %get image (skip if no more frames)
                try
                    im=data_plot(:,:,:,d4,d5,:,:,:);
                catch
                    continue;
                end
                im=squeeze(im);     
                %if not all NaNs, plot
                if ~isnan(nanmean(im(:)))
                    imagesc(im);
                end
                %set axis properties
                caxis(clim);
                axis off;
                axis image;
                %plot timestamps
                hold on;
                if isfield(NOTES,'FieldNames_t') && ~isempty(data_ts)
                    temp=data_ts;
                    a=NOTES.CurrentTime;
                    %timestamps at current time
                    ix = temp(:,4) == d4+a-1;
                    temp=temp(ix,:);
                    %timestamps at current condition
                    if ~isempty(temp)
                        ix = temp(:,5) == d5;
                        temp=temp(ix,:);
                        %plot timestamps as scatter
                        if ~isempty(temp)
                            %remove all non-spatial dimensions (Dims 4-8)
                            temp=temp(:,1:3);
                            %remove singleton spatial dimension
                            temp=temp(:,xy);
                            %check size of timestamp list
                            imsiz=d(1:3);
                            imsiz=imsiz(xy);
                            imsiz=prod(imsiz);
                            %if too many timestamps, reduce to one per
                            %location
                            if length(temp)>imsiz*10
                                %find unique timestamps
                                ix=diff(temp);
                                ix=sum(abs(ix),2)>0;
                                ix([false;ix])=true;
                                %select one timestamp per location
                                temp=temp(ix,:);
                                %duplicate x3 so it's clear there isn't
                                %just one timestamp
                                temp=[temp; temp; temp];
                            end
                            %add jitter for multiple spikes
                            a=rand(size(temp));
                            a=a-0.5;
                            a=a*0.2;
                            temp=temp+a;
                            %plot coordinates
                            X=temp(:,1);
                            Y=temp(:,2);
                            scatter(X,Y,'MarkerFaceColor',[0.9 0.95 1],'MarkerEdgeColor','k','SizeData',25,'LineWidth',0.5);
                        end
                    end
                end
                hold off;
                %plot color bar
                if d4==1 && d5==1
                    c=colorbar('Location','South');
                    set(c,'XTick',[],...
                        'Position',[0.92 0.89 0.06 0.03]);
                    if get(b4,'value')==3
                        set(c,'XTick',[0 1 2]);
                    end
                end
                %add time labels
                t=NOTES.CurrentTime; %current time
                t=t+(d4-1); %add current time step
                t=t*NOTES.BinSize; %convert to elements
                t=t/SR; %convert to sec
                if ~isempty(NOTES.Triggers)
                    t=t-NOTES.Triggers(1); %subtract trigger time
                end
                t=t*NOTES.TimeScale;
                t=round(t*10)/10;
                t_string=[num2str(t) NOTES.TimeScaleString];
                a=title(t_string,...
                    'Color',[0.5 0.5 0.5],...
                    'FontSize',10,...
                    'FontWeight','bold');
                %indicate trigger
                tr=NOTES.Triggers*NOTES.SampleRate;
                tr=round(tr/NOTES.BinSize);
                tr_true=tr==NOTES.CurrentTime+(d4-1);
                tr_true=any(tr_true);
                if tr_true
                    set(a,'Color','w');
                    %add box around trigger frame
                    axis on;
                    box on;
                    set(gca,'XColor','w',...
                        'XTick',[],...
                        'YColor','w',...
                        'YTick',[],...
                        'LineWidth',2);
                end
            end
        end
    end
    function savemovie(src,evt)
        %identify singleton spatial dimension
        d=size(data_plot);
        xy=(d(1:3)~=1);
        %cycle through conditions
        for d5=1:size(data_plot,5)
            %figure window & axes
            f_movie=figure('Units','Normalized','Position',[0.1 0.1 0.8 0.75]); %fix position to match aspect ratio of frames
            ha_movie=tight_subplot(1,1,0,0,0);
            %color map
            if NOTES.Cmap==1
                set(gcf,'Colormap',jet);
            elseif NOTES.Cmap==2
                set(gcf,'Colormap',cmap2);
            end
            %preallocate memory
            M(1:nframes)=getframe(gcf);
            %reset frame counter
            x=0;
            %
            if nframes>size(data_plot,4)
                n=size(data_plot,4);
            else
                n=nframes;
            end
            %cycle through time series            
            for d4=1:n
                %advance frame counter
                x=x+1;
                %get image & plot
                im=data_plot(:,:,:,d4,d5,:,:,:);
                im=squeeze(im);   
                imagesc(im);
                axis off;
                caxis(clim);
                %plot timestamps
                hold on;
                if isfield(NOTES,'FieldNames_t') && ~isempty(data_ts)
                    temp=data_ts;
                    a=NOTES.CurrentTime;
                    if isnan(a)
                        a=0;
                    end
                    %timestamps at current time
                    ix = temp(:,4) == d4+a;
                    temp=temp(ix,:);
                    %timestamps at current condition
                    if ~isempty(temp)
                        ix = temp(:,5) == d5;
                        temp=temp(ix,:);
                        %plot timestamps as scatter
                        if ~isempty(temp)
                            %remove all non-spatial dimensions (Dims 4-8)
                            temp=temp(:,1:3);
                            %remove singleton spatial dimension
                            temp=temp(:,xy);
                            %add jitter for multiple spikes
                            a=rand(size(temp));
                            a=a-0.5;
                            a=a*0.1;
                            temp=temp+a;
                            %plot coordinates
                            X=temp(:,1);
                            Y=temp(:,2);
                            scatter(X,Y,'MarkerFaceColor',[0.9 0.95 1],'MarkerEdgeColor','k','SizeData',140,'LineWidth',0.5);
                            %note: does not indicate whether 1 or multiple timestamps per bin
                        end
                    end
                end
                hold off;
                %add time labels
                t=NOTES.CurrentTime; %current time
                t=t+(d4-1); %add current time step
                t=t*NOTES.BinSize; %convert to elements
                t=t/SR; %convert to sec
                if ~isempty(NOTES.Triggers)
                    t=t-(NOTES.Triggers(1)); %subtract trigger time
                end
                l=(nframes*NOTES.BinSize)/NOTES.SampleRate;
                if l>=3600
                    t_string=[num2str(round(t/3600)) ' hr'];
                elseif l>=60
                    t_string=[num2str(round(t/60)) ' min'];
                elseif l<1
                    t_string=[num2str(round(t*1000)) ' ms'];
                else
                    t_string=[num2str(round(t)) ' s'];
                end
                if d4==1
                    pause;
                end
                pause(10/nframes);
                %save figure frame for movie
                M(x) = getframe(gcf);
            end
            %SAVE MOVIE AND CLOSE
            %file name
            string = [NOTES.SaveString '_' num2str(d5)];
            %make video
            f = VideoWriter(string,'MPEG-4');
            %set frame rate
            set(f,'FrameRate',10)
            %save .mp4 file
            open(f)
            writeVideo(f,M);
            close(f);
        end
    end
end
