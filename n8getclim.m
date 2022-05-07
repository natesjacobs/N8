function clim=n8getclim(data,satlevel,balancedyesno)

global DATA NOTES

%variables
if nargin<1
    eval(['data=DATA.' NOTES.CurrentField ';']);
    data=double(data);
end
if nargin<2
    satlevel=0.3;
else
    if satlevel<0 || satlevel>1
        error('satlevel input must be value between 0 and 1');
    end
end
if nargin<3
    balancedyesno=true;
else
    balancedyesno=logical(balancedyesno);
end

%invert satlevel
satlevel=satlevel*3;
satlevel=3-satlevel;
satlevel=satlevel+0.01;
    
%set thresh to abs(mean) + variance
m=nanmean(data(:));
s=nanstd(data(:));
clim(1)=m-(s*satlevel);
clim(2)=m+(s*satlevel);

%make sure it's not 0
if clim(1)>=clim(2)
    clim=[0 1];
end

%balance if selected
if balancedyesno
    clim=max(abs(clim));
    clim=[-clim clim];
end

%save in global
if nargin<1
    NOTES.Threshold(NOTES.CurrentFieldVal)=clim(2);
end

