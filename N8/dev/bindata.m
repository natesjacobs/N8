function data = bindata(data,bin,dim)

%crop data if d(4) doesn't divide evenly by bin size
cut = rem(d(4),b);
%cut = b-cut;
image=image(:,:,:,1:end-cut,:,:,:,:);
%update d4
d(4)=size(image,4);
%add new dimension before dim4
image=reshape(image,[d(1),d(2),d(3),b,d(4)/b,d(5),d(6),d(7),d(8)]);
%average across binsize
image=nanmean(image,4);
%remove added dimension
d(4)=size(image,5);
image=reshape(image,[d(1),d(2),d(3),d(4),d(5),d(6),d(7),d(8)]);