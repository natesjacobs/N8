function n8pca(data_string,conditions,times,n)
%PCA for averaged data
%for stimulus invariance data set
close all;

%% Variables
global NOTES RESULTSa STATS
eval(['data=RESULTSa.' data_string ';']);
if strcmp(data_string,'LFPmean') || strcmp(data_string,'MUAmean') || strcmp(data_string,'RAWmean')
    data=-data;
end
d=size(data);

%% Convert times from ms to elements
%time steps
steps_el=steps_ms*(NOTES.SampleRate/1e3);
%how many elements in 1 ms
el_in_1ms=1/steps_ms;
%triggers
triggers_ms=(NOTES.Triggers/NOTES.SampleRate)*1e3;
%say which trigger number to save in diff TOI dim
if NOTES.SaveAnalysis==1
    temp=triggers_ms(triggers_ms>start_ms);
    temp=temp(temp<stop_ms);
    trig=find(triggers_ms==temp);
    triggers_ms=temp;
    clearvars temp;
    if length(triggers_ms)>1
        trig=length(NOTES.Triggers)+1;
    end
end
triggers_ms=triggers_ms-start_ms+1;
triggers_el=triggers_ms*el_in_1ms;
%start/stop times
start_el=round((start_ms/1e3)*NOTES.SampleRate);
stop_el=round((stop_ms/1e3)*NOTES.SampleRate);

%% get data
%crop
data=data(:,NOTES.Crop,:,:,:,:,:);
%average any trials
data=nanmean(data,7);
%replace NaN's with 0's
data(isnan(data))=0;
%dimensions
d=size(data);

%% Get times
%select times/conditions
data=data(:,:,:,start_el:steps_el:stop_el,conditions,:,:);
d=size(data);

%% Normalize by subject/condition
%vectorize recording locations & calculate max values
m=reshape(data,d(1)*d(2)*d(3)*d(4),1,1,1,d(5),d(6));
m=max(m,[],1);
%replicate matrix and divide data by max values
m=repmat(m,[d(1) d(2) d(3) d(4) 1 1]);
data_norm=data./m;

%% Fill in missing values with random numbers near min value
filler=min(abs(data(data>0)));
nandata=zeros(1,d(5),d(6),1);
for d5=1:d(5)
    for d6=1:d(6)
        %Fill in missing conditions with minimum values
        test=data(:,:,:,:,d5,d6);
        test=mean(test(:));
        if test==0
            %if no values for a particular condition, fill with random
            %variations around minimum value to avoid PCA error
            data(:,:,:,:,d5,d6)=rand(d(1),d(2),d(3),d(4))*filler*0.01;
            data_norm(:,:,:,:,d5,d6)=rand(d(1),d(2),d(3),d(4))*0.0001;
            nandata(1,d5,d6,1)=1;
        end
    end
end
nandata=repmat(nandata,[d(4),1,1,n]);
nandata=logical(nandata);

%% Vectorize
vdata=reshape(data,d(1)*d(2)*d(3),d(4)*d(5)*d(6));
vdata_norm=reshape(data_norm,d(1)*d(2)*d(3),d(4)*d(5)*d(6));

%% PCA
%number of principle components
EXPLAINED=[];
SCORE=[];
pdata_score=[];
pdata=[];
toi=[];

%data
runPCA(vdata);
normyesno=0; %default is non-normalized data

%% Time labels
for d5=1:d(5)
    for d6=1:d(6)+1
        labels(:,d5,d6)=((1:d(4))*steps_ms) + start_ms; %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%NEED TO CHECK/ADJUST
    end
end

%% Color scheme
c=[0 200 0; 0 150 200; 0 0 255; 0 0 100; 255 150 0; 255 0 150; 255 0 0; 150 0 0];
c=c/255;
c=c(conditions,:);


%% PCs figure window
%principal components
f2=figure('Color',[0.2 0.2 0.2],...
    'Units','normalized',...
    'OuterPosition',[0 0 0.2 1],...
    'Toolbar','none',...
    'Colormap',cmap1);

