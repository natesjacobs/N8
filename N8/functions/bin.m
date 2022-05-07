function Y = bin(X,binsize)
%%bins data X into returns bin averages in Y

%make sure binsize is round number
if binsize~=round(binsize)
    warning('binsize set to non-integer value');
end
binsize=round(binsize);
%check length of X
cut = rem(length(X),binsize);
%crop so that X divides evenly by binsize
Y=X(1:end-cut);
%add new dimension to average bins
dim1=binsize;
dim2=length(Y)/binsize;
Y=reshape(Y,[dim1,dim2]);
%average across bins
Y=nanmean(Y,1);