function data = n8align2(data,shiftindx)
%realign N8 array based on 3D "shift" indices
%shiftindx 
    %should be an n x 8 matrix 
    %specifies x,y,z shift (cols 1:3) for each time point, condition,
    %subject, etc. (cols 4:8)
    %n should = product of size of dimensions 4-8.

%% Variables
%dimensions of data
d=ones(1,8);
d(1:length(size(data)))=size(data);
%shift indices
s=shiftindx; %shorthand to make code simpler

%% Check shiftindx format
%check columns
if size(shiftindx,2)~=8
    error('shiftindx should be an n x 8 matrix with n=prod(d(4:8)) where d=size(data)).');
end
%check length
if size(shiftindx,1)~=prod(d(4:8))
    error('shiftindx should be an n x 8 matrix with n=prod(d(4:8)) where d=size(data)).');
end

%% Align data
for i=1:size(shiftindx,1)
    %indices for row i
    s=shiftindx(i,:);
    %get temp data for current time, subj, etc.
    temp=data(:,:,:,s(4),s(5),s(6),s(7),s(8));
    %shift temp data
    temp=circshift(temp,s(1:3));
    %replace data with temp
    data(:,:,:,s(4),s(5),s(6),s(7),s(8))=temp;
end
