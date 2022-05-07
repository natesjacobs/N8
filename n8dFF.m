function data = n8dFF(data)

%% Variables
%dimensions of data
d=ones(1,8);
d(1:length(size(data)))=size(data);
%get data class
c=class(data);

%% Get mean value across time
%vectorize non-temporal dimensions
data=permute(data,[4 1 2 3 5 6 7 8]);
data=reshape(data,[d(4) numel(data)/d(4)]);
%calculate median
m=nanmedian(single(data),1); %%%%%%%%%%%%%%%%%%%% MEDIAN
%calculate min to remove any negative values
mn=nanmin(single(data),[],1); 
m=m-mn;
%make double
m=double(m);
mn=double(mn);

%% Subtract median
for i=1:size(m,2);
    %get data
    temp=data(:,i);
    %make double
    temp=double(temp);
    %make positive (to match positive median values)
    temp=temp-mn(i);
    %calculate dFF
    temp=temp./m(i);
    %convert to % (also avoids excessive clipping when converting back to int16)
    temp=temp*100;
    %center about 0 (-% = reduction, +% = increase)
    temp=temp-100;
    %convert to same class as data
    eval(['temp=' c '(temp);']);
    %replace data
    data(:,i)=temp;
end
%reshape into N8 array
data=reshape(data,[d(4) d([1:3 5:8])]);
data=permute(data,[2 3 4 1 5 6 7 8]);