%% Main figure window
%main figure window
f1=figure('units','normalized',...
    'OuterPosition',[0.2 0 0.8 1],...
    'Color','w',...
    'Toolbar','figure');
%defaults
xaxis=n+1;
yaxis=1;
currentconditions=1:d(5);
currentsubjects=1:d(6);
datatype=0;
endtime=d(4);
starttime=1;
%X-axis
for i=1:n
    b1string{i}=['PC' num2str(i)];
end
b1string{n+1}='time';
b1a = uicontrol(gcf,'Style','popup',...
    'String',b1string,...
    'Value',xaxis,...
    'FontSize',12,...
    'FontWeight','bold',...
    'Units','normalized',...
    'Position',[0.91 0.95 0.04 0.03],...
    'Callback',@(obj,evt)plotPCA(obj,evt));
%Y-axis
for i=1:d(3)
    b1string{n+i}=['Max' num2str(i)];
end
b1string{n+d(3)+1}='Max All';
b1b = uicontrol(gcf,'Style','popup',...
    'String',b1string,...
    'Value',yaxis,...
    'FontSize',12,...
    'FontWeight','bold',...
    'Units','normalized',...
    'Position',[0.95 0.95 0.04 0.03],...
    'Callback',@(obj,evt)plotPCA(obj,evt));
%Normalize
b2 = uicontrol(gcf,'Style','checkbox',...
    'String','Normalize',...
    'FontSize',10,...
    'Units','normalized',...
    'Value',normyesno,...
    'BackGroundColor','w',...
    'Position',[0.91 0.88 0.06 0.04],...
    'Callback',@changenorm);
%Line vs Timestamps
b3 = uicontrol(gcf,'Style','togglebutton',...
    'String','---',...
    'FontSize',12,...
    'Units','normalized',...
    'Position',[0.91 0.925 0.08 0.025],...
    'Value',1,...
    'Callback',@plotPCA);
%End time
b4 = uicontrol(gcf,'Style','slider',...
    'Min',2,...
    'Max',d(4),...
    'SliderStep',[1/d(4) 0.1],...
    'Value',d(4),...
    'Units','normalized',...
    'Position',[0.3 0.95 0.4 0.03],...
    'Callback',@plotPCA);
%Select conditions
for d5=1:d(5)
    b5(d5)=uicontrol(gcf,'Style','checkbox',...
        'String',['C' num2str(conditions(d5))],...
        'FontSize',10,...
        'Units','normalized',...
        'Position',[0.91 0.87-0.03*d5 0.15 0.04],...
        'BackgroundColor','w',...
        'Value',1,...
        'Callback',@plotPCA);
end
%Select subject
for d6=1:d(6)+1
    s=['S' num2str(d6)];
    v=0;
    if d6>d(6)
        s='Ave';
        v=1;
    end
    b6(d6)=uicontrol(gcf,'Style','checkbox',...
        'String',s,...
        'FontSize',10,...
        'Units','normalized',...
        'Position',[0.95 0.87-0.03*d6 0.15 0.04],...
        'BackgroundColor','w',...
        'Value',v,...
        'Callback',@plotPCA);
end
%Change start time yes/no
b7 = uicontrol(gcf,'Style','togglebutton',...
    'String','snake',...
    'FontSize',10,...
    'Units','normalized',...
    'Value',0,...
    'Position',[0.701 0.95 0.05 0.033],...
    'Callback',@plotPCA);
%save figure windows
uicontrol(gcf,'Style','pushbutton',...
    'String','save',...
    'FontSize',10,...
    'Units','normalized',...
    'Value',0,...
    'Position',[0.752 0.95 0.05 0.033],...
    'Callback',@saveEPS);

%% Initialize plots
%plot PCs
plotPCs;

%plot PCA scores
figure(f1);
hold on;
plotPCA;

%set axes defaults
set(gca,'XLim',[min(data1(:)) max(data1(:))],...
    'YLim',[min(data2(:)) max(data2(:))]); %,...%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %'visible','off');
