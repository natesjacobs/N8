function n8clims
%% Sets color axis limits to lower and upper quartiles of DATA fields
% Determines if data is centered about 0, if so makes clims symmetric

global DATA NOTES

%% Get current field
cf=NOTES.CurrentField;

%% Set color map and color axis
if NOTES.TSvars(cf)
    %timestamp data
    NOTES.Threshold(cf,:)=[0 2];
    NOTES.Cmap(cf)=1;
else
    %continuous data
    %get quartiles
    eval(['a=quantile(single(DATA.' NOTES.Fields{cf} '(:)),[0.01 0.99]);']);
    %if data centered around 0, use symmetric threshold
    ctrtest=a(1)/a(2);
    if ctrtest<-0.25
        %use symmetric threshold
        c=max(abs(a));
        NOTES.Threshold(cf,:)=[-c c];
        NOTES.Cmap(cf)=2;
    else
        %don't use symmetric threshold
        NOTES.Threshold(cf,1:2)=a;
        NOTES.Cmap(cf)=1;
    end
end
