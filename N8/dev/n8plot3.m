function n8plot3
%PCA for averaged data
%for stimulus invariance data set

%% Variables
global NOTES RESULTSa STATS

%% GET DATA
%get data for current field
data=n8getdata(NOTES.CurrentField);
%dimensions
d=ones(1,8);
d(1:length(size(data)))=size(data);
%remove trial/other dimension
if d(8)>1, data=nanmean(data,8); end
if d(7)>1, data=nanmean(data,7); end

%% Times
%select times
data=data(:,:,:,NOTES.CurrentTimeWindow(1):NOTES.CurrentTimeWindow(3),:,:,1,1);
%downsample if > 3e3 points
if size(data,4)>3e3
    ds=round(size(data,4)/3e3);
    data=data(:,:,:,1:ds:end,:,:,1,1);
    msg{end+1}=['data downsampled by factor of ' num2str(ds)];
else
    ds=1;
end
%time labels
for d5=1:d(5)
    for d6=1:d(6)+1
        labels(:,d5,d6)=(NOTES.CurrentTimeWindow(1):ds:NOTES.CurrentTimeWindow(3));
    end
end

%% Conditions
%number of conditions
conditions=choose('select which conditions to compare',d(5));
%select conditions
data=data(:,:,:,:,conditions,:,1,1);
%condition colors
c=varycolor(NOTES.Dimensions(5));
c=c(conditions,:);

%% Dimensions
d=ones(1,8);
d(1:length(size(data)))=size(data);

%% PCA variables
%number of PCs
n=4;
%save current time window
STATS.PCA.TimeWindow=NOTES.CurrentTimeWindow;
%save current field
STATS.PCA.Field=NOTES.CurrentField;

%% PCA
%vectorize spatial dimensions & times,conditions,subjects
vdata=reshape(data,d(1)*d(2)*d(3),d(4)*d(5)*d(6));
%initialize variables
EXPLAINED=[];
SCORE=[];
pdata_score=[];
pdata=[];
%data
runPCA(vdata);
%figure window for principal components
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
currentsubjects=1:d(6);
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
b1string{n+1}='Max';
b1b = uicontrol(gcf,'Style','popup',...
    'String',b1string,...
    'Value',yaxis,...
    'FontSize',12,...
    'FontWeight','bold',...
    'Units','normalized',...
    'Position',[0.95 0.95 0.04 0.03],...
    'Callback',@(obj,evt)plotPCA(obj,evt));
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
        %calculate mean/sem for PCA data
        pdata(:,:,d(6)+1,:)=nanmean(pdata,3);
        pdata(:,:,d(6)+2,:)=nanstd(pdata,3)/sqrt(d(6));
        %reshape principal components into d(2) x d(3) matrix
        pdata_score=reshape(SCORE,d(1),d(2),d(3),n);
        pdata_score=squeeze(pdata_score);
        %%%NEED TO FIX TO HANDLE 3D DATA
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
        %get data
        xaxis=get(b1a,'value');
        yaxis=get(b1b,'value');
        test=[];
        for d6=1:d(6)+1
            test(d6)=get(b6(d6),'value');
        end
        currentsubjects=find(test);
        %get X-Axis data
        if xaxis==n+1
            data1=labels;
        else
            data1=squeeze(pdata(:,:,:,xaxis));
        end
        %get Y-Axis data
        if yaxis==n+1
            %get max response (all layers)
            temp=max(data,[],3);
            temp=max(temp,[],2);
            temp=max(temp,[],1);
            data2=temp;
            %mean/sem
            data2(:,:,:,:,:,d(6)+1)=nanmean(temp,6);
            data2(:,:,:,:,:,d(6)+2)=nanstd(temp,6)/sqrt(d(6));
            %squeeze
            data2=squeeze(data2);
        else %PC data
            data2=squeeze(pdata(:,:,:,yaxis));
            data2se=squeeze(pdata(:,:,d(6)+2,yaxis));
        end
        %plot selected conditions/times
        figure(f1)
        cla;
        for d5=1:d(5)
            for d6=currentsubjects
                %data for current plot
                temp1=data1(:,d5,d6);
                temp2=data2(:,d5,d6);
                %line width: subj=thin, ave=thick
                if d6>d(6)
                    tempSE=data2(:,d5,d6+1);
                    shadedErrorBar2(temp1,temp2,tempSE,{'color',c(d5,:),'LineWidth',3});
                else
                    plot(data1(:,d5,d6),data2(:,d5,d6),'Color',c(d5,:),'LineWidth',1.5);
                end
            end
        end
        if nargin>0
            if src==b1a || src==b1b
                axis tight;
            end
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