axis tight;


%% Functions
    function runPCA(input)
        %PCA
        [pdata_temp, SCORE, LATENT, TSQUARED, EXPLAINED, MU]=pca(input,'NumComponents',n,'Centered','off');%%%%%%%%%%%%%
        %reshape scores/loadings by condition and component
        pdata=reshape(pdata_temp,d(4),d(5),d(6),n);
        %SMOOTH DATA
        for i=1:size(pdata,2)
            for j=1:size(pdata,3)
                for k=1:size(pdata,4)
                    %filter size
                    w=5/steps_ms;
                    if min(conditions)<=4
                        pdata(:,i,j,k)=gsmooth(pdata(:,i,j,k),8,w);
                    else
                        pdata(:,i,j,k)=gsmooth(pdata(:,i,j,k),5,w);
                    end
                end
            end
        end
        %REPLACE MISSING VALUES WITH NANS
        pdata(nandata)=NaN;
        %calculate mean/sem for PCA data
        pdata(:,:,d(6)+1,:)=nanmean(pdata,3);
        pdata(:,:,d(6)+2,:)=nanstd(pdata,3)/sqrt(d(6));
        %reshape principal components into d(2) x d(3) matrix
        pdata_score=reshape(SCORE,d(2),d(3),n);
        %rerun stats
        findTOI;
    end
    function plotPCs(src,evt)
        figure(f2)
        for i=1:n
            subplot(n,1,i);
            plotdata=squeeze(pdata_score(:,:,i));
            imagesc(plotdata');
            title(['PC' num2str(i) ' - ' num2str(round(EXPLAINED(i))) '%'],'Color','w');
            axis off;
            clim=[-max(abs(plotdata(:))) max(abs(plotdata(:)))];
            caxis(clim);
            colorbar('YTick',[clim(1) 0 clim(2)],'YTickLabel',[clim(1) 0 clim(2)]);
        end
    end
    function plotPCA(src,evt)
        %determine start/stop times
        endtime=round(get(b4,'value'));
        if get(b7,'value')==0
            starttime=1;
            set(b7,'string','snake');
        elseif get(b7,'value')==1
            starttime=endtime-round(25/steps_ms);
            set(b7,'string','funnel cake');
        end
        if starttime<1
            starttime=1;
        end
        %get data
        xaxis=get(b1a,'value');
        yaxis=get(b1b,'value');
        datatype=get(b3,'value');
        test=[];
        for d5=1:d(5)
            test(d5)=get(b5(d5),'value');
        end
        currentconditions=find(test);
        test=[];
        for d6=1:d(6)+1
            test(d6)=get(b6(d6),'value');
        end
        currentsubjects=find(test);
        %get X-Axis data
        if xaxis>n
            data1=labels;
        else
            data1=squeeze(pdata(:,:,:,xaxis));
        end
        %get Y-Axis data
        if yaxis==n+d(3)+1 
            %get max response (all layers)
            temp=max(data,[],3);
            temp=max(temp,[],2);
            data2=temp;
            %mean/sem
            data2(:,:,:,:,:,d(6)+1)=nanmean(temp,6);
            data2(:,:,:,:,:,d(6)+2)=nanstd(temp,6)/sqrt(d(6));
            %squeeze
            data2=squeeze(data2);
        elseif yaxis>n 
            %get max response (individual layer)
            temp=data(:,:,yaxis-n,:,:,:);
            temp=max(temp,[],2);
            data2=temp;
            %mean/sem
            data2(:,:,:,:,:,d(6)+2)=nanstd(temp,6)/sqrt(d(6));
            data2(:,:,:,:,:,d(6)+1)=nanmean(temp,6);
            %squeeze
            data2=squeeze(data2);
        else %PC data
            data2=squeeze(pdata(:,:,:,yaxis));
            data2se=squeeze(pdata(:,:,d(6)+2,yaxis));
        end
        %plot selected conditions/times
        figure(f1)
        cla;
        for d5temp=fliplr(1:length(currentconditions))
            for d6=currentsubjects
                d5=currentconditions(d5temp);
                %data for current plot
                temp1=data1(starttime:endtime,d5,d6);
                temp2=data2(starttime:endtime,d5,d6);
                if datatype==0
                    lscatter(temp1,temp2,labels(starttime:endtime,d5,d6),...
                        'LabelColor',c(d5,:),...
                        'FontSize',7,...
                        'FontWeight','bold');
                elseif datatype==1
                    %line width: subj=thin, ave=thick
                    if d6>d(6)
                        tempSE=data2(starttime:endtime,d5,d6+1);
                        shadedErrorBar2(temp1,temp2,tempSE,{'color',c(d5,:),'LineWidth',3});
                    else
                        plot(data1(starttime:endtime,d5,d6),data2(starttime:endtime,d5,d6),'Color',c(d5,:),'LineWidth',1.5);
                    end
                    %mark times of interest (toi's)
                    %use PC specified by xaxis
                    %if "time" selected for xaxis, use yaxis
                    %if "time" is selected for xaxis and yaxis is set to anything other than PC1:n, use toi's for max responses
                    if xaxis<=n
                        times=squeeze(toi(d5,d6,xaxis,:));
                    elseif xaxis==n+1
                        if yaxis<=n
                            times=squeeze(toi(d5,d6,yaxis,:));
                        elseif yaxis>n
                            times=squeeze(toi(d5,d6,n+1,:));
                        end
                    end
                    %mark first/last response
                    times1=[times(1) times(end)];
                    times1=times1(times1<=endtime);
                    times1=times1(~isnan(times1));
                    times1=times1(times1>0);
                    if ~isempty(times1)
                        scatter(data1(times1,d5,d6),data2(times1,d5,d6),...
                            'Marker','diamond',...
                            'SizeData',100,...
                            'MarkerFaceColor','w',...
                            'MarkerEdgeColor',c(d5,:)*0.75);
                    end
                    %mark peak responses
                    times2=times(2:end-1);
                    times2=times2(times2<=endtime);
                    times2=times2(~isnan(times2));
                    times2=times2(times2>0);
                    if ~isempty(times2)
                        scatter(data1(times2,d5,d6),data2(times2,d5,d6),...
                            'Marker','diamond',...
                            'SizeData',100,...
                            'MarkerFaceColor',c(d5,:)*0.75,...
                            'MarkerEdgeColor',c(d5,:)*0.75);
                    end
                end
                
            end
        end
        if nargin>0
            if src==b1a || src==b1b
                axis tight;
            end
        end
    end
    function changenorm(src,evt)
        normyesno=get(b2,'value');
        if normyesno==0
            runPCA(vdata);
        elseif normyesno==1
            runPCA(vdata_norm);
        end
        plotPCs;
        plotPCA;
        set(gca,'XLim',[min(data1(:)) max(data1(:))],...
            'YLim',[min(data2(:)) max(data2(:))]);
        axis tight;
    end
    function findTOI
        t=triggers_el(1);
        %find times of interest (toi) for each sig PC and raw values
        for pc=1:n+1
            %calculate thresh_last in case needed
            if pc<=n
                thresh_last=pdata(end,:,1:d(6),pc);
            else
                thresh_last=data(end,:,1:d(6));
            end
            thresh_last=max(thresh_last(:));
            for d5=1:d(5)
                for d6=1:d(6)+1
                    %prefill toi with NaNs
                    temp(1:4)=NaN;
                    %get data
                    if pc<=n
                        %PCA data
                        p=pdata(:,d5,d6,pc);
                    else
                        %Raw data (max absolute response, + or -)
                        %RESPONSE
                        p=data(:,:,:,:,d5,:);
                        p_min=min(p,[],2);
                        p_max=max(p,[],2);
                        p_min=min(p_min,[],3);
                        p_max=max(p_max,[],3);
                        if d6<=d(6)
                            %Subject
                            p_min=p_min(:,:,:,:,1,d6);
                            p_max=p_max(:,:,:,:,1,d6);
                        elseif d6>d(6)
                            %Group mean)
                            p_min=nanmean(p_min(:,:,:,:,1,:),6);
                            p_max=nanmean(p_max(:,:,:,:,1,:),6);
                        end
                        p_min=squeeze(p_min);
                        p_max=squeeze(p_max);
                        p=[p_min'; p_max'];
                        [p ix]=max(abs(p));
                        %make index -1 or +1 depending on whether biggest response was - or +
                        ix(ix==1)=-1;
                        ix(ix==2)=1;
                        p=p.*ix;
                    end
                    p=squeeze(p);
                    %buffer to avoid stim artifact (0-4ms)
                    ms4=round(el_in_1ms)*3;
                    %calculate baseline mean and std
                    mn=mean(p(1:t));
                    sd=std(p(1:t));
                    %calculate z-scores (relative to baseline)
                    z=(p-mn)/sd; %calculate z-scores (relative to baseline)
                    %set baseline values = 0 to avoid false positive before stim
                    z(1:t+ms4)=0;
                    %if specified, use absolute values of z to detect + or - responses
                    if absoluteZforTOIyesno==1
                        z2=abs(z);
                    else
                        z2=z;
                    end
                    
                    %FIRST RESPONSE (#1, first positive z-score above 3)
                    %element 1
                    a=find(z2>3,1,'first');
                    if ~isempty(a)
                        temp(1)=a;
                    end
                    
                    %LAST RESPONSE (#4, last z-score above 3)
                    %determine thresh for last
                    if autolastyesno==1
                        th=3;
                    else
                        th=(thresh_last-mn)/sd;
                    end
                    %make values absolute to detect + or - responses %%%%%%%
                    a=find(z2>th,1,'last');
                    if ~isempty(a) %&& a=~d(4)
                        temp(4)=a;
                    end
                    
                    %MIN/MAX VALUES (#2,3)
                    %elements 2, 3
                    %remove data before first response
                    if ~isnan(temp(1))
                        z(1:temp(1))=NaN;
                    end
                    %remove data after last response
                    if ~isnan(temp(4))
                        z(temp(4):end)=NaN;
                    end
                    %find min value
                    mn=find(z==min(z));
                    if ~isempty(mn)
                        temp(2)=mn(1); %use first instance if multiple
                    end
                    %find max value
                    mx=find(z==max(z));
                    if ~isempty(mx)
                        temp(3)=mx(1);%use first instance if multiple
                    end
                    
                    %warnings
                    if min(temp(2:end-1))<temp(1)
                        warning('Peak response before first response');
                    end
                    if max(temp(2:end-1))>temp(end)
                        warning('Peak response before first response');
                    end
                    
                    %SAVE
                    toi(d5,d6,pc,1:4)=temp;
                end
            end
        end
        %save results
        TOI=toi(:,1:d(6),:,:);
        TOI=TOI*steps_ms/1e3; %times in sec
        TOI=TOI+(start_ms/1e3); %correct for start time
        TOI=TOI*NOTES.SampleRate; %times in # data elements
        if NOTES.SaveAnalysis==1
            eval(['STATS.TOI.' data_string '(conditions,:,:,:,trig)=TOI;']);
            clc;
            disp(' ');
            disp('Times of Interest (TOI) analysis saved in STATS.')
            disp('*** To turn OFF saving of analyses, make NOTES.SaveAnalysis = 0');
            disp(' ');
        end
    end
    function saveEPS(~,~)
        %save name
        note=['PCA_' data_string '_'];
        if get(b2,'value')==1
            note=[note 'norm_'];
        end
        note=[note num2str(conditions) '_'];
        %save main figure window
        x=get(b1a,'string');
        x=x{get(b1a,'value')};
        y=get(b1b,'string');
        y=y{get(b1b,'value')};
        saveas(f1,[note x ' x ' y],'epsc2');
        %save PCs window
        saveas(f2,[note 'PCs'],'epsc2');
    end
end

