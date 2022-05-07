global DATA NOTES

d=size(DATA.Raw);
a=mean(DATA.Raw,4);
for i=1:d(4)
    DATA.Movie(:,:,1,i)=int16((a+0.7*(double(DATA.dFdt(:,:,1,i)).^2))/4);
end