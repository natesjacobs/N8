function data = n8submn(data)

%% Variables
%dimensions of data
d=ones(1,8);
d(1:length(size(data)))=size(data);
%get data class
dt=class(data);

%% Get mean values across space
%vectorize spatial dimensions (dim1) and other (dim2)
data=reshape(data,[prod(d(1:3)) prod(d(4:8))]);
%calculate median
m=nanmedian(data,1); %%%%%%%%%%%%%%%%%%%% MEDIAN
m=double(m);
%center around 0 to avoid edge issue when smoothing
m_mn=nanmean(m,2);
m_mn=repmat(m_mn,[1,size(m,2),d(5:8)]);
m=m-m_mn;
%smooth mean value across time
m=reshape(m,[1 1 1 prod(d(4:8))]);
m=n8tsmooth(m,10,50);
m=reshape(m,[1 prod(d(4:8))]);
%return to original value
m=m+m_mn;
%convert to same class as data
eval(['m=' dt '(m);']);

%% Subtract mean value
%use loop to subtract
for i=1:size(m,2);
    data(:,i)=data(:,i)-m(i);
end
%reshape into N8 array
data=reshape(data,d);

