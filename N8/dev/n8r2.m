function n8r2
%calculate Pearson's coefficient of determination (r^2) for each condition combo

%% Variables
%globals
global NOTES DATAa STATS
%dimensions
d=NOTES.Dimensions;
%check # of conditions
if d(5)>4
    conditions=choose('select which conditions to compare',d(5));
else
    conditions=true(d(5),1);
end
%check for >1 conditions
if length(conditions)<2
    error('please select at least 2 conditions'); 
end
%number of condition comparisons
n=nchoosek(sum(conditions),2);
%colors
c=varycolor(n);
%other
msg={};
%save current time window
STATS.Pearsons.TimeWindow=NOTES.CurrentTimeWindow;
%save current field
STATS.Pearsons.Field=NOTES.CurrentField;


%% GET DATA
%get data for current field
data=n8getdata(NOTES.CurrentField);
%remove trial/other dimension
if d(8)>1, data=nanmean(data,8); end
if d(7)>1, data=nanmean(data,7); end
%select conditions
data=data(:,:,:,:,conditions,:,1,1);
%select times
data=data(:,:,:,NOTES.CurrentTimeWindow(1):NOTES.CurrentTimeWindow(3),:,:,1,1);
%downsample if > 3e3 points
if size(data,4)>3e3
    ds=round(size(data,4)/3e3);
    data=data(:,:,:,1:ds:end,:,:,1,1);
    msg{end+1}=['data downsampled by factor of ' num2str(ds)];
end
%reset dimensions
d=size(data);

%% Pearsons correlations (mixed model)
R2=[];
P=[];
d6down=0;
%run analysis
for d6=1:d(6)
    %skip subjects with no data
    test=data(:,:,:,:,:,d6,1,1);
    if sum(isnan(test(:)))==numel(test)
        msg{end+1}=['Subject ' num2str(d6) ' removed from analysis'];
        d6down=d6down+1;
        continue;
    end
    %remove nans (missing data)
    test=data(:,:,:,1,:,d6,1,1);
    test=mean(test,5);
    test1=squeeze(mean(mean(test,2),3));
    test2=squeeze(mean(mean(test,1),3));
    test3=squeeze(mean(mean(test,1),2));
    if sum(isnan([test1(:); test2(:); test3(:)]))>0
        msg{end+1}=['Some recording locations/layers removed for Subject ' num2str(d6)];
    end
    for d4=1:d(4)
        temp=data(~isnan(test1),~isnan(test2),~isnan(test3),d4,:,d6,1,1);
        %vectorize data
        d2=size(temp);
        temp=reshape(temp,d2(1)*d2(2)*d2(3),d2(5));
        [r,p]=corrcoef(temp);
        %save unique comparisons (1v2, 1v3, 1v4 ..., 2v3, 2v4 ...)
        e=0;
        for i=1:d(5)-1
            s=e+1;
            e=s+d(5)-i-1;
            R2(s:e,d4,d6)=r(i,2+(i-1):end);
            P(s:e,d4,d6)=p(i,2+(i-1):end);
        end
    end
end
%convert r-values to r^2 values
R2=R2.^2;

%% Save results in STATS
STATS.Pearsons.R2=R2;
STATS.Pearsons.P=P;
STATS.Pearsons.ncomparisons=n;
STATS.Pearsons.messages=msg;

%% Calculate confidence intervals (if baseline is in window)
if max(NOTES.BaselineWindow)>min(NOTES.CurrentTimeWindow)
    %calculate "sig" threshold (mean bl + 2 sd)
    CI95=R2(:,NOTES.CurrentTimeWindow(1):NOTES.BaselineWindow(2),:);
    CI95=CI95(:);
    CI95=nanmean(CI95)+2*nanstd(CI95);
    NOTES.Pearsons.CI95=CI95;
end

%% Plot results
figure('units','normalized','outerposition',[0,0.6,1,0.4]);
plot(ones(d(4),1)*CI95,'LineStyle',':','Color','k');
hold on;
for i=1:size(R2,1)
    %mean
    mn=nanmean(R2(i,:,:),3);
    plot(1:d(4),mn,'color',c(i,:),'LineWidth',6);
    %upper SE
    se1=mn + nanstd(R2(i,:,:),3)./sqrt(d(6)-d6down);
    plot(1:d(4),se1,'color',c(i,:),'LineWidth',2);
    %lower SE
    se2=mn - nanstd(R2(i,:,:),3)./sqrt(d(6)-d6down);
    plot(1:d(4),se2,'color',c(i,:),'LineWidth',2);
end
%legend;
title(NOTES.CurrentField);
ylabel('r2 value');
axis tight;
set(gca,'YLim',[0 1]);
