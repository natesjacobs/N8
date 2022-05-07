function data = n8vectorspace(data)

%get dimensions
d=size(data);

%reshape data
data=reshape(data,[prod(d(1:3)) d(4:8)]);