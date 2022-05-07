function data = n8imagefun(data,fun,funprops)

%set function properties
if nargin<3
    funprops=char(0);
end
if ~isempty(funprops)
    funprops=[',' funprops];
end

%dimensions
d=ones(1,8);
d(1:length(size(data)))=size(data);

%apply function to each image of data set
if sum(d(1:3)>1)<3
    %for 2D data
    %vectorize all non-spatial dimensions
    data=reshape(data,[d(1:3) prod(d(4:8))]);
    for i=1:prod(d(4:8))
        temp=squeeze(data(:,:,:,i));
        eval(['temp=' fun '(temp' funprops ');']);
        data(:,:,:,i)=temp;
    end
else
    %for 3D data (diff depth = diff image)
    %vectorize all non-spatial dimensions
    data=reshape(data,[d(1:2) prod(d(3:8))]);
    for i=1:prod(d(3:8))
        temp=squeeze(data(:,:,:,i));
        eval(['temp=' fun '(temp,' funprops ');']);
        data(:,:,:,i)=temp;
    end
end

%reshape data
data=reshape(data,d);


